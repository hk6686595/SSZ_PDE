/*
    常量
 */

final int STATE_TEST=-1;
final int STATE_DEBUG=0;
final int STATE_VEDEO_MAPPING=1;
final int STATE_INTERACTIVE=2;
final int STATE_SLOW=3;
final int STATE_TIME_STANDBY=4;

final int PIXEL_STEP=60;
final int portOnUnity = 9525;
final int ignoreErrorNum=3;
final int EffectNum=500-ignoreErrorNum;

color time_color_fg=#FEFF08;
final color time_color_bg=0;

final int loacalPortToLight=9257;
final short COUNTS=128*3+5;
final int RGB_COUNTS=128*3;

String Local_ip="192.168.0.100";
String Light_ip="192.168.0.10";
String MotorLeft_ip="192.168.0.20";
String MotorRight_ip="192.168.0.30";
JSONObject ipJson;

void LoadUSRIpConfig()
{
  ipJson=loadJSONObject("ipJson.json");
  Local_ip = ipJson.getString("Local_ip");
  Light_ip = ipJson.getString("Light_ip");
  MotorLeft_ip = ipJson.getString("MotorLeft_ip");
  MotorRight_ip = ipJson.getString("MotorRight_ip");
  String logstr="load config ip = "+Local_ip + ", " + Light_ip + ", " + MotorLeft_ip+ ", " + MotorRight_ip;
  AppendLog(logstr);
}
