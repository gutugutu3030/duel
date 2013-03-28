//デュエルディスク関連の設定はこのクラス

class Disc {
  int state[]=new int[10];//0:なし1:待機（セット状態）2:？（攻撃表示）3:mqo表示（フィールドに存在）4:破壊　0~4:モンスター 5~9:魔法・トラップ
  int cardset;//一番最後に待機状態になったカードを記録 -1:なし
  int actuatetime[]=new int[10];//発動モーション
  int breaktime[]=new int[10];//破壊モーション
  Disc() {
    for (int i=0;i<10;i++) {
      state[i]=actuatetime[i]=breaktime[i]=0;
    }
    cardset=-1;
  }
  void update() {
    for (int i=0;i<5;i++) {
      //モンスターゾーン
      int pin=arduino.load(i);
      switch(pin) {
      case 0:
        BreakingCard(i);
        break;
      case 1://攻撃表示
        SettingCard(i);
        break;
      case 2://守備表示
        SettingCard(i);
        break;
      }
      switch(state[i]) {
      case 1:
        if (cardset==-1)cardset=i;
        break;
      case 2:
        if (actuatetime[i]<10)actuatetime[i]++;
        else state[i]=3;
        break;
      case 4:
        if (breaktime[i]<10)breaktime[i]++;
        else ResetState(i);
        break;
      }
    }
    for (int i=5;i<10;i++) {
      //魔法トラップ・ゾーン
      int pin=arduino.load(i);
      switch(pin) {
      case 0:
        BreakingCard(i);
        break;
      case 1:
        SettingCard(i);
        break;
      case 2:
        ActuatingCard();
        break;
      }
      switch(state[i]) {
      case 1:
        if (cardset==-1)cardset=i;
        break;
      case 2:
        if (actuatetime[i]<10)actuatetime[i]++;
        else state[i]=3;
        break;
      case 4:
        if (breaktime[i]<10)breaktime[i]++;
        else ResetState(i);
        break;
      }
    }
  }
  void SettingCard(int n) {
    if (state[n]!=0)return;
    state[n]=1;
    if (n<5)cardset=n;
    setSE.rewind();
    setSE.play();
  }
  void ActuatingCard() {
    int n=cardset;
    state[n]=2;
    actuatetime[n]=0;
    if (disc.cardset<=4) {
      summonSE.rewind();
      summonSE.play();
    }
    else {
      effectSE.rewind();
      effectSE.play();
    }
    disc.cardset=-1;
  }
  void SummonCard(int n) {
    if (state[n]==3)return;
    state[n]=3;
  }
  void BreakingCard(int n) {
    if (state[n]==0||state[n]==4)return;
    state[n]=4;
    breaktime[n]=0;

    breakSE.rewind();
    breakSE.play();
  }
  void ResetState(int n) {
    state[n]=0;
    breaktime[n]=0;
    actuatetime[n]=0;
  }
  boolean IfSet(int n) {//n=0,1,...,19
    if (n<0)return false;
    if (state[n]==1)return true;
    return false;
  }
  boolean IfActuating(int n) {
    if (state[n]==2)return true;
    return false;
  }
  boolean IfSummon(int n) {
    if (state[n]==3)return true;
    return false;
  }
  boolean IfBreaking(int n) {
    if (state[n]==4)return true;
    return false;
  }
  void draw(GL gl) {
    for (int i=0;i<10;i++) {
      gl.glPushMatrix();
      int k=i%5;
      gl.glTranslatef(0, 0, (k*70-140)*BattleScale);

      if (i<5) {
        gl.glTranslatef(150*BattleScale, 0, 0);
      }
      else if (i<10) {
        gl.glTranslatef(60*BattleScale, 0, 0);
      }
      switch(state[i]) {
      case 1:
        gl.glColor3f(0.50, 0, 0);
        gl.glBegin(gl.GL_POLYGON);
        gl.glVertex3f(43*BattleScale, 0, 30*BattleScale);
        gl.glVertex3f(-43*BattleScale, 0, 30*BattleScale);
        gl.glVertex3f(-43*BattleScale, 0, -30*BattleScale);
        gl.glVertex3f(43*BattleScale, 0, -30*BattleScale);
        gl.glEnd();
        break;
      case 2:
        gl.glTranslatef(43*BattleScale, 0, 0);
        if (disc.actuatetime[i]<=6) {
          gl.glRotatef(-disc.actuatetime[i]*15, 0, 0, 1);
          gl.glColor3f(0.50, 0, 0);
          gl.glBegin(gl.GL_POLYGON);
          gl.glVertex3f(0, 0, 30*BattleScale);
          gl.glVertex3f(-86*BattleScale, 0, 30*BattleScale);
          gl.glVertex3f(-86*BattleScale, 0, -30*BattleScale);
          gl.glVertex3f(0, 0, -30*BattleScale);
          gl.glEnd();
        }
        else {
          gl.glRotatef(-90, 0, 0, 1);
          gl.glColor3f(0.50, 0, 0);
          gl.glBegin(gl.GL_POLYGON);
          gl.glVertex3f(0, 0, 30*BattleScale);
          gl.glVertex3f(-86*BattleScale, 0, 30*BattleScale);
          gl.glVertex3f(-86*BattleScale, 0, -30*BattleScale);
          gl.glVertex3f(0, 0, -30*BattleScale);
          gl.glEnd();
        }
        break;
      case 3:
        //println("i="+i);
        if (i<5) {
          //println("OK!");
          gl.glRotatef(90, 0, 1, 0);
          md[i].draw();
        }
        else {
          //魔法トラップの時は何もしない
          gl.glRotatef(-90, 0, 0, 1);
          gl.glColor3f(0.50, 0, 0);
          gl.glBegin(gl.GL_POLYGON);
          gl.glVertex3f(0, 0, 30*BattleScale);
          gl.glVertex3f(-86*BattleScale, 0, 30*BattleScale);
          gl.glVertex3f(-86*BattleScale, 0, -30*BattleScale);
          gl.glVertex3f(0, 0, -30*BattleScale);
          gl.glEnd();
        }
        break;
      case 4:
        break;
      }
      gl.glPopMatrix();
    }
  }
}

