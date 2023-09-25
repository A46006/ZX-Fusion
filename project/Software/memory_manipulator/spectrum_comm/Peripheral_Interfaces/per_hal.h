#include "../Peripheral_Interfaces/per_hw.h"

void listen_for_en();

enum per_if_type {NA, INIT, SD, ONLINE, STATE};

enum per_if_type get_if_type();
int get_page_num();

int get_game_num();

bool is_read();
bool is_write();

void per_cmd_ack();
