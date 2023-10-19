#include ".\terasic_fat\FatFileSystem.h"
#include "..\terasic_lib\terasic_includes.h"

#define FILENAME_NUM 50
#define FILENAME_LEN_SD 50
#define FILENAME_LEN 32
#define FILES_PER_PAGE 16

typedef struct {
	size_t size;
	char ** filenames;
} FILENAMES;

FAT_HANDLE init_SD();
bool is_supported_file(char* filename, size_t len);
int format_file_name(FAT_BROWSE_HANDLE hBrowse, FILE_CONTEXT FileContext, char* name);

FILENAMES list_files(FAT_HANDLE hFat);
int num_of_pages(FAT_HANDLE hFat);
FILENAMES list_files_of_page(FAT_HANDLE hFat, int page_num);

void close_SD(FAT_HANDLE hFat);

void print_filenames(FILENAMES files, bool free_en);

FAT_FILE_HANDLE init_file(FAT_HANDLE hFat, const char *pFilename);
//alt_u8* get_file_data_block512(FAT_FILE_HANDLE hFile);
void close_file(FAT_FILE_HANDLE hFile);
