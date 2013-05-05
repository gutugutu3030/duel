import codeanticode.gsvideo.*;
import jp.nyatla.nyar4psg.*;
import javax.media.opengl.*;
import processing.opengl.*;
import jp.nyatla.kGLModel.*;
import jp.nyatla.kGLModel.contentprovider.*;
import processing.serial.*;
import ddf.minim.*;  //minimライブラリのインポート

Minim minim;  //Minim型変数であるminimの宣言
AudioPlayer setSE, breakSE, summonSE, effectSE;		//サウンドデータ格納用の変数

int cardnum=1;//読み込みたいモデルの数＝使うマーカーの数

Serial port;
GSCapture cam;
MultiMarker nya;
MultiMarker cardar;
int id[];


float BattleScale=1.0;//フィールドの大きさ


//MultiMarker monmark[]=new MultiMarker[cardnum];
String card[]=new String[cardnum];
float cardscale[]=new float[cardnum];

KGLModelData md[]=new KGLModelData[20];//ディスクでの最大表示数
ContentProvider cp;//コイツは1つでことたりる

//ディスク
Arduino arduino=new Arduino();
Disc disc=new Disc();



void setup() {
  size(640, 480, OPENGL);

  String portName = Serial.list()[0];
  port = new Serial(this, portName, 9600);
  port.clear();
  port.write(65);

  for (int i=0;i<cardscale.length;i++) {
    cardscale[i]=1;
  }


  minim = new Minim(this);  //初期化
  setSE = minim.loadFile("SE/set.wav", 512);
  breakSE = minim.loadFile("SE/break.wav", 512);
  summonSE = minim.loadFile("SE/summon.wav", 512);
  effectSE = minim.loadFile("SE/effect.wav", 512);



  cam=new GSCapture(this, 640, 480);
  nya=new MultiMarker(this, width, height, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  nya.addNyIdMarker(0, 40);


  cardSetup();
  cam.start();
}

void draw() {
  disc.print();
  if (cam.available()==false)return;
  cam.read();
  background(0);
  nya.detect(cam);
  cardar.detect(cam);
  nya.drawBackground(cam);//frustumを考慮した背景描画
  cardar.drawBackground(cam);//frustumを考慮した背景描画
  disc.update();

  PGraphicsOpenGL pgl=(PGraphicsOpenGL) g;
  GL gl=pgl.beginGL();
  //カード読み取り待機
  println(""+disc.cardset);
  if (disc.cardset!=-1&&(disc.state[disc.cardset]==1||disc.state[disc.cardset]==2)) {
    //監視
    
    for (int j=0;j<cardnum;j++) {
      if (cardar.isExistMarker(id[j])) {
        cp=new LocalContentProvider(this, dataPath(card[j]));
        println("召喚："+disc.cardset);
        md[disc.cardset]=KGLModelData.createGLModelPs(this, gl, null, this.cp, cardscale[j], KGLExtensionCheck.IsExtensionSupported(gl, "GL_ARB_vertex_buffer_object"), true);
        disc.ActuatingCard();
        break;
      }
    }
  }
  if (!nya.isExistMarker(0)) {
    pgl.endGL();
    return;
  }
  else {
    nya.beginTransform(0);
    //processingの行列をOpenGLで使えるようにする
    gl.glMatrixMode(gl.GL_PROJECTION);
    gl.glLoadMatrixf(convMatrixPsg2GL(((PGraphics3D)g).projection), 0);
    gl.glMatrixMode(gl.GL_MODELVIEW);
    gl.glLoadIdentity();
    gl.glScalef(1.0, -1.0, 1.0);
    gl.glMultMatrixf(convMatrixPsg2GL(((PGraphics3D)g).modelview), 0);
    //テスクチャとポリゴンの描画に関する設定
    gl.glTexEnvf(GL.GL_TEXTURE_ENV, GL.GL_TEXTURE_ENV_MODE, GL.GL_MODULATE);
    gl.glEnable(GL.GL_CULL_FACE);
    gl.glCullFace(GL.GL_FRONT);
    //光源の設定
    mySetLight(gl, 0, -100, 100);

    gl.glRotatef(90, 1, 0, 0);//立たせる
    gl.glRotatef(180, 0, 1, 0);//正面を向かせる

    //各々で違う処理は強引にswitch文へ・・・
    disc.draw(gl);
    //md.draw();
    //disc.draw();
    nya.endTransform();
  }

  pgl.endGL();
}
void mySetLight(GL gl, float x, float y, float z) {
  float[] light_diffuse= {
    0.2, 0.2, 0.2, 1.0
  };
  float[] light_specular= {
    0.3, 0.3, 0.3, 0.1
  };
  float[] light_ambient= {
    0.3, 0.3, 0.3, 1.0
  };
  float[] light_position= {
    x, y, z, 0.0
  };

  //光源パラメータの設定
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_DIFFUSE, light_diffuse, 0);
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_SPECULAR, light_specular, 0);
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_AMBIENT, light_ambient, 0);
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_POSITION, light_position, 0);
  gl.glShadeModel(gl.GL_SMOOTH);
  gl.glEnable(gl.GL_LIGHT0);
  gl.glEnable(gl.GL_LIGHTING);
}
float[] convMatrixPsg2GL(PMatrix3D mat_psg) {
  float[] mat_gl=new float [16];
  PMatrix3D mat=mat_psg.get();
  mat.transpose();
  mat.get(mat_gl);
  return mat_gl;
}

void cardSetup() {
  cardar=new MultiMarker(this, width, height, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  //カードの登録をするよ
  //マーカーを使えるようにする
  id=new int[1];
  card[0]="ninja.mqo";//試しに攻撃力100守備力200の忍者を登録
  for (int i=0;i<1;i++) {
    id[i]=cardar.addNyIdMarker(1+i, 40);
  }
}

void serialEvent(Serial p) {
  arduino.serial(port.readStringUntil(10));//Arduinoからの情報を得る
}

