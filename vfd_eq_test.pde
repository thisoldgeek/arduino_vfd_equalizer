/*
  SPI_VFD Library - Custom Character
 
 Demonstrates the use a 20x2 VFD display.  The SPI_VFD
 library works with all VFD displays that are compatible with the 
 NEC PD16314 driver and has the SPI pins brought out
 
 This sketch prints "I <3 Arduino" to the VFD

  The circuit:
 * VFD Data to digital pin 2
 * VFD Clock to digital pin 3
 * VFD Chip select to digital pin 4
 * VFD VCC (power) to 5V
 * VFD Ground (power) to Ground
 
 Library originally added 18 Apr 2008
 by David A. Mellis
 library modified 5 Jul 2009
 by Limor Fried (http://www.ladyada.net)
 example added 9 Jul 2009
 by Tom Igoe
 modified 22 Nov 2010
 by Tom Igoe
 
 This example code is in the public domain.
 */

// include the library code:
#include <SPI_VFD.h>


//channel 0
int strobe = 5; // strobe pins on digital 4
int res = 6;    // reset pins on digital 5
const int ANALOG = 0;

//channel 1
/*
int strobe1 = 7; // strobe pins on digital 7
int res1= 8;    // reset pins on digital 8
*/
const int ANALOG1 = 1;


int left[7];   // store band values in these arrays
int right[7];

int topchar[7];  // store the value for top row of bar
int botchar[7];  // store the value for bottom row of bar
int peak = 14;

int conspectrumValue[7]; // holds constrained/ mapped a2d values
int filterValue = 80; // MSGEQ7 always spits out a number around 60, so this filters those out


int band;

// initialize the library with the numbers of the interface pins
SPI_VFD vfd(2, 3, 4);
/*
byte newChar[8] = {
	B00000,
	B01010,
	B11111,
	B11111,
	B11111,
	B01110,
	B00100,
	B00000
};
*/
byte newChar[8] = {
	B00000,
	B00000,
	B00000,
	B00000,
	B00000,
	B00000,
	B00000,
	B11111
};

byte newChar1[8] = {
	B00000,
	B00000,
	B00000,
	B00000,
	B00000,
	B00000,
	B11111,
	B11111
};

byte newChar2[8] = {
	B00000,
	B00000,
	B00000,
	B00000,
	B00000,
	B11111,
	B11111,
	B11111
};
byte newChar3[8] = {
	B00000,
	B00000,
	B00000,
	B00000,
	B11111,
	B11111,
	B11111,
	B11111
};
byte newChar4[8] = {
	B00000,
	B00000,
	B00000,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111
};
byte newChar5[8] = {
	B00000,
	B00000,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111
};
byte newChar6[8] = {
	B00000,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111
};
byte newChar7[8] = {
	B11111,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111,
	B11111
};
void setup() {
  // MSGEQ7 Setup
  Serial.begin(115200);
  pinMode(ANALOG, INPUT);
  pinMode(res, OUTPUT); // reset
  pinMode(strobe, OUTPUT); // strobe
  digitalWrite(res,LOW); // reset low
  digitalWrite(strobe,HIGH); //pin 5 is RESET 
  
  pinMode(ANALOG1, INPUT);
  /*
  pinMode(res1, OUTPUT); // reset
  pinMode(strobe1, OUTPUT); // strobe
  digitalWrite(res1,LOW); // reset low
  digitalWrite(strobe1,HIGH); //pin 8 is RESET o
  */
  
  // create a new character
  vfd.createChar(0, newChar);
  vfd.createChar(1, newChar1);
  vfd.createChar(2, newChar2);
  vfd.createChar(3, newChar3);
  vfd.createChar(4, newChar4);
  vfd.createChar(5, newChar5);
  vfd.createChar(6, newChar6);
  vfd.createChar(7, newChar7);
  
  // set up the VFD's number of columns and rows: 
  vfd.begin(20, 2);
  // Print a message to the VFD.
  vfd.print(" 20x2 char. SPI VFD");
   vfd.setCursor(0, 1);
  vfd.print(" Adafruit ");
  vfd.write(0);
  vfd.write(1);
  vfd.write(2);
  vfd.write(3);
  vfd.write(4);
  vfd.write(5);
  vfd.write(6);
  vfd.write(7);
  
  
  
  //vfd.print(" Arduino");
}

void readMSGEQ7()
// Function to read 7 band equalizers
{
 digitalWrite(res, HIGH);
 digitalWrite(res, LOW);
  for(band=0; band <7; band++)
  {
    digitalWrite(strobe,LOW);    // strobe pin on the shield - kicks the IC up to the next band    
    delayMicroseconds(30);       // 
    left[band] = analogRead(0);  // store left band reading
   right[band] = analogRead(1); // ... and the right
    digitalWrite(strobe,HIGH);     
  }
  /*
  digitalWrite(res1, HIGH);
  digitalWrite(res1, LOW);
  for(band=0; band <7; band++)
  {
    digitalWrite(strobe1,LOW);    // strobe pin on the shield - kicks the IC up to the next band    
    delayMicroseconds(30);       // 
    //left[band] = analogRead(0);  // store left band reading
    right[band] = analogRead(1); // ... and the right
    digitalWrite(strobe1,HIGH);     
  }
  */
}

void musicVisualizer() { // sound to music
  vfd.clear();
  for (band = 0; band < 7; band++) {
    int RAW = left[band];
    RAW = constrain(RAW, filterValue, 1023);
    RAW = map (RAW, filterValue, 1023, 0, 14);
    if (RAW > 7 ) 
       { topchar[band] = peak - RAW;
         botchar[band] = 7;
       }
    else
       {  topchar[band] = 0;
          botchar[band] = RAW;
       }   
    vfd.setCursor(band,0);
    if (topchar[band] > 0)
      {
    vfd.write(topchar[band]);
      }
    vfd.setCursor(band,1);
    vfd.write(botchar[band]);
    
    RAW = right[band];
    RAW = constrain(RAW, filterValue, 1023);
    RAW = map (RAW, filterValue, 1023, 0, 14);
    if (RAW > 7 ) 
       { topchar[band] = peak - RAW;
         botchar[band] = 7;
       }
    else
       {  topchar[band] = 0;
          botchar[band] = RAW;
       }   
    vfd.setCursor(band+13,0);
    if (topchar[band] > 0)
      {
    vfd.write(topchar[band]);
      }
    vfd.setCursor(band+13,1);
    vfd.write(botchar[band]);
    
    
    //conspectrumValue [band] = RAW;
    //vfd.write(conspectrumValue[band]);
    //Serial.print(conspectrumValue[band]);
    //Serial.print(" ");
  }
  
}


void loop() 
{
  readMSGEQ7();
  musicVisualizer();
  //Serial.println(); 
}

