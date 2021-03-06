/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
//#include "platform.h"
#include "my_cordicfull.h"
#include "xparameters.h"
#include "stdio.h"
#include "xil_io.h"


int main()
{
	u32 baseaddr;
	u32 Mem32Value;
	int     Index;

	// Enabling caches
    Xil_DCacheEnable();
    Xil_ICacheEnable();

    xil_printf("Hello World\n\r");
    //baseaddr = XPAR_MYPIXFULL_0_S00_AXI_BASEADDR;
    baseaddr = 0x7AA00000;

	/*
	 * Write data to user logic BRAMs and read back
	 * A simple for-loop might take of the bursts, though it has be used in conjunction
	 * with a cache to make sure the bursts happen
	 * The previous one might not be a solution (some claim that it is with burst length of 8, requires painful verification)
	 */

    //xil_printf("Memory address is 0x%08x\n\r", baseaddr);
//    for ( Index = 0; Index < 16; Index++ )
//    {
//    	MYPIXFULL_mWriteMemory(baseaddr+4*Index, (0xDEADBEEF + Index));
//    }
//	for ( Index = 0; Index < 16; Index++ )
//	{
//	  Mem32Value = MYPIXFULL_mReadMemory(baseaddr+4*Index);
//	  xil_printf("Received data is 0x%08x\n\r", Mem32Value);
//	}
    //Mode 0 = Rotation
    //Mode 1 = Vectoring
    xil_printf("Start of Rotation\n\r");
	MY_CORDICFULL_mWriteMemory(baseaddr, (0x000026DC)); // X=0,Y=1/An
	MY_CORDICFULL_mWriteMemory(baseaddr, (0x21830000)); //Z=PI/6,Mode =0
	MY_CORDICFULL_mWriteMemory(baseaddr, (0x000026DC)); //X=0,Y=1/An
	MY_CORDICFULL_mWriteMemory(baseaddr, (0x32440000)); //Z=PI/4,Mode =0

	// Reading data.
		for ( Index = 0; Index < 4; Index++ )
		{
		  Mem32Value = MY_CORDICFULL_mReadMemory(baseaddr+4*Index);
		  xil_printf("Received data is 0x%08x\n\r", Mem32Value);
		}

		xil_printf("\n\r");
		MY_CORDICFULL_mWriteMemory(baseaddr, (0x000026DC)); // X=0,Y=1/An
		MY_CORDICFULL_mWriteMemory(baseaddr, (0xBD030000)); //Z=
		MY_CORDICFULL_mWriteMemory(baseaddr, (0x000026DC)); //X=0,Y=1/An
		MY_CORDICFULL_mWriteMemory(baseaddr, (0xE347000)); //Z=PI/4,Mode =0

		// Reading data.
			for ( Index = 0; Index < 4; Index++ )
			{
			  Mem32Value = MY_CORDICFULL_mReadMemory(baseaddr+4*Index);
			  xil_printf("Received data is 0x%08x\n\r", Mem32Value);
			}
			xil_printf("Start of Vectoring \n\r");
			//Vectoring
			MY_CORDICFULL_mWriteMemory(baseaddr, (0x33333333)); //
			MY_CORDICFULL_mWriteMemory(baseaddr, (0x00008000)); //Z=PI/6,Mode =1
			MY_CORDICFULL_mWriteMemory(baseaddr, (0x20002000)); //X=0,Y=1/An
			MY_CORDICFULL_mWriteMemory(baseaddr, (0x00008000)); //Z=PI/4,Mode =1

			// Reading data.
				for ( Index = 0; Index < 4; Index++ )
				{
				  Mem32Value = MY_CORDICFULL_mReadMemory(baseaddr+4*Index);
				  xil_printf("Received data is 0x%08x\n\r", Mem32Value);
				}

				xil_printf("\n\r");

				MY_CORDICFULL_mWriteMemory(baseaddr, (0x20004000)); //
				MY_CORDICFULL_mWriteMemory(baseaddr, (0x00008000)); //Z=PI/6,Mode =1
				MY_CORDICFULL_mWriteMemory(baseaddr, (0xE6664000)); //X=0,Y=1/An
				MY_CORDICFULL_mWriteMemory(baseaddr, (0x00008000)); //Z=PI/4,Mode =1

				// Reading data.
					for ( Index = 0; Index < 4; Index++ )
					{
					  Mem32Value = MY_CORDICFULL_mReadMemory(baseaddr+4*Index);
					  xil_printf("Received data is 0x%08x\n\r", Mem32Value);
					}
		xil_printf("Good Bye\n\r");
    Xil_DCacheDisable();
    Xil_ICacheDisable();

    return 0;
}
