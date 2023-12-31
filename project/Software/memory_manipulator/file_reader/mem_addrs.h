#define BORDER_COLOR_ADDR_H 0x5C
#define BORDER_COLOR_ADDR_L 0x48
#define BORDER_COLOR_ADDR 0x5C48



// for saving register values to video memory:
#define HL_ADDR_L 	0x00
#define HL_ADDR_H 	0x40

#define BC_ADDR_L 	HL_ADDR_L + 2
#define BC_ADDR_H 	HL_ADDR_H

#define DE_ADDR_L 	BC_ADDR_L + 2
#define DE_ADDR_H 	HL_ADDR_H


#define HL_AUX_ADDR_L 	DE_ADDR_L + 2
#define HL_AUX_ADDR_H 	HL_ADDR_H

#define BC_AUX_ADDR_L 	HL_AUX_ADDR_L + 2
#define BC_AUX_ADDR_H 	HL_ADDR_H

#define DE_AUX_ADDR_L	BC_AUX_ADDR_L + 2
#define DE_AUX_ADDR_H	HL_ADDR_H


#define IX_ADDR_L 	DE_AUX_ADDR_L + 2
#define IX_ADDR_H 	HL_ADDR_H

#define IY_ADDR_L 	IX_ADDR_L + 2
#define IY_ADDR_H 	HL_ADDR_H


#define I_ADDR_L	IY_ADDR_L + 2
#define I_ADDR_H	HL_ADDR_H

#define R_ADDR_L	I_ADDR_L + 2
#define R_ADDR_H	HL_ADDR_H
/*
#define BC_ADDR_L 0x02
#define BC_ADDR_H 0x40

#define DE_ADDR_L 0x04
#define DE_ADDR_H 0x40


#define HL_AUX_ADDR_L 0x06
#define HL_AUX_ADDR_H 0x40

#define BC_AUX_ADDR_L 0x08
#define BC_AUX_ADDR_H 0x40

#define DE_AUX_ADDR_L 0x0A
#define DE_AUX_ADDR_H 0x40


#define IX_ADDR_L 0x0C
#define IX_ADDR_H 0x40

#define IY_ADDR_L 0x0E
#define IY_ADDR_H 0x40


#define I_ADDR_L 0x10
#define I_ADDR_H 0x40

#define R_ADDR_L 0x11
#define R_ADDR_H 0x40
*/

#define SP_ADDR_L 0x00
#define SP_ADDR_H 0x41
