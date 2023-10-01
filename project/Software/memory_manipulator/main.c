#include <stdio.h>
//#include ".\SD\test_sd.c"
#include ".\file_format_reader\formats.h"
#include ".\file_format_reader\asm_opcodes.h"
#include ".\spectrum_comm\Peripheral_Interfaces\per_hal.h"
//#include ".\file_format_reader\file_format_aux.h"

#define PAGE_DATA_ADDR 0xC000
#define MENU_CODE_ADDR 0xB000

#define PAGES_LEFT_ADDR 0xEC09
#define PAGE_MENU_TYPE_ADDR 0xEC0A
#define CURR_MENU_PAGE_ADDR 0xEC0B
#define MENU_IDX_ADDR 0xEC0C
#define EDITOR_FLAGS_ADDR 0xEC0D

#define MENU_CODE_LEN 1170

const alt_u8 menu_code[MENU_CODE_LEN] = {
	0xFB, 0xFD, 0xCB, 0x02, 0xEE, 0x21, 0x00, 0x00, 0x22, 0x00, 0x40, 0xCD,
	0x11, 0xB0, 0xC3, 0x72, 0xB0, 0xCD, 0x35, 0xB0, 0x21, 0x00, 0x00, 0x22,
	0x9A, 0xFC, 0x3E, 0x82, 0x32, 0x0D, 0xEC, 0x21, 0x00, 0x00, 0x22, 0x49,
	0x5C, 0xCD, 0x2C, 0xB0, 0xCD, 0xE7, 0xB3, 0xC9, 0x21, 0x88, 0xB4, 0x11,
	0x6A, 0xFD, 0xC3, 0x67, 0xB0, 0xCD, 0x59, 0xB0, 0xCD, 0x47, 0xB0, 0xC3,
	0x3E, 0xB0, 0x21, 0x8B, 0xB4, 0x11, 0xEE, 0xF6, 0xC3, 0x67, 0xB0, 0xDD,
	0x21, 0x6C, 0xFD, 0x21, 0x76, 0xB4, 0x18, 0x03, 0x21, 0x7F, 0xB4, 0x11,
	0x6C, 0xFD, 0xC3, 0x67, 0xB0, 0x21, 0x3C, 0x5C, 0xCB, 0x86, 0x21, 0x70,
	0xB0, 0x11, 0x15, 0xEC, 0xC3, 0x67, 0xB0, 0x46, 0x23, 0x7E, 0x12, 0x13,
	0x23, 0x10, 0xFA, 0xC9, 0x01, 0x14, 0x21, 0x6F, 0xB1, 0x22, 0xEA, 0xF6,
	0x21, 0x79, 0xB1, 0x22, 0xEC, 0xF6, 0xE5, 0x21, 0x0D, 0xEC, 0xCB, 0xCE,
	0xCB, 0xA6, 0x2B, 0x36, 0x00, 0xE1, 0xCD, 0xA9, 0xB0, 0xC3, 0x90, 0xB0,
	0x31, 0xFF, 0xEB, 0xCD, 0xF1, 0xB3, 0xCD, 0xBE, 0xB3, 0xF5, 0x3A, 0x39,
	0x5C, 0xCD, 0xB0, 0xB3, 0xF1, 0x21, 0x5C, 0xB1, 0xCD, 0x22, 0xB3, 0x18,
	0xE7, 0x5E, 0x23, 0xE5, 0x21, 0x98, 0xB1, 0xCD, 0x6E, 0xB4, 0xE1, 0xCD,
	0x6E, 0xB4, 0xE5, 0xCD, 0x08, 0xB4, 0x21, 0xA6, 0xB1, 0xCD, 0x6E, 0xB4,
	0xE1, 0xD5, 0x01, 0x09, 0x0B, 0xCD, 0x66, 0xB4, 0xC5, 0x06, 0x0C, 0x3E,
	0x20, 0xD7, 0x7E, 0x23, 0xFE, 0x80, 0x30, 0x03, 0xD7, 0x10, 0xF7, 0xE6,
	0x7F, 0xD7, 0x3E, 0x20, 0xD7, 0x10, 0xFB, 0xC1, 0x04, 0xCD, 0x66, 0xB4,
	0x1D, 0x20, 0xE1, 0x21, 0x48, 0x57, 0xD1, 0xCB, 0x23, 0xCB, 0x23, 0xCB,
	0x23, 0x53, 0x15, 0x1E, 0x6F, 0x01, 0x00, 0xFF, 0x7A, 0xCD, 0x12, 0xB1,
	0x01, 0x01, 0x00, 0x7B, 0xCD, 0x12, 0xB1, 0x01, 0x00, 0x01, 0x7A, 0x3C,
	0xCD, 0x12, 0xB1, 0xAF, 0x0E, 0x00, 0xCD, 0x37, 0xB3, 0xC9, 0xF5, 0xE5,
	0xD5, 0xC5, 0x44, 0x4D, 0xCD, 0xE9, 0x22, 0xC1, 0xD1, 0xE1, 0xF1, 0x09,
	0x3D, 0x20, 0xEF, 0xC9, 0xF3, 0x3E, 0x00, 0xDB, 0x1B, 0x76, 0xFB, 0xC3,
	0xAE, 0xB1, 0x21, 0xFF, 0xFF, 0xCB, 0xC6, 0xC3, 0xB7, 0x11, 0x21, 0x0D,
	0xEC, 0xCB, 0x8E, 0x2B, 0x7E, 0x2A, 0xEA, 0xF6, 0xCD, 0x8F, 0xB3, 0xC9,
	0x37, 0x18, 0x01, 0xA7, 0x21, 0x0C, 0xEC, 0x7E, 0xE5, 0x2A, 0xEC, 0xF6,
	0x0E, 0x00, 0xDC, 0x6C, 0xB3, 0xD4, 0x7B, 0xB3, 0xE1, 0x77, 0x37, 0xC9,
	0x06, 0x0B, 0x44, 0xB1, 0x39, 0x44, 0xB1, 0x0A, 0x47, 0xB1, 0x38, 0x47,
	0xB1, 0x0D, 0x36, 0xB1, 0x30, 0x36, 0xB1, 0x03, 0x00, 0x24, 0xB1, 0x01,
	0x2E, 0xB1, 0x02, 0x2E, 0xB1, 0x04, 0x46, 0x75, 0x73, 0x69, 0x6F, 0x6E,
	0x20, 0x20, 0xFF, 0x53, 0x44, 0x20, 0x4C, 0x6F, 0x61, 0x64, 0x65, 0xF2,
	0x4F, 0x6E, 0x6C, 0x69, 0x6E, 0xE5, 0x42, 0x41, 0x53, 0x49, 0xC3, 0xA0,
	0x16, 0x0A, 0x09, 0x15, 0x00, 0x14, 0x00, 0x10, 0x07, 0x11, 0x00, 0x13,
	0x01, 0xFF, 0x11, 0x00, 0x20, 0x11, 0x07, 0x10, 0x00, 0xFF, 0x21, 0x00,
	0xC0, 0x22, 0xEC, 0xF6, 0xE5, 0x21, 0x0D, 0xEC, 0xCB, 0xCE, 0xCB, 0xA6,
	0x2B, 0x36, 0x00, 0x2B, 0x36, 0x00, 0x21, 0x00, 0x00, 0x22, 0x00, 0x40,
	0xE1, 0xCD, 0x19, 0xB2, 0xC3, 0xCF, 0xB1, 0x31, 0xFF, 0xEB, 0xCD, 0xF1,
	0xB3, 0xCD, 0xBE, 0xB3, 0xF5, 0x3A, 0x39, 0x5C, 0xCD, 0xB0, 0xB3, 0xF1,
	0x21, 0xF7, 0xB2, 0xCD, 0x22, 0xB3, 0x18, 0xE7, 0x57, 0xD5, 0xCD, 0x66,
	0xB4, 0xE5, 0x21, 0x16, 0xB3, 0xCD, 0x6E, 0xB4, 0xE1, 0xD1, 0x06, 0x1F,
	0xAF, 0xBA, 0xD5, 0x28, 0x02, 0x06, 0x1A, 0x7E, 0x23, 0xFE, 0xFF, 0x28,
	0x03, 0xD7, 0x10, 0xF7, 0x3E, 0x20, 0xD7, 0x10, 0xFB, 0xD1, 0xAF, 0xBA,
	0x28, 0x06, 0xCD, 0x08, 0xB4, 0x3E, 0x20, 0xD7, 0xC9, 0x5E, 0x23, 0x1D,
	0x3E, 0x10, 0x93, 0x57, 0x01, 0x00, 0x03, 0x3E, 0x01, 0xD5, 0xCD, 0xE8,
	0xB1, 0xE5, 0x21, 0xA6, 0xB1, 0xCD, 0x6E, 0xB4, 0xE1, 0x01, 0x00, 0x04,
	0xCD, 0x66, 0xB4, 0xC5, 0x06, 0x1F, 0x7E, 0x23, 0xFE, 0x80, 0x30, 0x03,
	0xD7, 0x10, 0xF7, 0xE6, 0x7F, 0xD7, 0x3E, 0x20, 0xD7, 0x10, 0xFB, 0xC1,
	0x04, 0xCD, 0x66, 0xB4, 0x1D, 0x20, 0xE4, 0xD1, 0xAF, 0xBA, 0x28, 0x10,
	0xC5, 0x06, 0x1F, 0x3E, 0x20, 0xD7, 0x10, 0xFB, 0xC1, 0x04, 0xCD, 0x66,
	0xB4, 0x15, 0x20, 0xF0, 0xE5, 0x21, 0x16, 0xB3, 0xCD, 0x6E, 0xB4, 0xE1,
	0x01, 0x00, 0x14, 0xAF, 0xCD, 0xE8, 0xB1, 0xAF, 0x0E, 0x01, 0xCD, 0x37,
	0xB3, 0xC9, 0xF3, 0x21, 0x0C, 0xEC, 0x46, 0x0E, 0x1B, 0x3A, 0x0A, 0xEC,
	0xA7, 0x28, 0x02, 0x0E, 0x1D, 0x78, 0x2B, 0x46, 0xED, 0x79, 0x31, 0xFF,
	0x57, 0x76, 0x37, 0x18, 0x01, 0xA7, 0x21, 0x0C, 0xEC, 0x7E, 0xE5, 0x2A,
	0xEC, 0xF6, 0x0E, 0x01, 0xDC, 0x6C, 0xB3, 0xD4, 0x7B, 0xB3, 0xE1, 0x77,
	0x37, 0xC9, 0x21, 0x09, 0xEC, 0x7E, 0xC6, 0x00, 0x28, 0x08, 0x21, 0x0B,
	0xEC, 0x7E, 0x3C, 0x77, 0x18, 0x0C, 0xC9, 0x21, 0x0B, 0xEC, 0x7E, 0xFE,
	0x00, 0x20, 0x01, 0xC9, 0x3D, 0x77, 0x77, 0x23, 0xF5, 0x7E, 0x0E, 0x01,
	0xCD, 0x37, 0xB3, 0x36, 0x00, 0xAF, 0xCD, 0x37, 0xB3, 0xF1, 0x47, 0x0E,
	0x1B, 0x21, 0x0A, 0xEC, 0xCB, 0x46, 0x28, 0x02, 0x0E, 0x1D, 0xF3, 0xED,
	0x78, 0x76, 0xFB, 0x21, 0x00, 0x00, 0x22, 0x00, 0x40, 0x2A, 0xEC, 0xF6,
	0xC3, 0xC9, 0xB1, 0x0A, 0x0B, 0x96, 0xB2, 0x39, 0x96, 0xB2, 0x0A, 0x99,
	0xB2, 0x38, 0x99, 0xB2, 0x09, 0xAE, 0xB2, 0x37, 0xAE, 0xB2, 0x08, 0xBF,
	0xB2, 0x36, 0xBF, 0xB2, 0x0D, 0x7E, 0xB2, 0x30, 0x7E, 0xB2, 0x15, 0x00,
	0x14, 0x00, 0x10, 0x07, 0x11, 0x00, 0x13, 0x01, 0x20, 0xFF, 0xE5, 0x21,
	0x0D, 0xEC, 0xCB, 0x4E, 0xE1, 0xF5, 0xCD, 0x8F, 0xB3, 0x20, 0x05, 0xD4,
	0x36, 0xB3, 0xF1, 0xC9, 0xF1, 0xC9, 0xC9, 0xF5, 0xE5, 0xD5, 0xC5, 0x47,
	0x21, 0x80, 0x58, 0xAF, 0xB9, 0x78, 0x20, 0x03, 0x21, 0x69, 0x59, 0x11,
	0x20, 0x00, 0xA7, 0x28, 0x04, 0x19, 0x3D, 0x20, 0xFC, 0x3E, 0x78, 0xBE,
	0x20, 0x02, 0x3E, 0x68, 0x47, 0x16, 0x20, 0xAF, 0xB9, 0x78, 0x20, 0x02,
	0x16, 0x0E, 0x77, 0x23, 0x15, 0x20, 0xFB, 0xC1, 0xD1, 0xE1, 0xF1, 0xC9,
	0xCD, 0x37, 0xB3, 0x3D, 0xF2, 0x76, 0xB3, 0x7E, 0x3D, 0x3D, 0xCD, 0x37,
	0xB3, 0x37, 0xC9, 0xD5, 0xCD, 0x37, 0xB3, 0x3C, 0x57, 0x7E, 0x3D, 0x3D,
	0xBA, 0x7A, 0xF2, 0x8A, 0xB3, 0xAF, 0xCD, 0x37, 0xB3, 0xD1, 0xC9, 0xC5,
	0xD5, 0x46, 0x23, 0xBE, 0x23, 0x5E, 0x23, 0x56, 0x28, 0x08, 0x23, 0x10,
	0xF6, 0x37, 0x3F, 0xD1, 0xC1, 0xC9, 0xEB, 0xD1, 0xC1, 0xCD, 0xAF, 0xB3,
	0x38, 0x02, 0xBF, 0xC9, 0xBF, 0x37, 0xC9, 0xE9, 0xDD, 0xE5, 0x16, 0x00,
	0x5F, 0x21, 0x80, 0x0C, 0xCD, 0xB5, 0x03, 0xDD, 0xE1, 0xC9, 0xE5, 0x21,
	0x3B, 0x5C, 0xCB, 0x6E, 0x28, 0xFC, 0xCB, 0xAE, 0x3A, 0x08, 0x5C, 0x21,
	0x41, 0x5C, 0xCB, 0x86, 0xFE, 0x20, 0x30, 0x0D, 0xFE, 0x10, 0x30, 0xE7,
	0xFE, 0x06, 0x38, 0xE3, 0xCD, 0xE3, 0xB3, 0x30, 0xDE, 0xE1, 0xC9, 0xCD,
	0xDB, 0x10, 0xC9, 0x3E, 0x00, 0x32, 0x41, 0x5C, 0x3E, 0x02, 0x32, 0x0A,
	0x5C, 0x21, 0x3B, 0x5C, 0x7E, 0xF6, 0x0C, 0x77, 0x21, 0x0D, 0xEC, 0xCB,
	0x66, 0x21, 0x66, 0x7B, 0x20, 0x03, 0xCB, 0x86, 0xC9, 0xCB, 0xC6, 0xC9,
	0xC5, 0xD5, 0xE5, 0x21, 0x2E, 0xB4, 0x11, 0x98, 0x5B, 0x01, 0x10, 0x00,
	0xED, 0xB0, 0x2A, 0x36, 0x5C, 0xE5, 0x21, 0x98, 0x5A, 0x22, 0x36, 0x5C,
	0x21, 0x3E, 0xB4, 0xCD, 0x6E, 0xB4, 0xE1, 0x22, 0x36, 0x5C, 0xE1, 0xD1,
	0xC1, 0xC9, 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F, 0xFF, 0xFE, 0xFC,
	0xF8, 0xF0, 0xE0, 0xC0, 0x80, 0x00, 0x10, 0x02, 0x20, 0x11, 0x06, 0x21,
	0x10, 0x04, 0x20, 0x11, 0x05, 0x21, 0x10, 0x00, 0x20, 0xFF, 0xC5, 0xAF,
	0x50, 0x5F, 0xCB, 0x1A, 0xCB, 0x1B, 0xCB, 0x1A, 0xCB, 0x1B, 0xCB, 0x1A,
	0xCB, 0x1B, 0x21, 0x00, 0x58, 0x47, 0x09, 0x19, 0xC1, 0xC9, 0x3E, 0x16,
	0xD7, 0x78, 0xD7, 0x79, 0xD7, 0xC9, 0x7E, 0x23, 0xFE, 0xFF, 0xC8, 0xD7,
	0x18, 0xF8, 0x08, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x08,
	0x00, 0x16, 0x01, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x02, 0x01, 0x05, 0x06,
	0x00, 0x00, 0x00, 0x04, 0x10, 0x14
};




