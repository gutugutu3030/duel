#define PIN 10
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
    for (int i=0;i<PIN-1;i++) {
      if (digitalRead(pin[i])==HIGH)Serial.print("1");
      else Serial.print("0");
      Serial.print(",");
    }
    if (digitalRead(pin[PIN-1])==HIGH)Serial.println("1");
    else Serial.println("0");
    Serial.read();
  }
}

