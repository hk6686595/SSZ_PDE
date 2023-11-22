 //<>//
void mousePressed()
{
  if (mouseButton == CENTER)
  {
  } else if (mouseButton == RIGHT)
  {
  } else if (mouseButton == LEFT)
  {
    setABPosByMouseClickUI();
  }
}

void keyPressed()
{
  if (key==27)
  {
    if (!ifQuitPress)
    {
      ifQuitPress=true;
      exit();
    }
  }
  if (key==' ')
  {
    lastRecvHexStringTexA.setText( lastRecvHexStringTexA.getText()+g_strLogBuffer.toString());
    FlushLogFile();
  }
}
boolean ifQuitPress=false;
boolean ifQuitPress2=false;
void exit()
{
  if (!ifQuitPress2)
  {
    ifQuitPress2=true;
    RobotMsg("控制程序退出", false);
    GotoLogiZero();
    CloseAllLights();
    FlushLogFile();
    DisconnectUnityTcp();
    super.exit();
  }
}

void DisconnectUnityTcp()
{
  //断开与unity的连接
  if (tcpServertoUnity!=null && tcpClienttoUnity!=null)
  {
    tcpServertoUnity.disconnect(tcpClienttoUnity);
    tcpServertoUnity.stop();
    tcpServertoUnity.dispose();
  }
}

void DebugInfoDisplay()
{
  push();
  background(20);
  noFill();
  rect(startX, startY, 960, 480);
  int id=0;
  //画点
  for (int y=startY+Ra/2; y<startY+480; y+=Ra)
    for (int x=startX+Ra/2; x<startX+960; x+=Ra)
    {
      int _col=id%32;
      int _row=id/32;
      int _index=_row*32+_col;
      //根据32*16行列转换得到4*4的行列
      int secCol=_col/8;
      int secRow=_row/4;
      int seqNormalSeqID=secRow*4+secCol;
      int offsetcolOfgrid=seqNormalSeqID%4;
      int offsetrowOfgrid=seqNormalSeqID/4;
      int offsetColx8=offsetcolOfgrid*8;
      int offsetRowx4=offsetrowOfgrid*4;
      int _col_=_col-offsetColx8;
      int _row_=_row-offsetRowx4;
      int xx=_col_;
      int yy=_row_;
      int seq=xx/2*4+xx%2*2+yy/2*16+yy%2;
      fill(unit_fill_colors[_index]);
      circle(x, y, Ra);
      fill(0, 255, 0);
      text(str(seq+1), x, y-8);
      fill(255, 255, 0);
      text(str(id+1), x, y+5);

      id++;
    }
  text(str(mouseX)+" , "+str(mouseY), 40, height-10);
  pop();
  //画框
  push();
  textSize(35);
  textAlign(CENTER, CENTER);
  for (int n=0; n<16; n++)
  {
    int xx=n%4;
    int yy=n/4;
    noFill();
    stroke(0, 255, 0);
    rect(startX+xx*960/4, startY+yy*480/4, 960/4, 480/4);
    int rIndex=xx+yy*4;
    fill(255, 0, 0);
    text(str(rIndex+1), startX+xx*960/4+960/4/2, startY+yy*480/4+480/4/2);
  }
  pop();
  //扫描指令发送完毕后1秒视为超时，处理相关判断
  //扫描顺序 1.扫描读使能状态2.机械归零3.写使能4.逻辑归零5.扫描高低位，检查是否在逻辑零点
  if (bScanOverFlag && getAppElapsedTimef()-scanTimf>1)//视为超时，不在接受数据
  {
    bScanOverFlag=false;
    AppendLog("超时，不在接受数据");
    if (g_ScanMode==3 )//扫描读使能数量不足
    {
      if (bAutoRun)
      {
        if (GetFeedbackTrueCount<EffectNum )
        {
          AppendLog("扫描读使能数量不足");
          //先读使能，如果不足，则需要归零，在使能
          g_ScanMode=0;
          thread("scan");
          AppendLog("扫描读使能数量不足,立刻执行机械归零操作");
          return;
        } else
        {
          buttonExcutedInfo="g_ScanMode==3,逻辑归零 按钮执行";
          buttontimestamp=getAppElapsedTimef();
          g_ScanMode=99;
          GotoLogiZero();
          bScanOverFlag=true;
          scanTimf=getAppElapsedTimef();
          return;
        }
      } else
      {
        if (GetFeedbackTrueCount<EffectNum )
        {
          AppendLog("扫描读使能数量不足");
          gScanModeLabel.setText("扫描读使能数量不足");
        }
      }
    }
    if (g_ScanMode==0 )
    {
      if (bAutoRun)
      {
        if ( GetFeedbackTrueCount<EffectNum)
        {
          AppendLog("扫描归零数量不足，无法继续");
          gScanModeLabel.setText("扫描归零数量不足，无法继续");
          RobotMsg("扫描归零数量不足，无法继续,扫描数："+GetFeedbackTrueCount, true);
          IsReady=false;
        } else
        {
          if (GetFeedbackTrueCount<500)
            RobotMsg("回到机械原点实际数量："+GetFeedbackTrueCount, false);
          g_ScanMode=6;
          thread("scan");
          AppendLog("开始写使能");
        }
        return;
      } else
      {
        if ( GetFeedbackTrueCount<EffectNum)
        {
          AppendLog("扫描归零数量不足，无法继续");
          gScanModeLabel.setText("扫描归零数量不足");
        }
      }
    }
    if (g_ScanMode==6 )
    {
      if (bAutoRun)
      {
        RobotMsg("写使能实际数量："+GetFeedbackTrueCount, false);
        buttonExcutedInfo="逻辑归零 按钮执行";
        buttontimestamp=getAppElapsedTimef();
        GotoLogiZero();
        g_ScanMode=99;
        bScanOverFlag=true;
        scanTimf=getAppElapsedTimef()+1;//逻辑回零后等待2秒执行读取位置指令
        return;
      } else
      {
        if ( GetFeedbackTrueCount<EffectNum)
        {
          AppendLog("扫描写使能数量不足，无法继续");
          gScanModeLabel.setText("扫描归零数量不足");
        }
      }
    }
    if (g_ScanMode==99)
    {
      if (bAutoRun)
      {
        AppendLog("开始读高位");
        g_ScanMode=16;//开始读取位置
        thread("scan");
      }
      return;
    }

    if (g_ScanMode==17 && GetFeedbackTrueCount>=EffectNum)
    {
      CalcScanedPos();
      AppendLog("计算扫描之后的当前位置，并验证是否在逻辑原点");
      if (ChcekIsAllInPos())
      {
        IsReadySHowLabel.setText("所有点击就位");
        IsReadySHowLabel.setColorValue(0xff00ff00);
        Arrays.fill(unit_fill_colors, color(100));
        ProgState=STATE_TIME_STANDBY;
        ChangeMotorAcc(700);
        cp5.hide();
        //RobotMsg("全部回到逻辑原点", false);
        RobotMsg("硬件启动检测完成", false);
      } else
      {
        IsReadySHowLabel.setText("有电机不在位置！");
        IsReadySHowLabel.setColorValue(0xffff0000);
        AppendLog("有电机不在位置");
        RobotMsg("有部分电机不在逻辑零点", true);
      }
    }
    g_ScanMode=-1;
    scanModeStr="over,waiting time out!";
    gScanModeLabel.setText("当前扫描:"+scanModeStr);
  }
}

