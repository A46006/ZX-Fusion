#include <stdio.h>
#include "./sd_if.h"

const char* SUPPORTED_EXTENSIONS[2] = {".z80", ".sna"};
#define N_SUPPORTED_EXTENSIONS (sizeof SUPPORTED_EXTENSIONS / sizeof (const char *))


FAT_HANDLE init_SD() {
	return Fat_Mount(FAT_SD_CARD, 0);
}

/**
 * Checks input file's extension and compares it to supported ones
 */
bool is_supported_file(char* filename, size_t len) {
	// Making extensions lower case for comparisons
	char to_compare[FILENAME_LEN_SD];
	strncpy(to_compare, filename, len);
	for(int i = 1; i < 5; i++) {
		to_compare[len-i] = tolower(filename[len-i]);
	}

	char* extension = to_compare + (len-5);
	for (int i = 0; i < N_SUPPORTED_EXTENSIONS; i++) {
		if (strncmp(extension, SUPPORTED_EXTENSIONS[i], 4) == 0) {
			return TRUE;
		}
	}
	return FALSE;
}

int format_file_name(FAT_BROWSE_HANDLE hBrowse, FILE_CONTEXT FileContext, char* name) {
	int len = 0;
	//if (page_num == 1) entries = {0};

	if (FileContext.bLongFilename){

		alt_u16 *pData16;
		alt_u8 *pData8;
		pData16 = (alt_u16 *)FileContext.szName;
		pData8 = FileContext.szName;

		//printf("[%d]", nCount);
		while(*pData16 && len < FILENAME_LEN){
			if (*pData8)
				name[len++] = *pData8;
			pData8++;
			if (*pData8)
				name[len++] = *pData8;
			pData8++;
			//
			pData16++;
		}
		name[len++] = '\0';
	}else {
		len = strlen(FileContext.szName);
		name[len++] = '\0';
		strncpy(name, FileContext.szName, len);
	}
	return len;
}

FILENAMES list_files(FAT_HANDLE hFat) {
	// allocate space for FILENAME_NUM file names
	FILENAMES filenames = {0, NULL};
	filenames.filenames = (char**) malloc(FILENAME_NUM*sizeof(char*));
	for (int i = 0; i < FILENAME_NUM; i++) {
		// allocating 50 chars for each file_name
		filenames.filenames[i] = (char*)malloc(FILENAME_LEN_SD*sizeof(char));
	}
	int filename_num = 0;

	bool bSuccess;
	FAT_BROWSE_HANDLE hBrowse;
	FILE_CONTEXT FileContext;

	bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);

	if (bSuccess){
		while(Fat_FileBrowseNext(&hBrowse, &FileContext)) {
			char name[FILENAME_LEN];
			//char *name = (char *) malloc(51);

			int len = format_file_name(hBrowse, FileContext, name);

			// Skip unsupported files
			if (!is_supported_file(name, len)) {
				continue;
			}

			if (len > FILENAME_LEN) {
				len = FILENAME_LEN;
			}

			// adding 0x80 to last char of string as a final byte (spectrum uses this in string tables)
			name[len-2] += 0x80;

			snprintf(filenames.filenames[filename_num], len, name);
			filename_num++;
		}
		filenames.size = filename_num;
		filenames.filenames = (char**) realloc(filenames.filenames, filenames.size*sizeof(char*));

		return filenames;
	}

	printf("Listing files failed somehow...\r\n");
	for(int i = 0; i < FILENAME_NUM; i++) {
		free(filenames.filenames[i]);
	}
	free(filenames.filenames);

	filenames.size = 0;
	filenames.filenames = NULL;
	return filenames;
}

int num_of_pages(FAT_HANDLE hFat) {
	int num_of_files = 0;
	bool bSuccess;
	FAT_BROWSE_HANDLE hBrowse;
	FILE_CONTEXT FileContext;

	bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);

	if (bSuccess){
		while(Fat_FileBrowseNext(&hBrowse, &FileContext)) {
			char name[FILENAME_LEN];
			int len = format_file_name(hBrowse, FileContext, name);

			// Skip unsupported files
			if (!is_supported_file(name, len)) {
				continue;
			}
			num_of_files++;
		}
		return ((num_of_files-1) / 16 ) + 1;
	}

	printf("Counting pages went wrong...");
	return -1;
}

FILENAMES list_files_of_page(FAT_HANDLE hFat, int page_num) {
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
	FAT_BROWSE_HANDLE hBrowse;
	FILE_CONTEXT FileContext;

	bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);

	if (bSuccess){
		// First loop to advance file browse until the beginning of the requested page, if not requesting the first page
		if (page_num > 0) {
			int discarded_filename_num = 0;
			while(Fat_FileBrowseNext(&hBrowse, &FileContext)) {
				char name[FILENAME_LEN];
				int len = format_file_name(hBrowse, FileContext, name);
				// Skip unsupported files in the counting
				if (!is_supported_file(name, len)) {
					continue;
				}
				discarded_filename_num++;

				// if the requested page's start index corresponds to the skipped files, leave
				// so that the next file browse advancement is a wanted file
				if (page_start == discarded_filename_num) break;
			}
		}

		// Second loop, saving the 16 supported files to the FILENAMES struct
		while(Fat_FileBrowseNext(&hBrowse, &FileContext)) {
			char name[FILENAME_LEN];
			int len = format_file_name(hBrowse, FileContext, name);

			// Skip unsupported files
			if (!is_supported_file(name, len)) {
				continue;
			}

			if (len > FILENAME_LEN) {
				len = FILENAME_LEN;
			}

			// adding 0x80 to last char of string as a final byte (spectrum uses this in string tables)
			name[len-2] += 0x80;

			snprintf(filenames.filenames[filename_num], len, name);
			filename_num++;
			if (filename_num == FILES_PER_PAGE) break;
		}
		filenames.size = filename_num;
		filenames.filenames = (char**) realloc(filenames.filenames, filenames.size*sizeof(char*));

		return filenames;
	}

	printf("Listing files failed somehow...\r\n");
	for(int i = 0; i < FILES_PER_PAGE; i++) {
		free(filenames.filenames[i]);
	}
	free(filenames.filenames);

	filenames.size = 0;
	filenames.filenames = NULL;
	return filenames;
}


void close_SD(FAT_HANDLE hFat) {
	Fat_Unmount(hFat);
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


FAT_FILE_HANDLE init_file(FAT_HANDLE hFat, const char *pFilename) {
	return Fat_FileOpen(hFat, pFilename);
}

void close_file(FAT_FILE_HANDLE hFile) {
	Fat_FileClose(hFile);
}
