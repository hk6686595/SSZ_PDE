import controlP5.*;

//UI界面
ControlP5 cp5;
ColorWheel cw;
Textlabel gScanModeLabel;
Textlabel totalNumLabel;
Textlabel caliIndexLabel;
Button nextBtn, previousBtn, saveParamBtn;
Slider caliDepthSld;
Slider maxDepthSld;
Slider SliderAcc, SliderSpeed;
Textarea lastRecvHexStringTexA;
RadioButton testTypeRatioBtn;
ControlTimer testTimecontrollerTImer1;
Textlabel timerLabel;
ControlFont cFont;

Textlabel IsReadySHowLabel;
boolean isChceking=false;

void InitUI()
{
  cFont=new ControlFont(font50, 14);
  cp5 = new ControlP5(this, cFont);
  testTimecontrollerTImer1 = new ControlTimer();
  timerLabel = new Textlabel(cp5, "--", 100, 100);
  testTimecontrollerTImer1.setSpeedOfTime(1);

  cp5.addButton("CloseLights")
    .setCaptionLabel("关所有灯")
    .setValue(0)
    .setPosition(1475, 662)
    .setSize(120, 40)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      CloseAllLights();
      buttonExcutedInfo="关所有灯 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  saveParamBtn = cp5.addButton("SaveParam")
    .setCaptionLabel("保存参数")
    .setValue(0)
    .setPosition(10, 150)
    .setSize(60, 25)
    .hide()
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      //save params
      saveParmas();
      buttonExcutedInfo="保存参数 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );
  //显示最近一次收到的指令信息
  lastRecvHexStringTexA = cp5.addTextarea("txt")
    .setPosition(480, 730)
    .setSize(960, 200)
    .setLineHeight(14)
    .setColor(color(56, 240, 180))
    .setColorBackground(color(40, 150))
    .setColorForeground(color(255));
  ;
  lastRecvHexStringTexA.getProperty("text").disable();

  IsReadySHowLabel = cp5.addTextlabel("IsReadySHow")
    .setText("是否就位:False")
    .setPosition(0, 900)
    .setColorValue(0xffffffff);
  IsReadySHowLabel.getProperty("stringValue").disable();
  IsReadySHowLabel.getProperty("value").disable();

  gScanModeLabel = cp5.addTextlabel("gScanMode")
    .setText("扫描方式:none")
    .setPosition(900, 10)
    .setColorValue(0xffffff00)
    ;
  gScanModeLabel.getProperty("stringValue").disable();
  gScanModeLabel.getProperty("value").disable();

  totalNumLabel = cp5.addTextlabel("totalNum")
    .setText("扫描成功数:0")
    .setPosition(0, 920)
    .setColorValue(0xffffffff)
    .setColorBackground(0);
  totalNumLabel.getProperty("stringValue").disable();
  totalNumLabel.getProperty("value").disable();

  caliIndexLabel = cp5.addTextlabel("caliIndex")
    .setText("当前标定对象序号:0")
    .setPosition(250, 80)
    .setColorValue(0xffffff00)
    .hide();
  caliIndexLabel.getProperty("stringValue").disable();
  caliIndexLabel.getProperty("value").disable();
  //标定实时设置位置
  caliDepthSld= cp5.addSlider("caliDepthSld")
    .setCaptionLabel("当前深度")
    .setBroadcast(false)
    .setRange(15000, -15000)
    .setPosition(140, 80)
    .setSize(70, 850)
    .setBroadcast(true)
    .setValue(-10000)
    .hide()
    ;
  //改变最大深度值
  maxDepthSld=cp5.addSlider("maxDepthSld")
    .setCaptionLabel("最大深度值")
    .setBroadcast(false)
    .setRange(-50000, -120000)
    .setPosition(0, 0)
    .setSize(700, 20)
    .setBroadcast(true)
    .setValue(-110000);


  SliderSpeed=cp5.addSlider("spd")
    .setCaptionLabel("目标速度调节")
    .setBroadcast(false)
    .setRange(500, 2000)
    .setPosition(0, 22)
    .setSize(700, 20)
    .setBroadcast(true)
    .setValue(700)
    ;

  SliderAcc=cp5.addSlider("acc")
    .setCaptionLabel("加速度调节")
    .setBroadcast(false)
    .setRange(500, 5000)
    .setPosition(0, 44)
    .setSize(700, 20)
    .setBroadcast(true)
    .setValue(1000)
    ;

  //测试颜色选择器
  cw = cp5.addColorWheel("test_color", 1460, 430, 200 )
    .setCaptionLabel("测试颜色")
    .setRGB(color(0, 0, 0))
    ;
  cw.setSaturation(0.5f);
  cw.getProperty("arrayValue").disable();

  //物理归零
  cp5.addButton("Zero_All")
    .setCaptionLabel("物理归零")
    .setValue(0)
    .setPosition(300, 325+85-170)
    .setSize(78, 80)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      if (!IsScanning&& g_ScanMode==-1)
      {
        g_ScanMode=0;
        thread("scan");
      }
      buttonExcutedInfo="物理归零 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  //回到逻辑0点
  cp5.addButton("Zero_To_LogicPos")
    .setCaptionLabel("逻辑归零")
    .setValue(0)
    .setPosition(382, 325+85-170)
    .setSize(78, 80)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      GotoLogiZero();
      buttonExcutedInfo="逻辑归零 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  //写使能按钮
  cp5.addButton("Let_Enable_All")
    .setCaptionLabel("使能全开")
    .setValue(0)
    .setPosition(300, 325+85+85-170)
    .setSize(78, 80)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      if (!IsScanning && g_ScanMode==-1)
      {
        g_ScanMode=6;
        thread("scan");
      }
      buttonExcutedInfo="使能全开 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  cp5.addButton("Let_EnEnable_All")
    .setCaptionLabel("EN使能")
    .setValue(0)
    .setPosition(380, 325+85+85-170)
    .setSize(78, 80)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      if (!IsScanning && g_ScanMode==-1)
      {
        g_ScanMode=1;
        thread("scan");
      }
      buttonExcutedInfo="EN使能 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  //读-使能按钮
  cp5.addButton("Check_Enable_All")
    .setCaptionLabel("查看使能")
    .setValue(0)
    .setPosition(300, 325+85+85+85-170)
    .setSize(160, 80)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      if (!IsScanning && g_ScanMode==-1)
      {
        g_ScanMode=3;
        thread("scan");
      }
      buttonExcutedInfo="查看使能 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  cp5.addButton("ReadPos")
    .setCaptionLabel("扫描位置")
    .setValue(0)
    .setPosition(300, 325+85+85+85+85-170)
    .setSize(160, 80)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      if (!IsScanning && g_ScanMode==-1)
      {
        g_ScanMode=16;
        thread("scan");
      }
      buttonExcutedInfo="扫描位置 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );
  cp5.addButton("Clear_Color")
    .setCaptionLabel("清除标记颜色")
    .setValue(0)
    .setPosition(300, 325+85+85+85+85-170+85)
    .setSize(160, 80)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      if (g_ScanMode==-1)
      {
        Arrays.fill(unit_fill_colors, color(100, 100, 100, 255));
      }
      buttonExcutedInfo="清除标记颜色 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );
  //单选框按钮，选择测试模式
  testTypeRatioBtn = cp5.addRadioButton("test_style")
    .setPosition(1460, 240)
    .setSize(30, 30)
    .setColorForeground(color(140))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(3)
    .setSpacingColumn(80)
    .addItem("测试行", 0)
    .addItem("测试单模块", 1)
    .addItem("波型", 2)
    ;
  testTypeRatioBtn.getProperty("arrayValue").disable();

  //全出按钮
  cp5.addButton("All_Out_test")

    .setCaptionLabel("整体全出")
    .setValue(0)
    .setPosition(1460, 280)
    .setSize(80, 50)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      MoveAll(true);
      buttonExcutedInfo="整体全出 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  //全进按钮
  cp5.addButton("All_In_test")
    .setCaptionLabel("整体全进")
    .setValue(0)
    .setPosition(1542, 280)
    .setSize(80, 50)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      MoveAll(false);
      buttonExcutedInfo="整体全进 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  //开始测试
  cp5.addButton("Start_Test")
    .setCaptionLabel("开始测试")
    .setValue(0)
    .setPosition(1460, 332)
    .setSize(80, 50)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      startTest(test_style);
      buttonExcutedInfo="开始测试 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );
  //停止测试
  cp5.addButton("Stop_Test")
    .setCaptionLabel("停止测试")
    .setValue(0)
    .setPosition(1542, 332)
    .setSize(80, 50)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      stop_test();
      buttonExcutedInfo="停止测试 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  cp5.addButton("Check_All_Ready")
    .setCaptionLabel("验证是否\n准备完毕")
    .setValue(0)
    .setPosition(300, 850)
    .setSize(160, 80)
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      if (!isChceking)//
      {
        IsReadySHowLabel.setText("正在查询...");
        isChceking=true;
        boolean b=ChcekIsAllInPos();
        if (b)
        {
          IsReadySHowLabel.setText("所有点击就位");
          IsReadySHowLabel.setColorValue(0xff00ff00);
        } else
        {
          IsReadySHowLabel.setText("有电机不在位置！");
          IsReadySHowLabel.setColorValue(0xffff0000);
        }
      } else
      {
        println("正在查询，请稍等");
        return;
      }
      buttonExcutedInfo="Check_All_Ready 按钮执行";
      buttontimestamp=getAppElapsedTimef();
    }
  }
  );

  Toggle tg=cp5.addToggle("toggleOfCaliLogicZero")
    .setCaptionLabel("矫正逻辑原点")
    .setPosition(10, 80)
    .setSize(40, 40)
    .setValue(false)
    .setMode(ControlP5.SWITCH);
  tg.getProperty("value").disable();
  cp5.loadProperties(("data\\cp5.properties"));
  MAX_DEPTH = int(maxDepthSld.getValue());
  rememberAcc=gacc;
  rememberSpd=gspd;
  cp5.hide();

  ChangeMotorAcc(500);
}

