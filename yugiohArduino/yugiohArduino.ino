#define PIN 15
int pin[PIN];

void setup() {
  for (int i=0;i<PIN;i++) {
    pin[i]=i+2;
  }

  for (int i=0;i<PIN;i++) {
    pinMode(pin[i], INPUT_PULLUP);
  }
  //シリアル通信開始
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()>0) {
    for (int i=0;i<10;i+=2) {
      if (digitalRead(pin[i])==HIGH)Serial.print("1");
      else if(digitalRead(pin[i+1])==HIGH)Serial.print("2");
      else Serial.print("0");
      Serial.print(",");
    }
    for(int i=10;i<PIN-1){
      if (digitalRead(pin[i])==HIGH)Serial.print("1");
      else Serial.print("0");
    }
    if (digitalRead(pin[PIN-1])==HIGH)Serial.println("1");
    else Serial.println("0");
    Serial.read();
  }
}

