int ingPin = 2;
int pmtPin = 3;
int buzzerPin = 4;
int val;

//IR stuff
int IR_OUT = 13;
int debug = 1;
int start_bit = 2000;		//Start bit threshold (Microseconds)
int bin_1 = 1200;			//Binary 1 threshold (Microseconds)
int bin_0 = 600;			//Binary 0 threshold (Microseconds)
byte power_off = 0x7A;
byte power_toggle = 0x54;//B1010100
byte array_signal[] = {0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0};
byte time_up = 5;
byte time_down = 12;
byte value_decode1 = 0;
byte value_decode2 = 0;
int delay_value = 600;

void setup()
{
  pinMode(ingPin, OUTPUT);
  pinMode(pmtPin, OUTPUT);
  pinMode(buzzerPin, OUTPUT);
  pinMode(IR_OUT, OUTPUT);
  Serial.begin(9600);
  Serial.flush();
}

void loop()
{
  if (Serial.available() > 0)
  {
    val = Serial.read();

    while(val != 78) {
      if(val == 90) {
        togglePower(power_off);
        val='N';
      } else if(val == 65) {
        togglePower(power_toggle);
        val='N';
      } 
      Serial.println("b4 buzzer ");
      Serial.println(val);
      if(val > 128) { // build failure
        digitalWrite(buzzerPin, HIGH);
        delay(200);
        digitalWrite(buzzerPin, LOW);
        delay(200);
        digitalWrite(buzzerPin, HIGH);
        delay(200);
        digitalWrite(buzzerPin, LOW);
        val = val - 64;
      } else if (val > 96) {
        digitalWrite(buzzerPin, HIGH);
        delay(400);
        digitalWrite(buzzerPin, LOW);
        val = val - 32;
      }
      Serial.println(val);

      if(val == 73) {
      digitalWrite(ingPin, HIGH);
      } else if(val == 80) {
        digitalWrite(pmtPin, HIGH);
      } else if(val == 66) {
        digitalWrite(ingPin, HIGH);
        digitalWrite(pmtPin, HIGH);
      } 

      delay(300);
      digitalWrite(ingPin, LOW);
      digitalWrite(pmtPin, LOW);
      delay(300);

      if (Serial.available() > 0) {
      val = Serial.read();    
      }
    }
    while (val == 78) {
      val = Serial.read();
      digitalWrite(ingPin, LOW);
      digitalWrite(pmtPin, LOW);
      delay(1000);
    }
  } 
}

void togglePower(int code) {
  Serial.println("power ... ");
  for(int count=0; count<3;count++) {
    command_decode(code);
    signal_send();
  }
  return;
}

void command_decode(int binary_command) {  //less space than five arrays)
  value_decode1 = binary_command;
  for (int i = 6; i > -1; i--) {
    value_decode2 = value_decode1 & B1;
    if (value_decode2 == 1) {
      array_signal[i] = 1;
    }
    else {
      array_signal[i] = 0;
    }
    value_decode1 = value_decode1 >> 1;
  }
}

void carrier_make() {
  digitalWrite(IR_OUT, HIGH);
  delayMicroseconds(time_up);
  digitalWrite(IR_OUT, LOW);
  delayMicroseconds(time_down);
}

void signal_send() {
  for (int i = 0; i < 90; i++) {//start the message with a 2.4 ms time up
    carrier_make();
  }
  for (int a = 0; a < 12; a++) {
    delayMicroseconds(delay_value);//time down is always 0.6 ms
    if (array_signal[a] == 1) {
      for (int i = 0; i < 45; i++) {//"1" is always 1.2 ms high
        carrier_make();
      }
    }
    else {
      for (int i = 0; i < 22; i++) {//"0" is always 0.6 ms high
        carrier_make();
      }
    }
  }
  delay(25);
}