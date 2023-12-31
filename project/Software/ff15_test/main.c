#include ".\ff15\ff.h"
#include ".\terasic_lib\terasic_includes.h"

#define FILENAME_NUM 50
#define FILENAME_LEN_SD 50
#define FILENAME_LEN 32
#define FILES_PER_PAGE 16

typedef struct {
	size_t size;
	char ** filenames;
} FILENAMES;

const char* SUPPORTED_EXTENSIONS[2] = {".z80", ".sna"};
#define N_SUPPORTED_EXTENSIONS (sizeof SUPPORTED_EXTENSIONS / sizeof (const char*))

/*FATFS* init_SD() {
	FATFS* fs;

	fs = malloc(sizeof (FATFS)); 	// Get work area for the volume
	f_mount(fs, "", 0);			// Mount the default drive
	return fs;
}
 */
FATFS* fs;
void init_SD() {
	fs = malloc(sizeof(FATFS));
	f_mount(fs, "", 0);
}

/**
 * Checks input file's extension and compares it to supported ones
 */
bool is_supported_file(char* filename, size_t len) {
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

void free_file_list(FILENAMES filenames) {
	for (int i = 0; i < FILES_PER_PAGE; i++)
		free(filenames.filenames[i]);
	free(filenames.filenames);
	filenames.size = 0;
	filenames.filenames = NULL;
}

FILENAMES list_files_of_page(int page_num) {
	// allocate space for FILENAME_NUM file names
	FILENAMES filenames = {0, NULL};
	filenames.filenames = (char**) malloc(FILES_PER_PAGE*sizeof(char*));
	for (int i = 0; i < FILES_PER_PAGE; i++) {
		// allocating 50 chars for each file_name
		filenames.filenames[i] = (char*)malloc(FILENAME_LEN_SD*sizeof(char));
	}

	int filename_num = 0;
	int page_start = page_num * FILES_PER_PAGE;

	bool bSuccess;
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
						if (page_start == discarded_filename_num) break;
					}

					// get next entry
					err = f_findnext(&dir, &fno);
				} while (*fno.fname && !err);

				if (err) {
					free_file_list(filenames);
					printf("Error when finding entry, first loop in list: 0x%02X\r\n", err);
					return filenames;
				}

				// if the loop stopped due to no more files to list, then the page requested does not exist
				if (!*fno.fname) {
					free_file_list(filenames);
					printf("Out of bounds...\r\n");
					return filenames;
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

					// add the filename to the list
					snprintf(filenames.filenames[filename_num], len, name);
					filename_num++;

					// if all 16 filenames have been saved, leave
					if (filename_num == FILES_PER_PAGE) break;
				}

				// get next entry
				err = f_findnext(&dir, &fno);
			} while(*fno.fname && !err);

			if (err) {
				free_file_list(filenames);
				printf("Error when finding entry, second loop in list: 0x%02X\r\n", err);
				return filenames;
			}
			filenames.size = filename_num;
			filenames.filenames = (char**) realloc(filenames.filenames, filenames.size*sizeof(char*));

			return filenames;
		}

		// if the first entry did not have a name
		free_file_list(filenames);
		printf("No files... list files\r\n");
		return filenames;

	}

	// if the first entry finding resulted in error
	printf("Listing files failed...\r\n");
	free_file_list(filenames);
	return filenames;
}

void print_filenames(FILENAMES files, bool free_en) {
	int page, filename;
	size_t page_max = (files.size + (FILES_PER_PAGE-1)) / FILES_PER_PAGE;
	size_t entries_left = files.size;
	size_t files_in_page = FILES_PER_PAGE;

	for (page = 0; page < page_max; page++) {
		printf("Page %d:\r\n", page);

		if (entries_left < files_in_page) {
			files_in_page = entries_left;
		}

		for (filename = 0; filename < files_in_page; filename++) {
			int idx = (page*FILES_PER_PAGE) + filename;
			printf("\t[%d]: %s\r\n", filename, files.filenames[idx]);
			if (free_en)
				free(files.filenames[idx]);
		}
		entries_left -= FILES_PER_PAGE;
	}
	if (free_en)
		free(files.filenames);
}

