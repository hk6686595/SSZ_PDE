
String cityWeaetherUrl="https://api.seniverse.com/v3/weather/now.json?key=SrPvekjW60tflzBHI&location=hefei&language=zh-Hans&unit=c";

void loadProgramConfig()
{
  String[] txtlines = loadStrings("roboturl.txt");
  yunzhijieUrl = txtlines[0];
  String[] lines=loadStrings("city.txt");
  if (lines.length>0)
  {
    cityWeaetherUrl=lines[0];
    println("load city ok", cityWeaetherUrl);
  }
  String[] configStr =loadStrings("config.txt");
  if (configStr.length>0)
  {
    String[] list = split(configStr[0], '=');
    if (list.length==2)
    {
      if (list[0].contains("AutoRun"))
      {
        bAutoRun= (list[1].contains("0"))?false:true;
      }
    }
  }
  if (!bAutoRun)
  {
    RobotMsg("非自动模式bAutoRun=false", false);
  }
}
