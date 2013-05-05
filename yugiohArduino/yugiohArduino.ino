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
    String str="";
    for (int i=4;i<13;i+=2) {
      if(digitalRead(pin[i])==LOW&&digitalRead(pin[i+1])==LOW)str=str+"2";//Serial.print(2);
      else if(digitalRead(pin[i])==LOW)str=str+"1";//Serial.print(1);
      else str=str+"0";//Serial.print(0);
      str=str+",";//Serial.print(",");
    }  
    /*
    for(int i=10;i<20;i++){
      Serial.print("0,");
    }
    */
    Serial.println(str);
    
  }
}

