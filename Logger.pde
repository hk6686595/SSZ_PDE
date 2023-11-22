//日志模块

//StringBuilder 与 StringBuffer 之间的最大不同在于, StringBuilder 的方法不是线程安全的（不能同步访问）。

StringBuffer g_strLogBuffer=new StringBuffer();
boolean g_bPrintToConsole=true;
String logfilename="";

void GetDaylogFile()
{
  logfilename+=sketchPath();
  logfilename+="\\data\\log\\log";
  logfilename+=GetDate();
  logfilename+=".log";
}

void AppendLog(String logdata)
{
  if (g_bPrintToConsole)
  {
    println(logdata);
  }
  String curTime=GetFormatedDateTime();
  g_strLogBuffer.append(curTime);
  g_strLogBuffer.append(logdata);
  g_strLogBuffer.append("\n");
}

void FlushLogFile()
{
  try
  {
    FileWriter myWriter = new FileWriter(logfilename, false);
    myWriter.write(g_strLogBuffer.toString());
    g_strLogBuffer.setLength(0);
    myWriter.close();
    println("Successfully wrote to the file.");
  }
  catch (IOException e) {
    System.out.println("An error occurred.");
    e.printStackTrace();
  }
}
