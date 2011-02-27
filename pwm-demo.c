/*
 * pwm-demo.c - C (gcc) program to demonstrate PWM on an ATTiny2313 AVR
 *              microcontroller.  
 *
 * Copyright (C) 2011 Paul J. Zawada
 *
 * Feel free to modify, share, incorporate, or otherwise use this code
 * for anything you want as long as you attribute the source.
 *
 * This program comes with no warranty and is not guaranteed to be fit for any 
 * particular purpose.
 *
 */


#include <avr/io.h>
#include <avr/interrupt.h>

volatile uint16_t clk;             /* Global time-clock counter */
static   uint8_t  dutycycle[]={  0,  4,  9, 13, 17, 21, 26, 30, 
                                34, 38, 43, 47, 51, 55, 60, 64,
				72, 77, 81, 85, 89, 94, 98,102,
                               106,111,115,119,123,128,132,135,
			       140,145,149,153,157,162,166,170,
			       174,179,183,187,191,196,200,204,
			       208,213,217,221,225,230,234,238,
			       242,247,251,255};

int main() {
   
    uint8_t pos = 0;             
    
    DDRB  |= (1 << 2);       /* Enable OCR0A output */
    PORTB |= (1 << 2);       /* Initialize OCR0A off */


    TCCR0A |= ((1<<WGM01)|(1<<WGM00)); /* Configure timer 0 for Fast PWM mode */ 
   
    TCCR0A |= (1 << COM0A1);  /* Clear OC0A on match, set at top */
    TCCR0B |= (1 << CS00);    /* Start timer 1 - no prescaler */

    TIMSK |= (1 << TOIE0);   /* Fire an interrupt every time TIM0 overflows */

    OCR0A = dutycycle[pos];     /* Initialize duty cycle */

    sei();                   /* Turn on interrupts */

    for (;;) {

        if(clk >= 3906) {     /* change duty cycle every 1 sec */

            cli();           /* Turn off interrupts */

            clk = 0;         /* Reset clock counter */

            if (pos < 60) pos++; 
			
			    else pos=0; /* Go back to zero */
		
	        OCR0A = dutycycle[pos];
						
            sei();            /* Turn interrupts back on */
        }
    }
}

ISR(TIMER0_OVF_vect) {

/*
 * With 1 MHz clock and 8-bit timer, the timer will overflow 3906
 * times per second.  ( 1000000 / 256 = 3906 )
 */
    clk++;
}

