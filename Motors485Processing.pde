//伺服电机控制模块 //<>// //<>// //<>// //<>//

UDP[] udpOn_IP20_s;
UDP[] udpOn_IP30_s;

int[] selectflags=new int[16*32];
int getAbposition=0;
int g_ScanMode=-1;//3-读使能 6-写使能 0-写回零 16-readlowpos 17-readhipos 1-EnEnable
String lastRecvHexStringData="null";
String scanModeStr="null";
boolean IsScanning=false;
boolean bScanOverFlag=false;
float scanTimf=0;

//初始化485motor
void InitialMotor()
{
  udpOn_IP20_s=new UDP[8];
  udpOn_IP30_s=new UDP[8];
  ACC=shortToByteArray(gacc);
  SPD=shortToByteArray(gspd);
  int beginPort1=6000;
  int beginPort2=6008;
  for (int u=0; u<8; u++)//创建16个udp对象，ip固定20和30，端口6000-6007
  {
    udpOn_IP20_s[u]=new UDP(this, beginPort1++, Local_ip);//6000-6007
    udpOn_IP30_s[u]=new UDP(this, beginPort2++, Local_ip);//6008-6015
    udpOn_IP20_s[u].listen(true);
    udpOn_IP30_s[u].listen(true);
  }
  if (bAutoRun)
  {
    //先验证是否全部使能
    AppendLog("刚启动，先读取使能状态");
    g_ScanMode=3;
    thread("scan");
  }
}

//轮询发送对应指令，线程调用函数
void scan()
{
  if (IsScanning) return;
  GetFeedbackTrueCount=0;
  Arrays.fill(GetFeedbackFlags, 0);
  if (g_ScanMode==0)  scanModeStr="writing zeroing";
  else if (g_ScanMode==3) scanModeStr="reading enable";
  else if (g_ScanMode==6) scanModeStr="writing enable";
  else if (g_ScanMode==9) scanModeStr="reading dir";
  else if (g_ScanMode==16) scanModeStr="read low pos";
  else if (g_ScanMode==17) scanModeStr="read hi pos";
  else if (g_ScanMode==1)  scanModeStr="clear warnings";
  else return;

  IsScanning=true;
  gScanModeLabel.setText("当前扫描:"+scanModeStr);
  ResetColorArray();

  for (int adr=1; adr<=32; adr++)
  {
    try {
      Thread.sleep(20);
    }
    catch (InterruptedException e) {
      e.printStackTrace();
    }
    for (int t=1; t<=16; t++)
    {
      try {
        Thread.sleep(16);
      }
      catch (InterruptedException e) {
        e.printStackTrace();
      }
      SendToOnePoint((byte)adr, t, g_ScanMode);
    }
  }
  IsScanning=false;
  if (g_ScanMode==16)//高位发送完成接着发低位
  {
    g_ScanMode=17;
    thread("scan");
  } else
  {
    scanModeStr+=",OVER!";
    gScanModeLabel.setText("当前扫描:"+scanModeStr);
    bScanOverFlag=true;
    scanTimf=getAppElapsedTimef();//记录发送结束时间，等待5秒
    AppendLog("发送scan指令结束！");
  }
}

