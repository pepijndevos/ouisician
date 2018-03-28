// inslude the SPI library:
#include <SPI.h>


// set pin 10 as the slave select for the digital pot:
const int slaveSelectPin = 10;

void setup() {
  Serial.begin(9600);
  // set the slaveSelectPin as an output:
  pinMode(slaveSelectPin, OUTPUT);
  // initialize SPI:
  SPI.begin();
}

void loop() {

  int value = 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
  Serial.println(value);
  Write(value);
  Serial.println(value);

  

}

int Write(int value) {
  // take the SS pin low to select the chip:
  //  send in the address and value via SPI:
  SPI.beginTransaction(SPISettings(14000000, MSBFIRST, SPI_MODE0));
  digitalWrite(slaveSelectPin, LOW);
  SPI.transfer(value,32);
  digitalWrite(slaveSelectPin, HIGH);
  SPI.endTransaction();
  // take the SS pin high to de-select the chip:
 
  
  return value;
}