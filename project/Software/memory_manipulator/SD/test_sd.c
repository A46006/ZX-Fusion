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
	print_filenames(names, TRUE);

	names = list_files_of_page(1);
	print_filenames(names, TRUE);

	names = list_files_of_page(2);
	print_filenames(names, TRUE);
	*/
	FRESULT err;

	err = init_file_write("test.txt");
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
