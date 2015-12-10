/* Generated driver function for led_controller IP core */
#include "myGrayscale.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "stdio.h"
#include "xuartlite.h"
#include "Grayscale.h"


/* 	Define the base memory address of the led_controller IP core */
#define MYGRAYSCALE_BASE 0x43C00000

 //Already Defined in the mycordic.h file
#define SLV_REG0 MYGRAYSCALE_S00_AXI_SLV_REG0_OFFSET
#define SLV_REG1 MYGRAYSCALE_S00_AXI_SLV_REG1_OFFSET
#define SLV_REG2 MYGRAYSCALE_S00_AXI_SLV_REG2_OFFSET



void grayscaleFilter(unsigned int PHOTO_HEIGHT, unsigned int PHOTO_LENGTH, u32 Rp, u32 Gp, u32 Bp){
	u32 RGB = 0;
	u32 inp = 0;
	unsigned int i,c,pixel,PHOTO_SIZE;
	u32 PER = 0;
	u16 output = 0;

	i = 0;
	c = 0;

	PHOTO_SIZE = PHOTO_HEIGHT * PHOTO_LENGTH;


	PER = (Rp<<16 & 0x00FF0000) + (Gp<<8 & 0x0000FF00) + (Bp & 0x000000FF);


	for(i=0;i<PHOTO_SIZE;i++){
		pixel = pictureRocks[i];
		inp = (pixel<<24 & 0xFF000000) + PER;
		c = c+1;

		//Formatting, prints the length of the image
		if (c == PHOTO_LENGTH){
			c = 0;
			MYGRAYSCALE_mWriteReg(MYGRAYSCALE_BASE,SLV_REG0,inp);
			MYGRAYSCALE_mWriteReg(MYGRAYSCALE_BASE,SLV_REG2,0x00000001); //Start
			MYGRAYSCALE_mWriteReg(MYGRAYSCALE_BASE,SLV_REG2,0x00000000); //Clear the register
			RGB = MYGRAYSCALE_mReadReg(MYGRAYSCALE_BASE,SLV_REG1);
			output = RGB>>24 & 0xFFFFFFFF;
			xil_printf("%02X \r\n", output);
		}
		else{
			MYGRAYSCALE_mWriteReg(MYGRAYSCALE_BASE,SLV_REG0,inp);
			MYGRAYSCALE_mWriteReg(MYGRAYSCALE_BASE,SLV_REG2,0x00000001); //Start
			MYGRAYSCALE_mWriteReg(MYGRAYSCALE_BASE,SLV_REG2,0x00000000); //Clear the register
			RGB = MYGRAYSCALE_mReadReg(MYGRAYSCALE_BASE,SLV_REG1);
			output = RGB>>24 & 0xFFFFFFFF;
			xil_printf("%02X,", output);
		}
	};

}