//给指定端口和序号的电机发送指令
void SendToOnePoint(byte addr, int comport, int tp)
{
  if (addr<1 || addr>32 || comport<1 || comport>16)
  {
    AppendLog("error addr or comport:"+str(addr));
    return;
  }

  byte[] tmpBytes={};
  UDP[] tmpUdp={};
  String tmpIP="";
  int mins=0;
  if (comport<=8)//1--8
  {
    tmpUdp=udpOn_IP20_s;
    tmpIP=MotorLeft_ip;
  } else //8-16
  {
    tmpUdp=udpOn_IP30_s;
    tmpIP=MotorRight_ip;
    mins=8;
  }
  //根据类型判断
  if (tp==3)//读 使能 状态
    tmpBytes=readMakeCanCmd;
  else if (tp==6)//写 使能 状态
    tmpBytes=writeMakeCanCmd;
  else if (tp==9)//读 dir 状态
    tmpBytes=readDirCmd;
  else if (tp==16)//读-位置低位
    tmpBytes= readPosLoCmd;
  else if (tp==17)//读-位置高位
    tmpBytes= readPosHiCmd;
  else if (tp==0)//写-回零
    tmpBytes= zeroCmd;
  else if (tp==1)//清除告警
    tmpBytes= writeEnEnableCmd;
  else return;
  tmpBytes[0]=(byte)(addr);
  int res=crc16.calcCrc16(tmpBytes);
  byte[] _crc= crc16.getCrcByte(res);
  byte[] newBts=new byte[tmpBytes.length+2];
  System.arraycopy(tmpBytes, 0, newBts, 0, tmpBytes.length);
  newBts[6]=_crc[0];
  newBts[7]=_crc[1];
  tmpUdp[comport-1-mins].send(newBts, tmpIP, comport-1+6000);

  //记录发送日志
  lastRecvHexStringData="";
  for (int i=0; i<newBts.length; i++)
  {
    lastRecvHexStringData+=hex(newBts[i]);
    lastRecvHexStringData+=" ";
  }
  AppendLog("sent:"+lastRecvHexStringData +"  to COM["+str(comport)+"] , PORT["+str(addr) +"]");
}


//接收电机返回的数据,处理
//收到的数据可能是7个字节也可能是8个字节，或者更多
int[] GetFeedbackFlags=new int[512];
int GetFeedbackTrueCount=0;
synchronized void receive( byte[] data, String ip, int port )
{
  lastRecvHexStringData="";
  for (int i=0; i<data.length; i++)
  {
    lastRecvHexStringData+=hex(data[i]);
    lastRecvHexStringData+=" ";
  }
  if (data.length<7)
  {
    AppendLog("err length:"+str(data.length)+" on"+" COM["+str(port-6000)+"]");
    AppendLog(lastRecvHexStringData);
    return;
  }

  int comPort=port-6000+1;
  int addr=data[0];
  int seqIndex=calcIndexByAddressPort(addr, comPort);
  AppendLog("recv:"+lastRecvHexStringData+"from COM["+str(comPort)+"] , PORT["+str(addr)+"]");

  if (data.length==7)//收到7个字节，一般为读取指令的应答
  {
    if (data[1]==byte(0x03) && data[2]==byte(0x02))//收到合法数据
    {
      if (g_ScanMode==3)//读使能返回
      {
        GetFeedbackFlags[seqIndex]=data[4];//0 or 1
        unit_fill_colors[seqIndex]= data[4]==1?color(0, 255, 0):color(255, 0, 0);//1绿0红
        GetFeedbackTrueCount+=GetFeedbackFlags[seqIndex];//统计状态是1数量
        totalNumLabel.setText("扫描成功数:"+GetFeedbackTrueCount);
        if (!IsReady && GetFeedbackTrueCount>=EffectNum)
        {
          IsReady=true;
          GotoLogiZero();
          AppendLog("使能全部开启");
          RobotMsg("使能全部开启", false);
        }
      } else if (g_ScanMode==9)//读dir返回
      {
        GetFeedbackFlags[seqIndex]=data[4];
        unit_fill_colors[seqIndex]= data[4]==1?color(150, 150, 150):color(60, 60, 60);
        GetFeedbackTrueCount+=GetFeedbackFlags[seqIndex];
        totalNumLabel.setText("扫描成功数:"+GetFeedbackTrueCount);
      } else if (g_ScanMode==16)//读绝对位置低位2字节
      {
        ints[seqIndex][2]=data[3];
        ints[seqIndex][3]=data[4];
        unit_fill_colors[seqIndex]= color(66, 150, 200);
        GetFeedbackTrueCount++;
        totalNumLabel.setText("扫描成功数:"+GetFeedbackTrueCount);
      } else if (g_ScanMode==17)//读绝对位置高位2字节
      {
        ints[seqIndex][0]=data[3];
        ints[seqIndex][1]=data[4];
        unit_fill_colors[seqIndex]= color(200, 150, 66);
        GetFeedbackTrueCount++;
        totalNumLabel.setText("扫描成功数:"+GetFeedbackTrueCount);
        if (GetFeedbackTrueCount>=EffectNum)
        {
          AppendLog("扫描位置结束");
        }
      }
    }
  } else if (data.length==8)//收到8字节一般位写指令应答
  {
    if (data[5]==byte(0x01) && data[3]==byte(0x00)) //收到写使能反馈
    {
      GetFeedbackFlags[seqIndex]=data[5];
      GetFeedbackTrueCount++;
      totalNumLabel.setText("扫描成功数:"+GetFeedbackTrueCount);
      unit_fill_colors[seqIndex]=color(255, 255, 0);//黄色
    } else if (data[5]==byte(0x01) && data[3]==byte(0x01))//en 使能
    {
      GetFeedbackFlags[seqIndex]=data[5];
      GetFeedbackTrueCount++;
      totalNumLabel.setText("扫描成功数:"+GetFeedbackTrueCount);
      unit_fill_colors[seqIndex]=color(50, 150, 120);
    } else if (data[5]==byte(0x08) && data[3]==byte(0x19))//物理归零反馈
    {
      GetFeedbackFlags[seqIndex]=data[5];//this data[5] == 0x08
      GetFeedbackTrueCount++;
      totalNumLabel.setText("扫描成功数:"+GetFeedbackTrueCount);
      unit_fill_colors[seqIndex]=color(0, 255, 255);// 青色
      if (g_ScanMode==0 && GetFeedbackTrueCount>=EffectNum)
      {
        if (GetFeedbackTrueCount==500)
        {
          RobotMsg("全部回到机械原点", false);
          AppendLog("全部归零结束");
          gScanModeLabel.setText("全部归零结束");
        } else if (GetFeedbackTrueCount==EffectNum)
        {
        }
      }
    } else if (data[1]==(byte)0x7b)//收到单个位置反馈
    {
      getAbposition=byteArrayToInt(new byte[]{data[4], data[5], data[2], data[3]});
      if (getAbposition-LogicZeroPos[seqIndex]<MAX_DEPTH/2)
      {
        unit_fill_colors[seqIndex]=color(100);
      } else
      {
        if (!bCaliActPosFlag)//如果不在标定，显示淡红色
          unit_fill_colors[seqIndex]=color(150, 80, 102);
      }
    }
  }//end of length==8
}


