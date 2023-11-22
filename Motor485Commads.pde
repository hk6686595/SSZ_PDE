short gspd=500;
short gacc=2000;

short rememberAcc;
short rememberSpd;

byte[]ACC;
byte[]SPD;
byte[] Data=new byte[32*8];//32*8=256//同步电机数据
//指令类型
byte[] zeroCmd          = {(byte)00, (byte)06, (byte)00, (byte)0x19, (byte)0x00, (byte)0x08};//机械归零
byte[] writeMakeCanCmd  = {(byte)00, (byte)06, (byte)00, (byte)0x00, (byte)0x00, (byte)0x01};//使能 写
byte[] writeEnEnableCmd = {(byte)00, (byte)06, (byte)00, (byte)0x01, (byte)0x00, (byte)0x01};//清除报警
byte[] readMakeCanCmd   = {(byte)00, (byte)03, (byte)00, (byte)0x00, (byte)0x00, (byte)0x01};//使能 读
byte[] readDirCmd       = {(byte)00, (byte)03, (byte)00, (byte)0x09, (byte)0x00, (byte)0x01};//dir 读
byte[] readPosHiCmd     = {(byte)00, (byte)03, (byte)00, (byte)0x17, (byte)0x00, (byte)0x01};//高位 读
byte[] readPosLoCmd     = {(byte)00, (byte)03, (byte)00, (byte)0x16, (byte)0x00, (byte)0x01};//低位 读
byte[] readAccCmd       = {(byte)00, (byte)03, (byte)00, (byte)0x03, (byte)0x00, (byte)0x01};//加速度 读
byte[] readSpdCmd       = {(byte)00, (byte)03, (byte)00, (byte)0x02, (byte)0x00, (byte)0x01};//速度 读
byte[] dirCmd           = {(byte)00, (byte)06, (byte)00, (byte)0x09, (byte)0x00, (byte)0x00};//dir 写
byte[] saveParamCmd     = {(byte)00, (byte)06, (byte)00, (byte)0x14, (byte)0x00, (byte)0x01};//保存参数
byte[] syncCmd          = {(byte)0x00, (byte)0x10, (byte)0x00, (byte)0x16, (byte)0x00, (byte)128, (byte)0x00};
