#include ".\ff15\ff.h"

#include "..\terasic_lib\terasic_includes.h"

#define FILENAME_NUM 50
#define FILENAME_LEN_SD 33
#define FILENAME_LEN 33
#define FILES_PER_PAGE 16

typedef struct {
	size_t size;
	char filenames[FILES_PER_PAGE * FILENAME_LEN];
} FILENAMES;

//SD_DRIVER init_SD(SM_VOLUME_MOUNTED_CALLBACK volume_mounted_callback);
int init_SD(void);
bool is_supported_file(char* filename, size_t len);

int num_of_pages(void);
void list_files_of_page(FILENAMES* filenames, int page_num);
int get_save_num(char* filename, int* len);
void free_file_list(FILENAMES* filenames);


void print_filenames(FILENAMES* files);

FRESULT init_file_read(char* filename);
FRESULT init_file_write_create(char* filename);
FRESULT init_file_write_open(char* filename);
FRESULT file_read(alt_u8* buffer, unsigned int len, unsigned int* bytes_read);
FRESULT file_write(alt_u8* buffer, unsigned int len, unsigned int* bytes_written);
int file_size(void);
void close_file(void);
void close_sd(void);