//同步控制电机
final int perModuleMotorCounts=32;
byte[][] newBtss=new byte[16][7+256+2];
void UpdateToMotorActualDepth()
{
  for (int com=1; com<=16; ++com)//16*32次
  {
    for (int address=1; address<=32; address++)
    {
      int idx= calcIndexByAddressPort(address, com);
      int _abpos=PhyDepth[idx];
      _abpos=constrain(_abpos, LogicMaxPos[idx], LogicZeroPos[idx]);
      byte[]bytsAbpos=intToByteArray(_abpos);
      int i=address-1;
      Data[i*8+0]=bytsAbpos[2];
      Data[i*8+1]=bytsAbpos[3];
      Data[i*8+2]=bytsAbpos[0];
      Data[i*8+3]=bytsAbpos[1];
      Data[i*8+4]=SPD[0];
      Data[i*8+5]=SPD[1];
      Data[i*8+6]=ACC[0];
      Data[i*8+7]=ACC[1];
    }

    byte [] new1=new byte[syncCmd.length+Data.length];
    System.arraycopy(syncCmd, 0, new1, 0, syncCmd.length);
    System.arraycopy(Data, 0, new1, syncCmd.length, Data.length);
    int res=crc16.calcCrc16(new1);
    byte[] _crc= crc16.getCrcByte(res);
    System.arraycopy(new1, 0, newBtss[com-1], 0, new1.length);
    newBtss[com-1][7+256+2-2]=_crc[0];//0-16
    newBtss[com-1][7+256+2-1]=_crc[1];
  }
  for (int p=0; p<8; p++)
  {
    udpOn_IP20_s[p].send(newBtss[p], MotorLeft_ip, 6000+p);
    udpOn_IP30_s[p].send(newBtss[p+8], MotorRight_ip, 6008+p);
  }
}

