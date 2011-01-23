/*
 * ds1307_7seg.pde - Arduino program to read time from a DS1307 real time clock
 *                 and display on a 4 digit common cathode segment display.
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

#include <avr/interrupt.h>
#include <Wire.h>

int disp[4];                 /* 4 digits to be displayed */
int dcount;                  /* Display counter (next char to be displayed) */

int ddigit (int num, int pos) {
  int segment;                /* segment counter */
  int segbit;
  int i;
  
/* Define character set - LSB = Seg "a"  */

  int digits[] = { 0b00111111,        /* Segments that make up 0 */
                   0b00000110,        /* Segments that make up 1 */
                   0b01011011,        /* Segments that make up 2 */
                   0b01001111,        /* Segments that make up 3 */
                   0b01100110,        /* Segments that make up 4 */
                   0b01101101,        /* Segments that make up 5 */
                   0b01111101,        /* Segments that make up 6 */
                   0b00000111,        /* Segments that make up 7 */
                   0b01111111,        /* Segments that make up 8 */
                   0b01101111,        /* Segments that make up 9 */
                   0b00000000 };      
 
  for (i=9;i<13;i++) digitalWrite(i, HIGH);         /* Turn off all 4 digits */
  
  for (segment=0; segment<7; segment++) {
     segbit = (digits[num] >> segment) & 1;
     digitalWrite(segment+2, segbit);   /* Segments a - g are wired on pins 2 - 8 */
  }
  
  /* Turn on the character. Pos 0 - 3 (R to L) map to pins 9 - 12 */
  digitalWrite(pos+9, LOW);  
}

ISR(TIMER1_OVF_vect) {
      if (dcount>3) dcount=0; 
      ddigit(disp[dcount],dcount);
      dcount++;
}
   
void setup()
{
  int i;
  
  Wire.begin();              /* Start up i2c */
  
  dcount=0;
  
   /*Initialize pins */
   for (i=2; i < 13; i++) pinMode(i, OUTPUT);   /* sets the pins 2-13 as outputs */
   for (i=9; i < 13; i++) digitalWrite(i, HIGH); /* Turn all 4 digits off */
   pinMode(14, INPUT);
   
  /* Enable Timer1 Overflow Interrupt Enable and reset timer  */
  TIMSK1 = 1<<TOIE1;
  TCNT1 = 0; 

}

void loop()
{
  Wire.beginTransmission(0x68);
  Wire.send(0);
  Wire.endTransmission();
  
  Wire.requestFrom(0x68, 3);
  int sec = Wire.receive();
  int mins = Wire.receive();
  int hours = Wire.receive();

  if (digitalRead(14)==HIGH) {
     if ((hours & 0x1f) < 10 ) disp[3]=0x0a;  /* Assuming we're in 12 hour mode */
        else disp[3]=1;
     disp[2] = hours & 0x0f;
     disp[1] = (mins >>4) & 0x0f;
     disp[0] = mins &0x0f; 
  } else {
        disp[3] = 0x0a;
        disp[2] = 0x0a;
        disp[1] = (sec >>4) & 0x0f;
        disp[0] = sec &0x0f;
  }
  
  delay(200);
  
}

