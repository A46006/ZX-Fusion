//#include <stdio.h>
#include "./sd_if.h"

FATFS fs;
FIL fil;

const char* SUPPORTED_EXTENSIONS[] = {".z80", ".sna"};
#define N_SUPPORTED_EXTENSIONS (sizeof SUPPORTED_EXTENSIONS / sizeof (const char *))

int init_SD(void) {
	memset(&fs, 0, sizeof(FATFS));
	//fs = malloc(sizeof (FATFS)); 	// Get work area for the volume
	return f_mount(&fs, "", 0);			// Mount the default drive
}

/**
 * Checks input file's extension and compares it to supported ones
 */
bool is_supported_file(char* filename, size_t len) {
	if (len >= FILENAME_LEN-1) return FALSE;
	// Making extensions lower case for comparisons
	char to_compare[len];
	strncpy(to_compare, filename, len);
	for(int i = 1; i < 5; i++) {
		to_compare[len-i] = tolower(filename[len-i]);
	}

	// forcing the end of the filenames strings
	to_compare[len] = '\0';

	char* extension = to_compare + (len-4);
	for (int i = 0; i < N_SUPPORTED_EXTENSIONS; i++) {
		if (strncmp(extension, SUPPORTED_EXTENSIONS[i], 4) == 0) {
			return TRUE;
		}
	}
	return FALSE;
}


int num_of_pages() {
	FRESULT err;
	DIR dir;
	FILINFO fno;
	int num_of_files;

	TCHAR* pattern = "*";
	err = f_findfirst(&dir, &fno, "/", pattern);
	if (!err) {
		if (*fno.fname) {
			num_of_files = 0;
			do {
				if (is_supported_file(fno.fname, strlen(fno.fname))) {
					num_of_files++;
				}
				err = f_findnext(&dir, &fno);
			} while (*fno.fname && !err);

			if (err) {
				printf("Error when finding another entry: 0x%02X\r\n", err);
				return -1;
			}

			return ((num_of_files-1) / 16 ) + 1;
		}

	}
	printf("Counting pages went wrong... 0x%02X\r\n", err);
	return -1;
}

void free_file_list(FILENAMES* filenames) {
	filenames->size = 0;
}

void list_files_of_page(FILENAMES* filenames, int page_num) {
	int filename_num = 0;
	int page_start = page_num * FILES_PER_PAGE;

	FRESULT err;
	DIR dir;
	FILINFO fno;

	TCHAR* pattern = "*";
	err = f_findfirst(&dir, &fno, "/", pattern);

	if (!err){
		if (*fno.fname) {
			// First loop to advance file browse until the beginning of the requested page, if not requesting the first page
			if (page_num > 0) {
				int discarded_filename_num = 0;
				do {
					// count if the file is supported
					if (is_supported_file(fno.fname, strlen(fno.fname))) {
						discarded_filename_num++;
						// if the requested page's start index corresponds to the skipped files, leave
						// so that the next file browse advancement is a wanted file
						//if (page_start == discarded_filename_num) break;
					}

					// get next entry
					err = f_findnext(&dir, &fno);
				} while (*fno.fname && !err && page_start != discarded_filename_num);

				if (err) {
					filenames->size = 0;
					printf("Error when finding entry, first loop in list: 0x%02X\r\n", err);
					return;
				}

				// if the loop stopped due to no more files to list, then the page requested does not exist
				if (!*fno.fname) {
					filenames->size = 0;
					printf("Out of bounds...\r\n");
					return;
				}
			}

			// Second loop, saving the 16 supported files to the FILENAMES struct
			do {
				char name[FILENAME_LEN];
				int len = strlen(fno.fname);
				// If the file is supported, save it
				if (is_supported_file(fno.fname, len)) {
					if (len > FILENAME_LEN) {
						len = FILENAME_LEN;
					}
					strncpy(name, fno.fname, len);
					// adding 0x80 to last char of string as a final byte (spectrum uses this in string tables)
					name[len-1] += 0x80;
					name[len] = '\0';

					// add the filename to the list
					memcpy(filenames->filenames + (filename_num * FILENAME_LEN), name, len+1);
					//snprintf(filenames->filenames[filename_num * FILENAME_LEN], len+1, name);
					filename_num++;

					// if all 16 filenames have been saved, leave
					if (filename_num == FILES_PER_PAGE) break;
				}

				// get next entry
				err = f_findnext(&dir, &fno);
			} while(*fno.fname && !err);

			if (err) {
				printf("Error when finding entry, second loop in list: 0x%02X\r\n", err);
				return;
			}
			filenames->size = filename_num;
			//filenames->filenames = (char**) realloc(filenames.filenames, filenames.size*sizeof(char*));

			return;
		}

		// if the first entry did not have a name
		printf("No files... list files\r\n");
		filenames->size = 0;
		return;

	}

	// if the first entry finding resulted in error
	printf("Listing files failed...\r\n");
	filenames->size = 0;
	return;
}

