//坐标转换映射 //<>// //<>// //<>//
Module485  ligthtModuleID=new Module485();
Module485 motorModuleID=new Module485();

int GetRevertOwnSeq(int col, int row) //<>// //<>// //<>// //<>//
{
  //根据32*16行列转换得到4*4的行列
  int secCol=col/8;  //0-32  /8    0-4
  int secRow=row/4;  //0-15  /4    0-4
  //行列颠倒
  int _tsecRow=secCol;
  int _tsecCol=secRow;
  int seq485Dev=_tsecRow*4+_tsecCol;
  return seq485Dev+1;
}

int calcIndexByAddressPort(int addr,int comport)
{
  int id=addr-1;
  int n=comport-1;
  int c=n%4;//0-3
  int r=n/4;//0-1
  int rc=r;//0-1
  int rr=c;//0-3
  int offsetX=rc*8;//0-8
  int offsetY=rr*4;//0-12
  int idd=id<16?id:id-16;
  int t1=idd/4;//0-3
  int t2=id%4;//0-3;
  int t3=t2/2;//0-1
  int xx=t1*2+t3;
  int r1=id/16;//0-1
  int r2=r1*2;//0-2
  int r3=idd%4;//0-3
  int r4=r3%2;//0-1
  int yy=r4+r2;
  int col=xx+offsetX;
  int row=yy+offsetY;
  int index=col+row*32;
  return index;
}


void CalcModuleInfoByIndex(boolean isLight, int inNormalID, Module485 module)
{
  if (!isLight)//电机   16个485   *32
  {
    int _col=inNormalID%32;
    int _row=inNormalID/32;
    int secCol=_col/8;  //0-31  /8    0-4
    int secRow=_row/4;  //0-15  /4    0-4
    //行列颠倒
    int _tsecRow=secCol;
    int _tsecCol=secRow;
    int seq485Dev=_tsecRow*4+_tsecCol;//得到所属模块序号
    module.ownMID=seq485Dev;
    int seqNormalSeqID=secRow*4+secCol;
    int offsetcolOfgrid=seqNormalSeqID%4;//计算所属模块
    int offsetrowOfgrid=seqNormalSeqID/4;
    int offsetColx8=offsetcolOfgrid*8;//计算模块偏移
    int offsetRowx4=offsetrowOfgrid*4;
    int _col_=_col-offsetColx8;//去掉偏移得到就是第一个模块
    int _row_=_row-offsetRowx4;
    int xx=_col_;
    int yy=_row_;
    int seq=xx/2*4+xx%2*2+yy/2*16+yy%2;//得到在模块中的序号.
    module.seqID=seq;
  } else    //灯柱      4 * 128
  {
    int _col=inNormalID%32;
    int _row=inNormalID/32;
    int secCol=_col/8;  //0-31  /8    0-4    0 1
    int secRow=_row/16;  //0-32  /4    0-1    0 0
    //不用颠倒
    int _tsecRow=secRow;//0
    int _tsecCol=secCol;//0-4
    int seq485Dev=_tsecRow*4+_tsecCol;//得到所属模块序号
    module.ownMID=seq485Dev;
    int seqNormalSeqID=secRow*4+secCol;
    int offsetcolOfgrid=seqNormalSeqID%4;//计算所属模块
    int offsetrowOfgrid=seqNormalSeqID/4;
    int offsetColx8=offsetcolOfgrid*8;//计算模块偏移
    int offsetRowx0=offsetrowOfgrid*0;
    int _col_=_col-offsetColx8;//去掉偏移得到就是第一个模块
    int _row_=_row-offsetRowx0;

    int xx=_col_;
    int yy=_row_;
    int seq=xx/2*4+xx%2*2+yy/2*16+yy%2;//得到在模块中的序号.
    module.seqID=seq;
  }
}


//----------class Module485-----------///
class Module485
{
  Module485() {
  }
  Module485(int ownMid, int seqId)
  {
    this.ownMID=ownMid;
    this.seqID=seqId;
  }
  int ownMID;//1-16
  int seqID;//1-12
}