int inject_menu() {

	printf("\r\nListening...\r\n");
	listen_for_en();
	printf("enable happened\r\n");

	enum per_if_type type = get_if_type();

	if (type == INIT) {
		int res = DMA_request(100);
		printf("%d\r\n", res);
		if (res == -1) {
			return res;
		}

		write_buf_mem(MENU_CODE_ADDR, menu_code, 0, MENU_CODE_LEN);

		alt_u16 addr = NMI_ROUTINE_ADDR;
		write_mem(addr++, RETN1);
		write_mem(addr++, RETN2);

		DMA_stop_w_interrupt(10);
	}
	per_cmd_ack();
	return 0;
}

int my_list_test() {
	printf("Processing...\r\n");

	FAT_HANDLE hFat = 0;

	do {
		hFat = init_SD();
	} while (!hFat);

	if (hFat){
		printf("sdcard mount success!\n");
		printf("Root Directory Item Count:%d\n", Fat_FileCount(hFat));
		//Fat_Test(hFat, "text.txt");
	}else{
		//printf("Failed to mount the SDCARD!\r\nPlease insert the SDCARD into DE2-115 board and press KEY3.\r\n");
		printf("Failed to mount the SDCARD!\r\nPlease insert the SDCARD into DE2-115 board and reset.\r\n");
		return -1;
	}


	FILENAMES list = list_files(hFat);
	if (list.size == 0 && list.filenames == NULL) {
		printf("bad listing\r\n");
		close_SD(hFat);
		return -1;
	}
	print_filenames(list, 1);

	close_SD(hFat);

	return 0;
}

