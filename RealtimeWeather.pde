 //<>//
String nowWeather="";
String temp="";
JSONObject obj;

void StartWeatherThread()
{
  thread("ThreadGetWeatherInfo");
}

int GetTem()
{
  return int(temp);
}

int GetWeatherType()
{
  int t =0;
  if (nowWeather.contains("晴"))
  {
    t=1;
  } else if (nowWeather.contains("雨"))
  {
    t=3;
  } else // if (nowWeather.contains("云")||nowWeather.contains("雾")||nowWeather.contains("阴")|| nowWeather.contains("霾"))
  {
    t=2;
  }
  return t;
}

void ParseJsonWeatherData()
{
  obj = loadJSONObject(cityWeaetherUrl);
  //println(obj);
  JSONArray arry=obj.getJSONArray("results");
  //println(arry);
  JSONObject results=arry.getJSONObject(0);
  //println(results);
  JSONObject now=results.getJSONObject("now");
  // println(now);
  nowWeather=now.getString("text");
  temp=now.getString("temperature");
  println("state =", nowWeather);
  println("tmp =", temp);
}

void ThreadGetWeatherInfo()throws InterruptedException
{
  while (true)
  {
    try {
      ParseJsonWeatherData();
    }
    catch(Exception e)
    {
      println("get weather exception!");
    }
    finally {
    }
    Thread.sleep(60000);
  }
}


int BAX=0;
int BAY=4;

ENumber TmpEnumber0=new ENumber(BAX, BAY);
ENumber TmpEnumber1=new ENumber(BAX+6, BAY);

void ResetTemp()
{
  BAX=0;
  BAY=4;
}
void TempUpdate()
{
  if (frameCount%5!=0)
  {
    return;
  }
  zeroArray();
  BAX+=1;
  if (BAX==32)
    BAX=0;
  if (BAY==16)
    BAY=4;
  int itemp=GetTem();
  //itemp=-2;
  int _1=itemp/10;
  int _2=itemp%10;

  if (itemp>=0)
  {
    if (itemp>=10)
    {
      TmpEnumber0.matchNum(abs(_1));//十位数
      TmpEnumber0.setPos(BAX, BAY);
      TmpEnumber0.FlushToAry();
      TmpEnumber1.matchNum(abs(_2));//个位数
      TmpEnumber1.setPos(BAX+6, BAY);
      TmpEnumber1.FlushToAry();
    } else
    {
      TmpEnumber1.setPos(TmpEnumber0.curX, BAY);
      TmpEnumber1.matchNum(abs(_2));//个位数
      TmpEnumber1.FlushToAry();
    }
  } else //如果是负的温度，如果是一位数
  {
    int signOffX=BAX;
    int signOffY=BAY+4;
    if (itemp>-10)//-1~-9
    {
      for (int x=0; x<4; x++)
      {
        if (signOffY >= 0&& signOffY < 16 && signOffX+x < 32 && signOffX+x >= 0)
        {
          G_Array[signOffY][signOffX+x]=NegativeSignAry[x];
        }
      }

      TmpEnumber1.setPos(signOffX+5, BAY);
      TmpEnumber1.matchNum(abs(_2));//个位数
      TmpEnumber1.FlushToAry();
    }
     else//-10°以下
    {
      for (int x=0; x<4; x++)
      {
        if (signOffY>=0&& signOffY<16 && signOffX<32 &&signOffX>=0)
        {
          G_Array[signOffY][signOffX+x]=NegativeSignAry[x];
        }
      }
      TmpEnumber0.setPos(signOffX+5, BAY);
      TmpEnumber0.matchNum(abs(_1));//十位数
      TmpEnumber0.FlushToAry();
      TmpEnumber1.setPos(TmpEnumber0.curX+6, BAY);
      TmpEnumber1.matchNum(abs(_2));//个位数
      TmpEnumber1.FlushToAry();
    }
  }

  // 摄氏度℃
  int offxC=TmpEnumber1.curX+6;
  int offyC=BAY;
  for (int y=offyC; y<offyC+9; y++)
  {
    for (int x=offxC; x<offxC+8; x++)
    {
      if (y>=0&& y<16 && x<32 &&x>=0)
        G_Array[y][x]=TempSignArray[y-offyC][x-offxC];
    }
  }
}

final int wea_offY=1;
final int wea_offx=8;
int inb=1;
int ina=4;
int dive=10;
int[][] ar=new int [15][15];

void WeatherUpdate(int type)
{
  final int _h=Sun.length;//15
  final int _w=Sun[0].length;//15
  if (type==1) dive=1;
  else if (type==2) dive=30;
  else if (type==3) dive=5;
  if (frameCount%(dive)==0)
  {
    inb=1-inb;
    ina=(ina+1)%5;
    if (type==1)
    {
      int[][] sunRotateArray = rotateArray(Sun, frameCount*3%360);
      ar=sunRotateArray;
    } else if (type==2)
    {
      if (inb==0)
        ar=Cloud;
      else if (inb==1)
        ar=Cloud2;
    } else if (type==3)
    {
      if (ina==0)
        ar=Rain;
      else if (ina==1)
        ar=Rain2;
      else if (ina==2)
        ar=Rain3;
      else if (ina==3)
        ar=Rain4;
      else if (ina==4)
        ar=Rain5;
    }
  }
  for (int y=wea_offY; y<wea_offY+_h; y++)
  {
    for (int x=wea_offx; x<wea_offx+_w; x++)
    {
      G_Array[y][x]=ar[y-wea_offY][x-wea_offx];
    }
  }
}

int[][] rotateArray(int[][] input, int degree)
{
  int rows = input.length;
  int cols = input[0].length;
  int centerX = cols / 2;
  int centerY = rows / 2;
  int[][] rotated = new int[rows][cols];

  double radians = Math.toRadians(degree); // 将角度转换为弧度
  double cos30 = Math.cos(radians);
  double sin30 = Math.sin(radians);

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      int x = (int) (cos30 * (j - centerX) - sin30 * (i - centerY) + centerX);
      int y = (int) (sin30 * (j - centerX) + cos30 * (i - centerY) + centerY);

      if (x >= 0 && x < cols && y >= 0 && y < rows) {
        rotated[y][x] = input[i][j];
      }
    }
  }
  return rotated;
}

int[] NegativeSignAry={ 1, 1, 1, 1};
int[][] TempSignArray={
  {1, 1, 0, 0, 0, 0, 0, 0, 0},
  {1, 1, 0, 1, 1, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 1, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 1, 0, 0},
  {0, 0, 0, 1, 1, 1, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0}
};

int[][] Sun2={

  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

};
int[][] Sun={
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0},
  {1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

};


int[][] Cloud={
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};
int[][] Cloud2={
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
  {0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
  {0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};
int[][] Rain={
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0},
  {0, 0, 1, 0, 0, 0, 9, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};
int[][] Rain2={
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0},
  {0, 0, 1, 0, 0, 0, 9, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};
int[][] Rain3={
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0},
  {0, 0, 1, 0, 0, 0, 9, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0},
};
int[][] Rain4={
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0},
  {0, 0, 1, 0, 0, 0, 9, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0},
};
int[][] Rain5={
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0},
  {0, 0, 1, 0, 0, 0, 9, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};