void RecvTcpmsg()
{
  tcpClienttoUnity = tcpServertoUnity.available();
  if (tcpClienttoUnity != null)
  {
    for (int n=0; n<512; n++)
    {
      LightColors[n]=color(0, 0, 0, 0);
      alphaf[n]=0.0f;
    }
    if (tcpClienttoUnity.input!=null)
    {
      InputStringfromunity = tcpClienttoUnity.readString();
      HandleUnityTcpCmd(InputStringfromunity);
    }
  }
}

import java.text.DecimalFormat;
final color white_color = #ffffff;
final color black_color = #000000;
final color red_color = #FF0000;
final color orange_color = #E3A137;
final color skyblue_color = #2D78A5;
final color cyan_color=#29E5FC;
final color plane_color=#7CD4FF;
color lerpColor = 0;
float noff=0;
float randomInterval=3.0f;
float ranTimef=0;
DecimalFormat df1 = new DecimalFormat("#0.00");

void InteractiveLogic( int game_t)
{
  int g_bgCor = game_t==1? black_color : orange_color;
  clearRgbsArrays(g_bgCor);
  loadPixels();
  int id=0;
  for (int y = 0; y < height; y += PIXEL_STEP)
  {
    for (int x = 0; x < width; x += PIXEL_STEP)
    {
      int pixind = y * width + x;
      int pix=pixels[pixind];
      float rate=brightness(pix)/255;
      if (game_t==0)//凹陷
      {
        if (rate<0.01f)
        {
          lerpColor=black_color;
          U3dDepth[id]= 0.06f;
        } else if (rate<0.5)
        {
          //float maprate=map(rate, 0.01, 0.5, 0, 1.0f);
          lerpColor =lerpColor(black_color, red_color, rate*2);
          U3dDepth[id]= rate;
        } else if (rate<1.0001f)
        {
          //float maprate=map(rate, 0.5f, 1.0f, 0, 1.0f);
          lerpColor =lerpColor(red_color, orange_color, rate);
          U3dDepth[id]= rate;
        }
      } else if (game_t==1) //凸起  --随机效果 --零星随机闪烁
      {
        if (rate<0.05f)//背景闪烁
        {
          noff+=0.0005f;
          float nrate=noise(x, y, noff);
          lerpColor=lerpColor(black_color, orange_color, nrate );
          U3dDepth[id]= 0.06f;
        } else if (rate<0.5f)
        {
          lerpColor =lerpColor(black_color, skyblue_color, rate*2f);
          U3dDepth[id]= rate;
        } else if (rate<1.0001f  )
        {
          lerpColor =lerpColor(skyblue_color, white_color, rate);
          U3dDepth[id]= rate;
        }
      } else if (game_t==2)
      {
        if (rate>0.1)//白色，
        {
          U3dDepth[id]= 0.06f;//unity 0.05，平的，颜色青色
          lerpColor=plane_color;
        } else
        {
          float nrate=noise(id, noff);
          if (nrate>0.18f) //随机生出百色柱子
          {
            U3dDepth[id]= 0.06f;//unity 0.05
            lerpColor=black_color;
          } else
          {
            U3dDepth[id]= 0.95f;//unity 0.05
            lerpColor=white_color;
          }
          if (getAppElapsedTimef()-ranTimef>randomInterval)
          {
            noff+=0.4f;
            ranTimef=getAppElapsedTimef();
          }
        }
      }
      PhyDepth[id]=LogicZeroPos[id]+int(MAX_DEPTH * rate);
      LightColors[id]=lerpColor;
      CalcLightRGBs(id);
      id++;
    } //for inner
  }//for outer
  UpdateToMotorActualDepth();
  UpdateToLightActualColor();
  SendCylinderStateInfoToUnity();
}