void load_page(FILENAMES list) {
	int page_num = get_page_num();
	printf("PAGE: %d\r\n", page_num);
	int n_entries = 16;
	int start_idx = page_num*16;

	if (list.size < (start_idx + n_entries))
		n_entries = list.size - page_num*16;

	DMA_request(10);
	n_entries++; // to account for the title

	// Writing the menu text table for file list menu
	alt_u16 addr = PAGE_DATA_ADDR;
	write_mem(addr++, n_entries); // DEFB $n_entries
	char* title = "SD LOADER";
	write_buf_mem(addr, title, 0, strlen(title));
	addr += strlen(title);
	write_mem(addr++, 0xFF); // terminate char

	for (int i = start_idx; i < start_idx + (n_entries-1); i++) {
		int name_len = strlen(list.filenames[i]);
		write_buf_mem(addr, list.filenames[i], 0, name_len);
		addr += name_len;
	}

	// Forming page number string
	int all_pages = ((list.size-1) / 16) + 1; // calculates number of existing pages
	page_num++; // to start the page at number 1
	int str_len = (int)((ceil(log10(page_num))+1)*sizeof(char)) // number of digits page_num has (WRONG)
			+ sizeof(char)									// the '/' char's size
			+ (int)((ceil(log10(all_pages))+1)*sizeof(char));  // number of digits all_pages has (WRONG)

	char pages_str[str_len];
    sprintf(pages_str, "%d/%d", page_num, all_pages);
    str_len = strlen(pages_str);
    write_buf_mem(addr, pages_str, 0, str_len); // writes the page string to memory
    addr += str_len;		// advances address
    write_mem(addr++, 0xFF); // terminate char

    // writes the number of pages left
    alt_u8 remaining = all_pages-page_num;
    addr = PAGES_LEFT_ADDR;
    write_mem(addr, remaining);
    printf("REMAINING: %d\r\n",remaining);

	// writing NMI code (just a return)
	addr = NMI_ROUTINE_ADDR;
	write_mem(addr++, RETN1);
	write_mem(addr++, RETN2);

	DMA_stop_w_interrupt();
}

