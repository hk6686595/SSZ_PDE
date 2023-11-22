//逻辑0点配置功能

int MAX_DEPTH=-120000;
int[] LogicMaxPos=new int[512];
int[] LogicZeroPos=new int[512];
byte[][] ints=new byte[512][4];

int currentCaliPos=3;//从第四个开始
int [] ignoreIndexes=new int[]{0, 1, 30, 31, 32, 63, 448, 479, 480, 481, 511, 510};//忽略四个角点
int [] nowScanedPos=new int[512];
String[] lines;
boolean bCaliActPosFlag=false;

void CalcScanedPos()//计算当前扫描之后的位置
{
  for (int n=0; n<512; n++)
  {
    // FF FE 79 62
    int intValue=byteArrayToInt(ints[n]);
    nowScanedPos[n]=intValue;
    AppendLog("nowScanedPos["+n+"]="+ intValue);
  }
  AppendLog("计算完成");
}

boolean ChcekIsAllInPos()
{
  String info="";
  int errCts=0;
  for (int n=0; n<512; n++)
  {
    if (contains(ignoreIndexes, n))
      continue;
    if ( abs( nowScanedPos[n]-LogicZeroPos[n])>30)
    {
      AppendLog("nowPos["+n+"]="+str(nowScanedPos[n])+" , ZeroPos["+n+"]"+str(LogicZeroPos[n]));
      info+=str(n)+"\t";
      errCts++;
    }
  }
  if (info.length()>0)
  {
    RobotMsg("序号:"+info+"不在逻辑原点，数量："+errCts, true);
  }
  return errCts<=3;
}

void LoadZEROParams()
{
  lines=loadStrings("data\\params.txt");
  for (int i = 0; i < lines.length; i++) {
    String line =lines[i];
    int v=int(line);
    LogicZeroPos[i]=v;
    LogicMaxPos[i]=v+MAX_DEPTH;
  }
}

void StartCali()
{
  if (!bCaliActPosFlag)
  {
    bCaliActPosFlag=true;
    AppendLog("开始标定");
  } else return;
}

void saveParmas()
{
  String[] lines = new String[LogicZeroPos.length];
  for (int i = 0; i < LogicZeroPos.length; i++) {
    lines[i] = str(LogicZeroPos[i]);
  }
  saveStrings("data\\params.txt", lines);
  AppendLog("保存逻辑原点完成");
}
