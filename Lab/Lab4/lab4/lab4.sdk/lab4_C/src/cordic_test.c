/* Generated driver function for led_controller IP core */
#include "mycordic.h"
#include "xparameters.h"
#include "xil_printf.h"
//#include "xil_io.h"
#include "stdio.h"


// Define delay length
#define DELAY 1000000

/* 	Define the base memory address of the led_controller IP core */
//#define MYPIX_BASE XPAR_MYPIX_0_S00_AXI_BASEADDR
#define MYCORDIC_BASE 0x43C00000 // sometimes the xparameters.h is wrongly created with the wrong
                              // low address for MYPIX peripheral
                              // always look at the Address Editor for the correct address


 //Already Defined in the mycordic.h file
#define SLV_REG0 MYCORDIC_S00_AXI_SLV_REG0_OFFSET
#define SLV_REG1 MYCORDIC_S00_AXI_SLV_REG1_OFFSET
#define SLV_REG2 MYCORDIC_S00_AXI_SLV_REG2_OFFSET
#define SLV_REG3 MYCORDIC_S00_AXI_SLV_REG3_OFFSET


/* main function */
int main(void){
	/* unsigned 32-bit variables for storing current LED value */
	u32 valueXY, valueZ,valueXY2, valueZ2,valueXY3, valueZ3,valueXY4, valueZ4;
	u16 X1,Y1,Z1,X2,Y2,Z2,X3,Y3,Z3,X4,Y4,Z4;

	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0x00000000); //Clear the register

	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG0,0x26DC0000);
	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0x21834000);

	valueXY = MYCORDIC_mReadReg (MYCORDIC_BASE,SLV_REG2);
	valueZ = MYCORDIC_mReadReg (MYCORDIC_BASE,SLV_REG3);

	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0x00000000); //Clear the register


	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG0,0x26DC0000);
	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0xBD034000);

	valueXY2 = MYCORDIC_mReadReg (MYCORDIC_BASE,SLV_REG2);
	valueZ2= MYCORDIC_mReadReg (MYCORDIC_BASE,SLV_REG3);

	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0x00000000); //Clear the register


	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG0,0x33333333);
	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0x0000C000);

	valueXY3 = MYCORDIC_mReadReg (MYCORDIC_BASE,SLV_REG2);
	valueZ3= MYCORDIC_mReadReg (MYCORDIC_BASE,SLV_REG3);

	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0x00000000); //Clear the register


	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG0,0x40002000);
	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0x0000C000);

	valueXY4 = MYCORDIC_mReadReg (MYCORDIC_BASE,SLV_REG2);
	valueZ4= MYCORDIC_mReadReg (MYCORDIC_BASE,SLV_REG3);

	MYCORDIC_mWriteReg(MYCORDIC_BASE,SLV_REG1,0x00000000); //Clear the register

	X1 = (valueXY & 0x0000FFFF);
	Y1 = (valueXY & 0xFFFF0000)>>16;
	Z1 = (valueZ & 0xFFFF0000)>>16;

	X2 = (valueXY2 & 0x0000FFFF);
	Y2 = (valueXY2 & 0xFFFF0000)>>16;
	Z2 = (valueZ2 & 0xFFFF0000)>>16;

	X3 = (valueXY3 & 0x0000FFFF);
	Y3 = (valueXY3 & 0xFFFF0000)>>16;
	Z3 = (valueZ3 & 0xFFFF0000)>>16;

	X4 = (valueXY4 & 0x0000FFFF);
	Y4 = (valueXY4 & 0xFFFF0000)>>16;
	Z4 = (valueZ4 & 0xFFFF0000)>>16;

	xil_printf("|=========================================|\r\n");
	xil_printf("|            Circular CORDIC              |\r\n");
	xil_printf("|           By: Austin Copeman            |\r\n");
	xil_printf("|                 and                     |\r\n");
	xil_printf("|              Azam Tayybei               |\r\n");
	xil_printf("|               11/11/2015                |\r\n");
	xil_printf("|=========================================|\r\n");
	xil_printf("|         Value of the Registers          |\r\n");
	xil_printf("|=========================================|\r\n");
	xil_printf("|  ValueXY = %08X, ValueZ = %08X  |\r\n", valueXY, valueZ);
	xil_printf("|  ValueXY = %08X, ValueZ = %08X  |\r\n", valueXY2, valueZ2);
	xil_printf("|  ValueXY = %08X, ValueZ = %08X  |\r\n", valueXY3, valueZ3);
	xil_printf("|  ValueXY = %08X, ValueZ = %08X  |\r\n", valueXY4, valueZ4);
	xil_printf("|=========================================|\r\n");
	xil_printf("|              Formated Output            |\r\n");
	xil_printf("|=========================================|\r\n");
	xil_printf("|  Xout = %04X, Yout = %04X, Zout = %04X  |\r\n",X1,Y1,Z1);
	xil_printf("|  Xout = %04X, Yout = %04X, Zout = %04X  |\r\n",X2,Y2,Z2);
	xil_printf("|  Xout = %04X, Yout = %04X, Zout = %04X  |\r\n",X3,Y3,Z3);
	xil_printf("|  Xout = %04X, Yout = %04X, Zout = %04X  |\r\n",X4,Y4,Z4);
	xil_printf("|=========================================|\r\n");
/*
	// writing input data: A = 0x008C, B = 0x0009, expected: Q = 0x000F, R = 0x0005
	   MYCORIC_mWriteReg (MYCORDIC_BASE, 0, 0x008C0009); // Writing on Register 0
	   // Here, you might poll slv_reg2(0)=v to detect whether data is ready
	   // But we will read immediately since time between instructions is enough in this particular case.
       value = MYCORDIC_mReadReg (MYCORDIC_BASE,4); // Reading from Register 1

       MYCORDIC_mWriteReg(MYCORDIC_BASE,0, 0xFFFFFFFF); // this is just to restart for a new division
       Q = (value&0xFFFF0000)/0x10000;
       R = value&0x0000FFFF;
       xil_printf ("Q = %04X, R = %04X\r\n", Q, R);
    */

	return 1;
}
