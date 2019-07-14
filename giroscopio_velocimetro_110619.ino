
/*
  Created 2016
  by AlexGyver
  AlexGyver Technologies.
*/

#include <EEPROM.h>

unsigned int min_speed = 0;  // minimal speed to display on scale, km/h
unsigned int max_speed = 40; // maximum speed to display on scale, km/h


volatile unsigned long lastturn, time_press;
volatile float SPEED;
volatile float DIST;
volatile boolean eeprom_flag;
float w_length = 2.050;
boolean flag;
boolean state, button;

#include <Wire.h>

long accelX, accelY, accelZ;
float gForceX, gForceY, gForceZ;

long gyroX, gyroY, gyroZ;
float rotX, rotY, rotZ;

void setup() {
  Serial.begin(9600);                // configure serial for debug
  attachInterrupt(0, sens, RISING);  // hall sensor interrupt
  pinMode(3, OUTPUT);                // D3 as power source

  DIST = (float)EEPROM.read(0) / 10.0; // remember some distance

  Wire.begin();
  setupMPU();
}

void sens() {
  if (millis() - lastturn > 80) {    // simple noise cut filter (based on fact that you will not be ride your bike more than 120 km/h =)
    SPEED = w_length / ((float)(millis() - lastturn) / 1000) * 3.6;   // calculate speed
    lastturn = millis();                                              // remember time of last revolution
    DIST = DIST + w_length / 1000;                                    // calculate distance
  }
  eeprom_flag = 1;
}

void loop() {
  // convert speed value to servo angle


  if ((millis() - lastturn) > 2000) {       // if there is no signal more than 2 seconds
    SPEED = 0;                              // so, speed is 0
    if (eeprom_flag) {                      // if eeprom flag is true
      EEPROM.write(0, (float)DIST * 10.0);  // write ODO in EEPROM
      eeprom_flag = 0;                      // flag down. To prevent rewritind
    }
  }

  if (digitalRead(8) == 1) {  // if button pressed
    DIST = 0;                 // clear distance
  }

  recordAccelRegisters();
    recordGyroRegisters();
    printData();
    delay(100);

//  Serial.println(SPEED);
}

void setupMPU(){
  Wire.beginTransmission(0b1101000); //This is the I2C address of the MPU (b1101000/b1101001 for AC0 low/high datasheet sec. 9.2)
  Wire.write(0x6B); //Accessing the register 6B - Power Management (Sec. 4.28)
  Wire.write(0b00000000); //Setting SLEEP register to 0. (Required; see Note on p. 9)
  Wire.endTransmission();  
  Wire.beginTransmission(0b1101000); //I2C address of the MPU
  Wire.write(0x1B); //Accessing the register 1B - Gyroscope Configuration (Sec. 4.4) 
  Wire.write(0x00000000); //Setting the gyro to full scale +/- 250deg./s 
  Wire.endTransmission(); 
  Wire.beginTransmission(0b1101000); //I2C address of the MPU
  Wire.write(0x1C); //Accessing the register 1C - Acccelerometer Configuration (Sec. 4.5) 
  Wire.write(0b00000000); //Setting the accel to +/- 2g
  Wire.endTransmission(); 
}

void recordAccelRegisters() {
  Wire.beginTransmission(0b1101000); //I2C address of the MPU
  Wire.write(0x3B); //Starting register for Accel Readings
  Wire.endTransmission();
  Wire.requestFrom(0b1101000,6); //Request Accel Registers (3B - 40)
  while(Wire.available() < 6);
  accelX = Wire.read()<<8|Wire.read(); //Store first two bytes into accelX
  accelY = Wire.read()<<8|Wire.read(); //Store middle two bytes into accelY
  accelZ = Wire.read()<<8|Wire.read(); //Store last two bytes into accelZ
  processAccelData();
}

void processAccelData(){
  gForceX = accelX / 16384.0;
  gForceY = accelY / 16384.0; 
  gForceZ = accelZ / 16384.0;
}

void recordGyroRegisters() {
  Wire.beginTransmission(0b1101000); //I2C address of the MPU
  Wire.write(0x43); //Starting register for Gyro Readings
  Wire.endTransmission();
  Wire.requestFrom(0b1101000,6); //Request Gyro Registers (43 - 48)
  while(Wire.available() < 6);
  gyroX = Wire.read()<<8|Wire.read(); //Store first two bytes into accelX
  gyroY = Wire.read()<<8|Wire.read(); //Store middle two bytes into accelY
  gyroZ = Wire.read()<<8|Wire.read(); //Store last two bytes into accelZ
  processGyroData();
}

void processGyroData() {
  rotX = gyroX / 131.0;
  rotY = gyroY / 131.0; 
  rotZ = gyroZ / 131.0;
}

void printData() {
//  Serial.println("Gyro (deg)");
//  Serial.println(" X=");
//  Serial.println(rotX);
//  Serial.print(" Y=");
//  Serial.print(rotY);
//  Serial.print(" Z=");
//  Serial.print(rotZ);
//  Serial.print(" Accel (g)");
//  Serial.print(" X=");
//  Serial.print(gForceX);
//  Serial.print(" Y=");
  Serial.print(gForceY); Serial.print ("   "); Serial.println(SPEED);
//  Serial.print(" Z=");
//  Serial.println(gForceZ);
}