//把互动数据传到unity模拟器
void SendCylinderStateInfoToUnity()
{
  StringBuilder sb = new StringBuilder(15000);
  for (int i=0; i<512; i++)
  {
    sb.append(i);
    sb.append(",");
    sb.append(df1.format(U3dDepth[i]));
    sb.append(",");
    int a = (LightColors[i] >> 24) & 0xFF;
    int r = (LightColors[i] >> 16) & 0xFF;
    int g = (LightColors[i] >> 8) & 0xFF;
    int b = LightColors[i] & 0xFF;
    sb.append(a);
    sb.append(",");
    sb.append(r);
    sb.append(",");
    sb.append(g);
    sb.append(",");
    sb.append(b);
    sb.append("|");
  }
  // [length={0}]{1}
  String shead="[length="+sb.length()+"]";
  sb.insert(0, shead);
  tcpServertoUnity.write(sb.toString());
}

//tcp 解析字符串转颜色
color[]LightColors = new color[512];
float[]alphaf = new float[512];
float slowTimeStamp=0;
void HandleUnityTcpCmd(String data)
{
  if (data.length()<20)
  {
    println("Get Unity Data:", data);
  }
  if (data.contains("connected"))
  {
    if (ProgState!=STATE_TIME_STANDBY)
    {
      ProgState=STATE_TIME_STANDBY;
      changeNextInfoTimestamp=getAppElapsedTimef();
      ChangeMotorAcc(1000);
    }
    cp5.hide();
    AppendLog("get connected cmd");
  } else if (data.contains("VideoStart"))
  {
    if (ProgState!=STATE_VEDEO_MAPPING)
    {
      ProgState=STATE_VEDEO_MAPPING;
      ResetSpdAcc();
    }
    cp5.hide();
    AppendLog("get VideoStart cmd");
  } else if (data.contains("Game0"))
  {
    AppendLog("get Game0 cmd first to state_slow");
    if (ProgState!=STATE_SLOW)
    {
      ProgState=STATE_SLOW;
      slowTimeStamp=getAppElapsedTimef();
      bHasZeroed=false;
      ChangeMotorAcc(500);//进入互动时,先减速,再归零
    }
  } else if (data.contains("Game1"))
  {
    if (ProgState!=STATE_INTERACTIVE)
    {
      ProgState=STATE_INTERACTIVE;
    }
    ChangeMotorAcc(1200);
    GameType=1;
    AppendLog("get Game1 cmd");
  } else if (data.contains("Game2"))
  {
    if (ProgState!=STATE_INTERACTIVE)
    {
      ProgState=STATE_INTERACTIVE;
    }
    ChangeMotorAcc(1200);
    GameType=2;
    AppendLog("get Game2 cmd");
  } else if (data.contains("VideoOver")|| data.contains("BodyLeft") || data.contains("Gameover") )
  {
    ProgState=STATE_TIME_STANDBY;
    ChangeMotorAcc(1200);
    cp5.hide();
    zeroArray();
    changeNextInfoTimestamp=getAppElapsedTimef();
    //InfoType=(InfoType+1)%3;
    InfoType=0;
    AppendLog("get VideoOver || BodyLeft || Gameover cmd,back to standby");
  }
   else//否则时视频解析的数据
  {
    String[] strList = split(data, '|');
    for (int ndx=0; ndx<strList.length; ndx++)
    {
      String[] strList2=split(strList[ndx], '-');
      if (strList2.length==2)
      {
        String str1=strList2[0];
        int seq=int(str1);
        String str2=strList2[1];
        String[] floats=split(str2, ',');
        if (floats.length == 4)
        {
          float r=float(floats[0]);
          float g=float(floats[1]);
          float b=float(floats[2]);
          float a=float(floats[3]);
          LightColors[seq]=color(r*255, g*255, b*255);
          alphaf[seq]=a;
        }
      }
    }
  }
}
