//RGB灯 指令控制解析


//固定头数据5+rgb128*3通道
byte[] fixBytes={(byte)0xA5, (byte)0x5a, (byte)0x01, (byte)(COUNTS>>8), (byte)(COUNTS&0xff)};
byte[] rgbs=new byte[RGB_COUNTS];
byte[] all1=new byte[COUNTS];
byte[] all2=new byte[COUNTS];
byte[] all3=new byte[COUNTS];
byte[] all4=new byte[COUNTS];

byte[]rgbs1=new byte[RGB_COUNTS];
byte[]rgbs2=new byte[RGB_COUNTS];
byte[]rgbs3=new byte[RGB_COUNTS];
byte[]rgbs4=new byte[RGB_COUNTS];

UDP udpToLights ;

void InitLigthModule()
{
  udpToLights = new UDP( this, loacalPortToLight, Local_ip );
  Arrays.fill(all1, (byte)0x00);
  Arrays.fill(all2, (byte)0x00);
  Arrays.fill(all3, (byte)0x00);
  Arrays.fill(all4, (byte)0x00);
  System.arraycopy(fixBytes, 0, all1, 0, fixBytes.length);
  System.arraycopy(fixBytes, 0, all2, 0, fixBytes.length);
  System.arraycopy(fixBytes, 0, all3, 0, fixBytes.length);
  System.arraycopy(fixBytes, 0, all4, 0, fixBytes.length);
  clearRgbsArrays();
  UpdateToLightActualColor();
}

void setOneLightColor(int _index, color _c)
{
  LightColors[_index]=_c;
  CalcLightRGBs(_index);
  UpdateToLightActualColor();
}
void CalcLightRGBs(int id)
{
  int _cor_=LightColors[id];
  CalcModuleInfoByIndex(true, id, ligthtModuleID);
  switch(ligthtModuleID.ownMID)
  {
  case 0:
    {
      int seqId=ligthtModuleID.seqID;
      byte[]rgbbyte=intToByteArray(_cor_);
      rgbs1[seqId*3]=rgbbyte[3];
      rgbs1[seqId*3+1]=rgbbyte[2];
      rgbs1[seqId*3+2]=rgbbyte[1];
    }
    break;
  case 1:
    {
      int seqId=ligthtModuleID.seqID;
      byte[]rgbbyte=intToByteArray(_cor_);
      rgbs2[seqId*3]=rgbbyte[3];
      rgbs2[seqId*3+1]=rgbbyte[2];
      rgbs2[seqId*3+2]=rgbbyte[1];
    }
    break;
  case 2:
    {
      int seqId=ligthtModuleID.seqID;
      byte[]rgbbyte=intToByteArray(_cor_);
      rgbs3[seqId*3]=rgbbyte[3];
      rgbs3[seqId*3+1]=rgbbyte[2];
      rgbs3[seqId*3+2]=rgbbyte[1];
    }
    break;
  case 3:
    {
      int seqId=ligthtModuleID.seqID;
      byte[]rgbbyte=intToByteArray(_cor_);
      rgbs4[seqId*3]=rgbbyte[3];
      rgbs4[seqId*3+1]=rgbbyte[2];
      rgbs4[seqId*3+2]=rgbbyte[1];
    }
    break;
  }
}
void clearRgbsArrays(int clearColor)
{
  byte[]rgbbyte=intToByteArray(clearColor);
  for (int i=0; i<128; i++)
  {
    rgbs1[i*3]=rgbbyte[3];
    rgbs1[i*3+1]=rgbbyte[2];
    rgbs1[i*3+2]=rgbbyte[1];

    rgbs2[i*3]=rgbbyte[3];
    rgbs2[i*3+1]=rgbbyte[2];
    rgbs2[i*3+2]=rgbbyte[1];

    rgbs3[i*3]=rgbbyte[3];
    rgbs3[i*3+1]=rgbbyte[2];
    rgbs3[i*3+2]=rgbbyte[1];
    
    rgbs4[i*3]=rgbbyte[3];
    rgbs4[i*3+1]=rgbbyte[2];
    rgbs4[i*3+2]=rgbbyte[1];
  }
}
//clear with black of default
void clearRgbsArrays()
{
  Arrays.fill(rgbs1, (byte)0x00);
  Arrays.fill(rgbs2, (byte)0x00);
  Arrays.fill(rgbs3, (byte)0x00);
  Arrays.fill(rgbs4, (byte)0x00);
}

void CloseAllLights()
{
  clearRgbsArrays();
  UpdateToLightActualColor();
}

void ChangeAllLightsPureColor(color cc)
{
  SendToOneGroupLight(1, cc);
  SendToOneGroupLight(2, cc);
  SendToOneGroupLight(3, cc);
  SendToOneGroupLight(4, cc);
}

void UpdateToLightActualColor()
{
  System.arraycopy(rgbs1, 0, all1, fixBytes.length, 128*3);
  System.arraycopy(rgbs2, 0, all2, fixBytes.length, 128*3);
  System.arraycopy(rgbs3, 0, all3, fixBytes.length, 128*3);
  System.arraycopy(rgbs4, 0, all4, fixBytes.length, 128*3);
  udpToLights.send(all1, Light_ip, 6000 );
  udpToLights.send(all2, Light_ip, 6001 );
  udpToLights.send(all3, Light_ip, 6002 );
  udpToLights.send(all4, Light_ip, 6003 );
}

void SendToOneGroupLight(int area, int colo)
{
  float r=red(colo);
  float g=green(colo);
  float b=blue(colo);
  byte[] tmp={};
  if (area==1)
  {
    tmp=rgbs1;
  } else if (area==2)
  {
    tmp=rgbs2;
  } else if (area==3)
  {
    tmp=rgbs3;
  } else if (area==4)
  {
    tmp=rgbs4;
  }
  for (int n=0; n<128; n++)
  {
    tmp[n*3+0]=byte(int(b));
    tmp[n*3+1]=byte(int(g));
    tmp[n*3+2]=byte(int(r));
  }
  if (area==1)
  {
    System.arraycopy(rgbs1, 0, all1, fixBytes.length, 128*3);
    udpToLights.send(all1, Light_ip, 6000 );
  } else if (area==2)
  {
    System.arraycopy(rgbs2, 0, all2, fixBytes.length, 128*3);
    udpToLights.send(all2, Light_ip, 6001 );
  } else  if (area==3)
  {
    System.arraycopy(rgbs3, 0, all3, fixBytes.length, 128*3);
    udpToLights.send(all3, Light_ip, 6002 );
  } else if (area==4)
  {
    System.arraycopy(rgbs4, 0, all4, fixBytes.length, 128*3);
    udpToLights.send(all4, Light_ip, 6003 );
  }
}