//点击指定位置电机并伸缩
int clickDepth=MAX_DEPTH;
void setABPosByMouseClickUI()
{
  if (g_ScanMode!=-1) return;
  int curIndex=getClickIndex();
  if (curIndex==-1) {
    return;
  }
  currentCaliPos=curIndex;
  if ( selectflags[curIndex]==0)
  {
    setOneLightColor(curIndex, color(100, 100, 100));
    selectflags[curIndex]=1;
    clickDepth=LogicMaxPos[curIndex];
    if (!bCaliActPosFlag)//如果不在标定
      setOneMotorAbPos(curIndex, clickDepth);
    else
    {
      unit_fill_colors[curIndex]=color(100, 200, 180);
      caliIndexLabel.setText("当前标定对象序号:"+str(currentCaliPos));
    }
  } else
  {
    setOneLightColor(curIndex, color(0));
    selectflags[curIndex]=0;
    clickDepth=LogicZeroPos[curIndex];
    if (!bCaliActPosFlag)//如果不在标定，则伸出来
      setOneMotorAbPos(curIndex, clickDepth);
    else
    {
      currentCaliPos=-1;
      caliIndexLabel.setText("当前标定对象序号:"+str(currentCaliPos));
      unit_fill_colors[curIndex]=color(100);
    }
  }
}

//设置单个电机绝对位置
float intervaltime=0f;
int setOneMotorAbPos(int _index, int abpos)
{
  if (getAppElapsedTimef()-intervaltime<0.1f) return -1;//控制发送间隔
  intervaltime=getAppElapsedTimef();
  CalcModuleInfoByIndex(false, _index, motorModuleID);
  int port=motorModuleID.ownMID;
  byte motoraddress=(byte) motorModuleID.seqID;
  byte[] PosintBytes=intToByteArray(abpos);
  byte[] abPosCmd=new byte[6];
  abPosCmd[0]=byte(motoraddress+1);
  abPosCmd[1]=(byte)0x7b;
  System.arraycopy(PosintBytes, 0, abPosCmd, 2, PosintBytes.length);
  int res=crc16.calcCrc16(abPosCmd);
  byte[] _crc= crc16.getCrcByte(res);
  byte[] newBts=new byte[abPosCmd.length+2];
  System.arraycopy(abPosCmd, 0, newBts, 0, abPosCmd.length);
  newBts[6]=_crc[0];
  newBts[7]=_crc[1];
  if (port<8)//0-15  0-7 / 8-15
  {
    udpOn_IP20_s[port].send(newBts, MotorLeft_ip, port+6000);
  } else
  {
    udpOn_IP30_s[port-8].send(newBts, MotorRight_ip, port+6000);
  }
  return abpos;
}
//同步电机回到逻辑零点
void GoboLogiZero()
{
  for (int id=0; id<512; id++)
  {
    PhyDepth[id]= LogicZeroPos[id];
    fill(unit_fill_colors[id]);
  }
  UpdateToMotorActualDepth();
}
//点击坐标转换电机序号
int getClickIndex()
{
  if (mouseX<startX || mouseX>startX+960 || mouseY<startY ||mouseY>startY+480) return -1;
  int mx=mouseX-startX;
  int my=mouseY-startY;
  int cc=mx/Ra;
  int cr=my/Ra;
  return cc+cr*32;
}

//同步电机回到逻辑零点
void GotoLogiZero()
{
  for (int id=0; id<512; id++)
  {
    PhyDepth[id]= LogicZeroPos[id];
    fill(LightColors[id]);
  }
  UpdateToMotorActualDepth();
}

//整体全进/全出
void MoveAll(boolean isOut)
{
  if (!isOut)
  {
    for (int id=0; id<512; id++)
    {
      PhyDepth[id]= LogicZeroPos[id];
      fill(LightColors[id]);
    }
    UpdateToMotorActualDepth();
  } else
  {
    for (int id=0; id<512; id++)
    {
      PhyDepth[id]= LogicMaxPos[id];
      fill(LightColors[id]);
    }
    UpdateToMotorActualDepth();
  }
}