/*
FRESULT init_file_read(FIL* fil, char* filename) {
	return f_open(fil, filename, FA_READ);
}

FRESULT init_file_write(FIL* fil, char* filename) {
	return f_open(fil, filename, FA_WRITE | FA_CREATE_ALWAYS);
}

FRESULT file_read(FIL* fil, alt_u8* buffer, int len, int* bytes_read) {
	return f_read(fil, buffer, len, bytes_read);
}

FRESULT file_write(FIL* fil, alt_u8* buffer, int len, int* bytes_written) {
	return f_write(fil, buffer, len, bytes_written);
}

void close_file(FIL* fil) {
	f_close(fil);
}
*/
FIL fil;

FRESULT init_file_read(char* filename) {
	return f_open(&fil, filename, FA_READ);
}

FRESULT init_file_write_create(char* filename) {
	return f_open(&fil, filename, FA_WRITE | FA_CREATE_ALWAYS);
}

FRESULT init_file_write_open(char* filename) {
	return f_open(&fil, filename, FA_WRITE | FA_OPEN_ALWAYS);
}

FRESULT file_read(alt_u8* buffer, int len, int* bytes_read) {
	return f_read(&fil, buffer, len, bytes_read);
}

FRESULT file_write(alt_u8* buffer, int len, int* bytes_written) {
	return f_write(&fil, buffer, len, bytes_written);
}

void close_file(void) {
	f_close(&fil);
}

void close_sd(void) {
	free(fs);
}

int file_size(void) {
	return f_size(&fil);
}

int create_file(char* filename) {
	/////////////// TEST.TXT CREATION AND POPULATION ////////////////////////
	FRESULT err;
	int len = 512;
	alt_u8 buffer[len];

	err = init_file_write_create(filename);
	if (err) {
		printf("open to write test.txt FAILED: %d\r\n", err);
		close_sd();
		return -1;
	}
	int bytes_read;

	printf("test.txt opened/created\r\n");

	for (int i = 0; i < len; i++) {
		buffer[i] = 0xAA;
	}

	int bytes_written;
	err = file_write(buffer, len, &bytes_written);
	if (err) {
		printf("err write1: %d\r\n", err);
	}
	printf("bytes written 1: %d\r\n", bytes_written);

	for (int i = 0; i < len; i++) {
		buffer[i] = 0x55;
	}

	err = file_write(buffer, len, &bytes_written);
	if (err) {
		printf("err write2: %d\r\n", err);
	}
	printf("bytes written 2: %d\r\n", bytes_written);

	close_file();
	printf("write done\r\n");
	return 0;
}

int read_file(char* filename) {
	////////////////////// TEST.TXT READ BACK ///////////////////////
	FRESULT err;
	int len = 512;
	alt_u8 buffer[len];
	int bytes_read;

	err = init_file_read(filename);
	if (err) {
		printf("open to read test.txt FAILED: %d\r\n", err);
		close_sd();
		return -1;
	}
	printf("test.txt opened to read\r\n");

	int size = file_size();
	printf("text.txt size: %d bytes\r\n");

	int bytes_to_read = len;
	while(1) {
		if (bytes_to_read > size) {
			bytes_to_read = size;
		}

		err = file_read(buffer, bytes_to_read, &bytes_read);
		if (err) {
			printf("err: %d\r\n", err);
			break;
		}
		printf("\r\n bytes_read: %d\r\n", bytes_read);
		if (bytes_read == 0) break;
		for (int i = 0; i < len; i++) {
			if (i % 16 == 0) printf("\r\n");
			printf("%02X ", buffer[i]);
		}
		size -= len;
		//printf("%s\r\n", buffer);
		//printf("\r\n");
	}
	close_file();
	return 0;
}

