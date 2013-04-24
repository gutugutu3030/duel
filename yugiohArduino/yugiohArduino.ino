/*
今回はモンスターゾーンのスイッチだけ監視
*/

#define PIN 10

int pin[PIN];

void setup() {
  for (int i=0;i<PIN;i++) {
    pin[i]=i+3;
  }

  for (int i=0;i<PIN;i++) {
    pinMode(pin[i], INPUT_PULLUP);
  }
  //シリアル通信開始
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()>0) {
    Serial.read();
    delay(500);//通信の頻度を下げないと攻撃守備判定をミスる
    for (int i=0;i<10;i+=2) {
      if(digitalRead(pin[i])&&digitalRead(pin[i+1]))Serial.print("2,");
      else if(digitalRead(pin[i]))Serial.print("1,");
      else Serial.print("0,");
    }
    for(int i=10;i<20){
      Serial.print("0,");
    }
    Serial.println();
  }
}