//////////////////分割线//////回调函数///////////////

void toggleOfCaliLogicZero(boolean theFlag) {
  if (theFlag==true) {
    caliIndexLabel.show();
    //nextBtn.show();
    //previousBtn.show();
    caliDepthSld.show();
    saveParamBtn.show();
    bCaliActPosFlag=true;
    currentCaliPos=-1;
  } else {
    caliIndexLabel.hide();
    //nextBtn.hide();
    //previousBtn.hide();
    saveParamBtn.hide();
    caliDepthSld.hide();
    bCaliActPosFlag=false;
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(testTypeRatioBtn)) {
    for (int i=0; i<theEvent.getGroup().getArrayValue().length; i++) {
      int abc=int(theEvent.getGroup().getArrayValue()[i]);

      test_style= i==0?(abc==1?0:-1):(i==1? (abc==1?1:-1):(abc==1?2:-1));
      if (test_style!=-1) break;
    }
    println("\t "+test_style);
  }
}

void test_color(int col) {
  g_light_color=col;
  if (ProgState==0)
  {
    ChangeAllLightsPureColor(g_light_color);
  }
}

void Test_Bar(int n) {
  test_style=n;
}

public void caliDepthSld(float value) {
  if (!bCaliActPosFlag) return;
  int _abpos=int(value);
  if (currentCaliPos<0 || currentCaliPos>511) return;
  int ret=setOneMotorAbPos(currentCaliPos, _abpos);
  if (ret!=-1)
    LogicZeroPos[currentCaliPos]=_abpos;
}

public void maxDepthSld(float value) {
  MAX_DEPTH=(int)value;
  LoadZEROParams();
}

public void spd(float _abpos) {
  gspd=(short)_abpos;
  SPD=shortToByteArray(gspd);
}
public void acc(float _abpos) {
  gacc=(short)_abpos;
  ACC=shortToByteArray(gacc);
}

void LoadSaveCp5JsonProperty() {
  if (key=='1') {
    cp5.saveProperties(("data\\cp5.properties"));
    AppendLog("保存ui参数完成");
  } else if (key=='2') {
    cp5.loadProperties(("data\\cp5.properties"));
    AppendLog("加载ui参数完成");
  }
}
