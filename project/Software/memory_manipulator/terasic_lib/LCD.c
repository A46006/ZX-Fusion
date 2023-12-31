// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

#include <unistd.h>
#include <string.h>
#include <io.h>
#include "./terasic_includes.h"
#include "./LCD.h"

// (\b): Move the cursor to the left by one character
// (\r): Move the cursor to the start of the current line
// (\n): Move the cursor to the start of the line and move it donw one line

//-------------------------------------------------------------------------
void LCD_Init()
{
  lcd_write_cmd(LCD_BASE,0x38);
  usleep(2000);
  lcd_write_cmd(LCD_BASE,0x0C);
  usleep(2000);
  lcd_write_cmd(LCD_BASE,0x01);
  usleep(2000);
  lcd_write_cmd(LCD_BASE,0x06);
  usleep(2000);
  lcd_write_cmd(LCD_BASE,0x80);
  usleep(2000);
}
//-------------------------------------------------------------------------
void LCD_Show_Text(char* Text)
{
  int i;
  for(i=0;i<strlen(Text);i++)
  {
    lcd_write_data(LCD_BASE,Text[i]);
    usleep(2000);
  }
}
//-------------------------------------------------------------------------
void LCD_Line1()
{
  lcd_write_cmd(LCD_BASE,0x80);
  usleep(2000);
}
void LCD_Line2()
{
  lcd_write_cmd(LCD_BASE,0xC0);
  usleep(2000);
}
//-------------------------------------------------------------------------
void LCD_Test()
{
  char Text1[16] = " Altera DE2-115 ";
  char Text2[16] = "LCD Test ";
  //  Initial LCD
  LCD_Init();
  //  Show Text to LCD
  LCD_Show_Text(Text1);
  //  Change Line2
  LCD_Line2();
  //  Show Text to LCD
  LCD_Show_Text(Text2);
}
//-------------------------------------------------------------------------
