#include "myGrayscale.h"
#include "xparameters.h"
#include "stdio.h"
//#include "xuartlite.h" //For use of UART, need to figure out how to use!
#include "Grayscale.h"


/* main function */
int main(void){
	//Variable declaration for Grayscale
	unsigned int PHOTO_HEIGHT,PHOTO_LENGTH = 0;
	u32 Rp, Gp, Bp = 0;

	//Initial Parameters for Grayscale
	PHOTO_HEIGHT = 100;
	PHOTO_LENGTH = 100;
	Rp = 100;
	Gp = 0;
	Bp = 0;
	//End of Parameters for Grayscale

	grayscaleFilter(PHOTO_HEIGHT, PHOTO_LENGTH, Rp, Gp, Bp);

	return 1;
}
