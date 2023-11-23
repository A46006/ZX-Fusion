#include ".\sd_if.h"
#include "..\terasic_lib\terasic_includes.h"

int test_sd () {
	init_SD();
	printf("MOUNTED\r\n");

	printf("Displaying number of pages of .z80 and .sna files:\r\n");

	int pages = num_of_pages();
	printf("num of pages: %d\r\n", pages);

	/*printf("Listing each page of .z80 and .sna files:\r\n");

	FILENAMES names;
	names = list_files_of_page(0);
	print_filenames(names);

	names = list_files_of_page(1);
	print_filenames(names);

	names = list_files_of_page(2);
	print_filenames(names);
	*/
	FRESULT err;

	err = init_file_write_create("test.txt");
	if (err) {
		printf("open to write test.txt FAILED: %d\r\n", err);
		close_sd();
		return -1;
	}
	int bytes_read;
	char* buffer = "Hello World!";

	printf("test.txt opened/created\r\n");

	int bytes_written;
	err = file_write(buffer, strlen(buffer), &bytes_written);
	if (err) {
		printf("err write1: %d\r\n", err);
	}

	close_file();
	printf("write done\r\n");


	memset(buffer, 0, strlen(buffer));

	err = init_file_read("test.txt");
	if (err) {
		printf("open to read test.txt FAILED: %d\r\n", err);
		close_sd();
		return -1;
	}
	printf("test.txt opened to read\r\n");

	int size = file_size();
	printf("text.txt size: %d bytes\r\n");

	while(1) {
		err = file_read(buffer, size, &bytes_read);
		if (err) {
			printf("err: %d\r\n", err);
			break;
		}
		printf("\r\n bytes_read: %d\r\n", bytes_read);
		if (bytes_read == 0) break;
		printf("%s\r\n", buffer);
		printf("\r\n");
	}
	close_file();

	printf("END");
	close_sd();
	return 0;
}