void load_game(FAT_HANDLE hFat, FILENAMES list) {
	int page_num = get_page_num();
	int game_num = get_game_num();
	printf("PAGE: %d\r\n", page_num);
	printf("GAME: %d\r\n", game_num);

	int idx = (page_num*16 + game_num);
	printf("idx: %d\r\n", idx);
	if (list.size < idx) {
		printf("something went wrong :(\r\n");
		return;
	}

	// restoring the name
	int name_len = strlen(list.filenames[idx]);
	char filename[name_len];
	strncpy(filename, list.filenames[idx], name_len);
	filename[name_len] = '\0'; // have to stress this, cause sometimes it would have an extra @ for no reason

	printf("GAME SELECTED before: %s\r\n", filename);
	filename[name_len-1] = filename[name_len-1] - 0x80;

	printf("GAME SELECTED: %s\r\n", filename);
	printf("FILENAME_LEN: %d (%d)\r\n", strlen(filename), name_len);

	int ret = load_file(hFat, filename, name_len);
	if (ret) {
		printf("Load file went wrong\r\n");
	}
}

int main() {
	//SD_Test("SENBAL.SNA");

	//my_list_test();

	//sna_file_test();

	//return z80_file_test();

	//return load_SNA("SENBAL.SNA");
	//return load_SNA("DAAW.SNA");
	//return load_SNA("DIABLO1.SNA");
	//return load_SNA("CLOUD99.SNA");

	printf("TEST\r\n");
	DMA_init();

	printf("Injecting menu...\r\n");
	int res = inject_menu();
	if (res == -1) {
		printf("inject menu went wrong\r\n");
		return res;
	}

	printf("Initializing SD...\r\n");
	FAT_HANDLE hFat = 0;
	int tries = 10;
	while (tries-- > 0) {
		hFat = init_SD();
		if (hFat) break;
		printf("retrying...");
	}
	printf("LOAD\r\n");

	//return load_z80(hFat, "BOMBJ.z80");
	//return load_z80(hFat, "BUBBOB.z80");
	//return load_z80(hFat, "BUBBUS.z80");

	//return load_z80(hFat, "MANICM.z80"); // NORMAL
	//return load_z80("MISSILGZ.z80"); // CONTROLLER REQUIRED?

	printf("\r\nRetrieving files");
	FILENAMES list = list_files(hFat);
	if (list.size == 0 && list.filenames == NULL) {
		printf("bad listing\r\n");
		close_SD(hFat);
		return -1;
	}

	//////////////////////////

	print_filenames(list, 0);

	/////////////////////////


	while (1) {
		printf("\r\nListening...\r\n");
		listen_for_en();
		printf("enable happened\r\n");

		enum per_if_type type = get_if_type();

		switch(type) {
			case NA:
				printf("NONE\r\n");
				break;
			case SD:
				if (is_read()) {
					load_page(list);
				} else if (is_write()) {
					load_game(hFat, list);
				}
				break;
			case INIT:
				printf("shouldnt be happening\r\n");
				break;
			default:
				printf("default\r\n");
		}
		per_cmd_ack();
	}


	//my_list_test();

	close_SD(hFat);
	return 0;

}
