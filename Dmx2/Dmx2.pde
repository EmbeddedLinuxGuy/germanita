#include "pins_arduino.h"

int port_to_output[] = { 
   NOT_A_PORT, 
   NOT_A_PORT, 
   _SFR_IO_ADDR(PORTB), 
   _SFR_IO_ADDR(PORTC), 
   _SFR_IO_ADDR(PORTD) 
   }; 

int sig = 8;           // signal 

int DEBUG = 1;

int count = 0;

int dmxValue = 0x80;

void setup() {
 
 pinMode(sig, OUTPUT);
 digitalWrite(8, HIGH);
 
 pinMode(9, OUTPUT);
 pinMode(10, OUTPUT);
 pinMode(11, OUTPUT);
 
   if (DEBUG) {           // If we want to see the pin values for debugging...
   Serial.begin(115200);  // ...set up the serial ouput on 0004 style
         }
}

/* Sends a DMX byte out on a pin.  Assumes a 16 MHz clock.
* Disables interrupts, which will disrupt the millis() function if used
* too frequently. */


void shiftDmxOut(int pin, int theByte)
{
   int wasteTime = 0;
   int theDelay = 1;
   int count = 0;
   int portNumber = port_to_output[digitalPinToBitMask(pin)];
   int pinNumber = digitalPinToBitMask(pin) ;
       
   // the first thing we do is to write te pin to high
   // it will be the mark between bytes. It may be also
   // high from before
       _SFR_BYTE(_SFR_IO8(portNumber)) |= _BV(pinNumber);
   delayMicroseconds(10);

   // disable interrupts, otherwise the timer 0 overflow interrupt that
   // tracks milliseconds will make us delay longer than we want.
   cli();

       // DMX starts with a start-bit that must always be zero
       _SFR_BYTE(_SFR_IO8(portNumber)) &= ~_BV(pinNumber);
       //we need a delay of 4us (then one bit is transfert)
       // at the arduino just the delay for 1us is precise every thing between 2 and 12 is jsut luke
       // to get excatly 4us we have do delay 1us 4 times
       delayMicroseconds(theDelay);
       delayMicroseconds(theDelay);
       delayMicroseconds(theDelay);
       delayMicroseconds(theDelay);
   
        for (count = 0; count < 8; count++) {
                           
               if (theByte & 01) {
                 _SFR_BYTE(_SFR_IO8(portNumber)) |= _BV(pinNumber);
               }
           else {
                 _SFR_BYTE(_SFR_IO8(portNumber)) &= ~_BV(pinNumber);
               }

             delayMicroseconds(theDelay);
             delayMicroseconds(theDelay);
             delayMicroseconds(theDelay);
             // to write every bit exactly 4 microseconds, we have to waste some time here.
             //thats why we are doing a for loop with nothing to do, a delayMicroseonds is not smal enough
             for (wasteTime =0; wasteTime <2; wasteTime++) {}
            
             
               theByte>>=1;
       }
      
   // the last thing we do is to write the pin to high
   // it will be the mark between bytes. (this break is have to be between 8 us and 1 sec)
       _SFR_BYTE(_SFR_IO8(portNumber)) |= _BV(pinNumber);

   // reenable interrupts.
   sei();
}

void loop()  {
 
///////////////////////////////////////////////////////////sending the dmx signal

 

 
 // sending the break (the break can be between 88us and 1sec)
  digitalWrite(sig, LOW);
  delay(50);
   
  //sending the start byte
  shiftDmxOut(sig,0);
  
  //set all adresses/channel to the swing value
  for (count = 1; count<=512; count++)
  {
    
   shiftDmxOut(sig, dmxValue);

  }

    if (DEBUG)
     { // If we want to read the output
   
       Serial.print("\t");    // Print a tab
       Serial.print("DMX Value:");    // Indicate that output is red value
       Serial.print(dmxValue);
     }
     
     
     
}



