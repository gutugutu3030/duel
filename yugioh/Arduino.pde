class Arduino{
  int status[]=new int[10];
  //0:無し　1:セット　2:発動
  Arduino(){
  }
  void serial(String str){
    if(str!=null){
    //改行記号を取り除く
    str=trim(str);
    //コンマで区切ってデータを分解、整数化
    int data[]=int(split(str,','));
    //println("length:"+data.length+" "+Arrays.toString(data));
    if(data.length>=5){
      //データの値を代入
      for(int i=0;i<5;i++){
        status[i]=data[i];
      }
      //合図用データ送信
      port.write(65);
      //println("read");
    }
  }
  }
  int load(int n){
    //if(n==0)return 1;
    return status[n];
  }
}
