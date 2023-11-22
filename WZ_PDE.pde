import java.util.Arrays; //<>//
import java.io.*;
import spout.*;
import processing.net.*;
import hypermedia.net.*;

Server tcpServertoUnity;
Client tcpClienttoUnity;
Spout spout;

int g_light_color;

color[] unit_fill_colors=new color[512];
float[] U3dDepth=new float[512];
int[] PhyDepth=new int[512];

StringBuffer strBuf = new StringBuffer();
String InputStringfromunity;
String buttonExcutedInfo="666";
float buttontimestamp=0;
int InfoType=0;
int ProgState;
int GameType=0;//0 凹进去 1 凸出来 2 平的

PFont font50;
PFont font30;

boolean IsReady=false;
boolean bAutoRun=false;
boolean bHasZeroed=false;
float changeNextInfoTimestamp;
void setup()
{
  size(1920, 960, P2D);
  //surface.setLocation(0, 0);
  frameRate(15);
  textAlign(LEFT, CENTER);
  font50=createFont("abc.ttf", 50);
  font30=createFont("abc.ttf", 30);
  changeNextInfoTimestamp=getAppElapsedTimef();
  buttontimestamp=getAppElapsedTimef();

  tcpServertoUnity = new Server(this, portOnUnity);
  spout = new Spout(this);
  loadProgramConfig();
  LoadUSRIpConfig();
  GetDaylogFile();
  LoadZEROParams();
  RobotMsg("控制程序启动", false);
  InitLEDnumbers();
  ResetColorArray();
  InitLigthModule();
  InitUI() ;
  InitialMotor();

  ProgState=STATE_DEBUG;//STATE_DEBUG STATE_TIME_STANDBY

  if (ProgState==STATE_DEBUG)
  {
    cp5.show();
  }

  StartWeatherThread();
}

int startX=(1920-960)/2;
int startY=(960-480)/2;
int Ra=960/32;

void draw()
{
  RecvTcpmsg();//从unity读取色值-视频部分

  if (ProgState==STATE_TIME_STANDBY)//日期-时间-天气-温度
  {
    if (InfoType==0)
    {
      LEDDateUpdate();
      if (getAppElapsedTimef()-changeNextInfoTimestamp>12.3f)
      {
        zeroArray();
        ResetOriginPos();
        InfoType=1;
        changeNextInfoTimestamp=getAppElapsedTimef();
      }
    } else if (InfoType==1)//时间
    {
      LEDTimeUpdate();
      if (getAppElapsedTimef()-changeNextInfoTimestamp>15.0f)
      {
        zeroArray();
        InfoType=2;
        changeNextInfoTimestamp=getAppElapsedTimef();
      }
    } else if (InfoType==2)//天气
    {
      //WeatherUpdate(1);
      WeatherUpdate(GetWeatherType());
      if (getAppElapsedTimef()-changeNextInfoTimestamp>5.5f)
      {
        zeroArray();
        InfoType=3;
        ResetTemp();
        changeNextInfoTimestamp=getAppElapsedTimef();
      }
    } else if (InfoType==3)//温度
    {
      TempUpdate();
      if (getAppElapsedTimef()-changeNextInfoTimestamp>5.0f)
      {
        zeroArray();
        InfoType=0;
        ResetOriginPos();
        changeNextInfoTimestamp=getAppElapsedTimef();
      }
    }
    DarwtoPanel();
    clearRgbsArrays(time_color_bg);
    for (int n=0; n<512; n++)
    {
      PhyDepth[n]= LogicZeroPos[n];
    }
    IntList il= getArrayDetail();
    for (int i=0; i<512; i++)
    {
      U3dDepth[i]= 0;
      LightColors[i]=0;
    }
    for (int i : il)
    {
      U3dDepth[i]= 0.65f;
      PhyDepth[i]= LogicZeroPos[i]+int(MAX_DEPTH*0.65f);//伸出0.5
      LightColors[i]=time_color_fg;
      CalcLightRGBs(i);
    }
    UpdateToMotorActualDepth();
    UpdateToLightActualColor();
    SendCylinderStateInfoToUnity();
  } else if (ProgState==STATE_VEDEO_MAPPING)//动画
  {
    push();
    background(50);
    clearRgbsArrays();
    int id=0;
    for (int y=startY+Ra/2; y<startY+480; y+=Ra)
    {
      for (int x=startX+Ra/2; x<startX+960; x+=Ra)
      {
        CalcLightRGBs(id);
        PhyDepth[id]= LogicZeroPos[id]+int(MAX_DEPTH*alphaf[id]);
        fill(LightColors[id]);
        ellipse(x, y, Ra/1.2f, Ra/1.2f);
        id++;
      }
    }
    pop();
    //发送指令到硬件
    UpdateToMotorActualDepth();
    UpdateToLightActualColor();
  }//end of if (show video)
  else if (ProgState==STATE_SLOW) //减速
  {
    if ( !bHasZeroed && getAppElapsedTimef()-slowTimeStamp>0.6f)
    {
      bHasZeroed=true;
      GoboLogiZero();
      slowTimeStamp=getAppElapsedTimef();
      println("已归零");
    }
    if (bHasZeroed && getAppElapsedTimef()-slowTimeStamp>1.2f)
    {
      ProgState=STATE_INTERACTIVE;
      GameType=0;
      cp5.hide();
      ChangeMotorAcc(1000);
      println("进入game0");
    }
  } else if (ProgState==STATE_INTERACTIVE) //互动部分
  {
    if (bHasZeroed)
    {
      push();
      if (spout.receiveTexture())
      {
        spout.drawTexture();
        InteractiveLogic(GameType);
      }
      pop();
    }
  } else if (ProgState==STATE_DEBUG)//设置界面
  {
    DebugInfoDisplay();
  } else if (ProgState==STATE_TEST)  //----测试模式
  {
    if (getAppElapsedTimef()-test_run_time>test_run_total_time)
    {
      AppendLog("测试结束...");
      RobotMsg("测试结束", true);
      ProgState=0;
    }
    if (getAppElapsedTimef()-test_timeStamp>test_interval_time)
    {
      push();
      background(50);
      timerLabel.setValue(testTimecontrollerTImer1.toString());
      timerLabel.draw(this);
      timerLabel.setPosition(1340, 208);
      test_timeStamp=getAppElapsedTimef();
      run_test_once();
      clearRgbsArrays();
      int id=0;
      for (int y=startY+Ra/2; y<startY+480; y+=Ra)
      {
        for (int x=startX+Ra/2; x<startX+960; x+=Ra)
        {
          CalcLightRGBs(id);
          PhyDepth[id]=int(alphaf[id]*MAX_DEPTH);
          fill(LightColors[id]);
          ellipse(x, y, Ra/1.2f, Ra/1.2f);
          id++;
        }
      }
      pop();
      UpdateToMotorActualDepth();
      UpdateToLightActualColor();
    }
  }

  pushStyle();
  fill(150, 255, 76);
  textFont(font30);
  text("CurrentState : "+str(ProgState)+"\nfps="+nf(frameRate, 0, 2), width-300, height-100);

  if (getAppElapsedTimef()-buttontimestamp<1.0f)
  {
    text(buttonExcutedInfo, width-350, 40);
  }
  popStyle();
}//end of draw()d of draw()
