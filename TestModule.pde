//测试模块

float test_run_total_time=2000;
float test_run_time=0;
float test_interval_time=1.0f;
float test_timeStamp;
int test_style=-1;


void startTest(int _test_style)
{
  if (_test_style<0) return;
  if (ProgState!=0)
    return;
  ProgState=-1;
  AppendLog("开始测试..."+"类型:"+str(_test_style));
  test_run_time=getAppElapsedTimef();
  NowTestRow=15;
  now_mo_id=15;
  cw.setColorValue(color(255, 0, 0));
  g_light_color=color(255, 0, 0);
  test_style=_test_style;
}

//测试方式1--一行一行测
int NowTestRow=15;
void run_once_row_by_row()
{
  for (int n=0; n<32; n++)
  {
    LightColors[NowTestRow*32+n]=color(0);
    alphaf[NowTestRow*32+n]=0.0f;
  }
  NowTestRow=(NowTestRow+1)%16;//0-15;
  for (int n=0; n<32; n++)
  {
    alphaf[NowTestRow*32+n]=1.0f;
    LightColors[NowTestRow*32+n]=g_light_color;
  }
}

//测试方式2----一个一个模块测
int now_mo_id=15;
void run_once_mo_by_mo()
{
  int comport=now_mo_id+1;
  for (int n=0; n<32; n++)
  {
    int address=n+1;
    int index=calcIndexByAddressPort(address, comport );
    LightColors[index]=color(0);
    alphaf[index]=0.0f;
  }
  now_mo_id=(now_mo_id+1)%16;//0-15;
  comport=now_mo_id+1;
  for (int n=0; n<32; n++)
  {
     int address=n+1;
    int index=calcIndexByAddressPort(address, comport);
    LightColors[index]=g_light_color;
    alphaf[index]=1.0f;
  }
}

//测试方式2----波浪效果
void run_once_with_wave()
{
  for (int rr=0; rr<16; rr++)
  {
    for (int cc=0; cc<32; cc++)
    {
      int index=rr*32+cc;
      float rad=map(cc, 0, 31, 0, 8*PI);
      alphaf[index]=(sin(rad+frameCount*0.2f)+2)/3;
      LightColors[index]=g_light_color;
    }
  }
}

void run_test_once()
{
  switch(test_style)
  {
  case 0:
    run_once_row_by_row();
    test_interval_time=1.0f;
    break;
  case 1:
    run_once_mo_by_mo();
    test_interval_time=2.0;
    break;
  case 2:
    run_once_with_wave();
    test_interval_time=0.05f;
    break;
  }
}

void stop_test()
{
  ProgState=0;
  thread("fnStopTest");
}

void fnStopTest()
{
  try {
    Thread.sleep(500);
  }
  catch (InterruptedException e) {
    e.printStackTrace();
  }
  test_style=-1;
  for (int n=0; n<512; n++)
  {
    LightColors[n]=color(0);
    PhyDepth[n]= LogicZeroPos[n];
  }
  UpdateToMotorActualDepth();
  for (int p=0; p<8; p++)
  {
    udpOn_IP20_s[p].send(newBtss[p], MotorLeft_ip, 6000+p);
    udpOn_IP30_s[p].send(newBtss[p+8], MotorRight_ip, 6008+p);
  }
  CloseAllLights();
  AppendLog("停止测试，复位");
}