int replace_file_first_sec(char* filename) {
	/////////////// TEST.TXT CREATION AND POPULATION ////////////////////////
	FRESULT err;
	int len = 512;
	alt_u8 buffer[len];

	err = init_file_write_open(filename);
	if (err) {
		printf("open to write test.txt FAILED: %d\r\n", err);
		close_sd();
		return -1;
	}
	int bytes_read;

	printf("test.txt opened/created\r\n");

	for (int i = 0; i < len; i++) {
		buffer[i] = 0xDE;
	}

	int bytes_written;
	err = file_write(buffer, len, &bytes_written);
	if (err) {
		printf("err write1: %d\r\n", err);
	}

	close_file();
	printf("write done\r\n");
	return 0;
}

int main () {
	init_SD();
	printf("MOUNTED\r\n");

	printf("Displaying number of pages of .z80 and .sna files:\r\n");

	int pages = num_of_pages();
	printf("num of pages: %d\r\n", pages);

	printf("Listing each page of .z80 and .sna files:\r\n");

	FILENAMES names;
	names = list_files_of_page(0);
	print_filenames(names, TRUE);

	names = list_files_of_page(1);
	print_filenames(names, TRUE);

	names = list_files_of_page(2);
	print_filenames(names, TRUE);

	char* filename = "test.txt";

	int e = create_file(filename);
	if (e) return e;
	printf("created and written\r\n");

	e = read_file(filename);
	if (e) return e;
	printf("\r\nread\r\n");

	e = replace_file_first_sec(filename);
	if (e) return e;
	printf("replace first sec done\r\n");

	e = read_file(filename);
	if (e) return e;
	printf("\r\nread\r\n");

	// a.txt has "Sup world!!!!"
	/*
	FIL fil;
	unsigned char buf[512];


	int size = f_size(&fil);
	printf("SIZE of a.txt: %d\r\n", size);
	int bytes_read;
	while(1) {
		err = f_read(&fil, buf, size, &bytes_read);
		if (err) {
			printf("err: %d\r\n", err);
			break;
		}
		printf("\r\n bytes_read: %d\r\n", bytes_read);
		if (bytes_read == 0) break;
		printf(buf);
		printf("\r\n");
	}
	f_close(&fil);

	printf("a.txt closed\r\n");


	// lets create counting_test_ff15.bin
	err = f_open(&fil, "date_test.bin", FA_WRITE | FA_CREATE_ALWAYS);
	if (err) {
		printf("open to create counting_test_ff15.bin FAILED: %d\r\n", err);
		free(fs);
		return -1;
	}
	printf("counting_test_ff15 opened\r\n");

	// write first 512 bytes as AA
	for (int i = 0; i < sizeof(buf); i++) {
		buf[i] = 0x55;
	}
	int bytes_written;
	err = f_write(&fil, buf, sizeof(buf), &bytes_written);
	if (err) {
		printf("err write1: %d\r\n", err);
	}

	// write second 512 bytes as 55
	for (int i = 0; i < sizeof(buf); i++) {
		buf[i] = 0xAB;
	}
	err = f_write(&fil, buf, sizeof(buf), &bytes_written);
	if (err) {
		printf("err write1: %d\r\n", err);
	}

	f_close(&fil);
	printf("write done\r\n");

	// verify
	err = f_open(&fil, "counting_test_ff15.bin", FA_READ);
	if (err) {
		printf("open to read counting_test_ff15.bin FAILED: %d\r\n", err);
		free(fs);
		return -1;
	}

	int bytes_read;
	while(1) {
		err = f_read(&fil, buf, sizeof(buf), &bytes_read);
		if (err) {
			printf("err: %d\r\n", err);
			break;
		}
		printf("\r\n bytes_read: %d\r\n", bytes_read);
		if (bytes_read == 0) break;
		for (int i = 0; i < sizeof(buf); i++) {
			if (i % 16 == 0) printf("\r\n");
			printf("%02X ", buf[i]);
		}
		printf("\r\n");
	}
	f_close(&fil);
	*/
	printf("END");
	close_sd();
	return 0;
}