/**
 * Checks all the supported file's names and keeps track of the last save state
 * Receives the filename of the selected file and its length up to the name.
 */
int get_save_num(char* filename, int* len) {
	// false if no game was selected (length = 0)
	if (*len) {
		printf("NAME: %s\r\n", filename);
		printf("NAME LEN: %d\r\n", *len);
	} else {
		//curr_game_filename = "save";
		filename[0] = 's';
		filename[1] = 'a';
		filename[2] = 'v';
		filename[3] = 'e';
		filename[4] = '\0';
		*len = 4;
	}

	int curr_save_num = -1;
	// checking for save state tag to ajust the length
	if (*len > 3 && filename[(*len)-3] == '_') {
		curr_save_num = string_to_num(filename, *len, 2);
		*len -= 3; // updating length for the save state tag not to appear
		printf("CURR_SAVE_NUM: %02d\r\n", curr_save_num);
	}

	FRESULT err;
	DIR dir;
	FILINFO fno;

	TCHAR* pattern = "*";
	err = f_findfirst(&dir, &fno, "/", pattern);
	if (!err) {
		if (*fno.fname) {
			do {
				// For every supported file
				if (is_supported_file(fno.fname, strlen(fno.fname))) {
					// if the filename is the same (without counting the _xx or extension) and the _ is present
					if (
						strncmp(filename, fno.fname, *len) == 0 &&
						(fno.fname[*len]) == '_'
					) {
						// obtain the number of that save state and save it if it is higher
						int next_num = string_to_num(fno.fname, (*len)+3, 2);
						if (next_num > curr_save_num) curr_save_num = next_num;
					}
				}
				err = f_findnext(&dir, &fno);
			} while (*fno.fname && !err);

			if (err) {
				printf("Error when finding another entry: 0x%02X\r\n", err);
				return -1;
			}

			// return the highest save state number +1 for the current number
			curr_save_num++;
			// if it reaches 100 or more, use 0
			if (curr_save_num > 99) curr_save_num = 0;
			return curr_save_num;
		}

	}

	//curr_save_num ++;
	//return curr_save_num;
	printf("find first bad 0x%02X\r\n", err);
	return -1;
}

void print_filenames(FILENAMES* files) {
	int filename;
	size_t entries_left = files->size;
	size_t files_in_page = FILES_PER_PAGE;

	if (entries_left < files_in_page) {
		files_in_page = entries_left;
	}

	for (filename = 0; filename < files_in_page; filename++) {
		printf("\t[%d]: %s\r\n", filename, files->filenames + (filename * FILENAME_LEN));
	}
}

FRESULT init_file_read(char* filename) {
	return f_open(&fil, filename, FA_READ);
}

FRESULT init_file_write_create(char* filename) {
	return f_open(&fil, filename, FA_WRITE | FA_CREATE_ALWAYS);
}

FRESULT init_file_write_open(char* filename) {
	return f_open(&fil, filename, FA_WRITE | FA_OPEN_ALWAYS);
}

FRESULT file_read(alt_u8* buffer, unsigned int len, unsigned int* bytes_read) {
	return f_read(&fil, buffer, len, bytes_read);
}

FRESULT file_write(alt_u8* buffer, unsigned int len, unsigned int* bytes_written) {
	return f_write(&fil, buffer, len, bytes_written);
}

int file_size(void) {
	return f_size(&fil);
}

void close_file(void) {
	f_close(&fil);
}

void close_sd(void) {
	//free(fs);
}

