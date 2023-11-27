#ifndef LCD_H_
#define LCD_H_

//  LCD Module 16*2
#define lcd_write_cmd(base, data)                     IOWR(base, 0, data)
#define lcd_read_cmd(base)                            IORD(base, 1)
#define lcd_write_data(base, data)                    IOWR(base, 2, data)
#define lcd_read_data(base)                           IORD(base, 3)
//-------------------------------------------------------------------------
void  LCD_Init();
void  LCD_Show_Text(char* Text);
void  LCD_Line1();
void  LCD_Line2();
void  LCD_Test();
//-------------------------------------------------------------------------

#endif

