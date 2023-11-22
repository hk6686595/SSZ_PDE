//<>// //<>// //<>//
/*
  由点组成的数字
 */
static int[][] G_Array = new int[16][32];

IntList ilist=new IntList();

IntList getArrayDetail()
{
  ilist.clear();
  for (int y=0; y<16; y++)
  {
    for (int x=0; x<32; x++)
    {
      if (G_Array[y][x]==1)
      {
        ilist.append(y*32+x);
      }
    }
  }
  return ilist;
}
void zeroArray()
{
  for (int y=0; y<16; y++)
  {
    for (int x=0; x<32; x++)
    {
      G_Array[y][x]=0;
    }
  }
}

void setArray(int col, int row, int v)
{
  v=constrain(v, 0, 1);

  if (row>=0 && row<16 && col>=0 && col<32)
  {
    G_Array[row][col]=v;
  }
}

int h1=2, h2=9, h3=18, h4=25;//时间数字起始x位置
int ver=4;//时间数字起始y位置
int d1=0, d2=6, d3=12, d4=18, d5=28, d6=34, d7=44, d8=50;
int xAdd=30;
ENumber[] timeEnums=new ENumber[4];
ENumber[] DataEnums=new ENumber[8];
Dot3 dot3=new Dot3();
Dot3 dot33=new Dot3();
void InitLEDnumbers()
{
  timeEnums[0]=new ENumber( h1, ver);
  timeEnums[1]=new ENumber( h2, ver);
  timeEnums[2]=new ENumber( h3, ver);
  timeEnums[3]=new ENumber( h4, ver);

  DataEnums[0]=new ENumber( d1+xAdd, ver);
  DataEnums[1]=new ENumber( d2+xAdd, ver);
  DataEnums[2]=new ENumber( d3+xAdd, ver);
  DataEnums[3]=new ENumber( d4+xAdd, ver);
  DataEnums[4]=new ENumber( d5+xAdd, ver);
  DataEnums[5]=new ENumber( d6+xAdd, ver);
  DataEnums[6]=new ENumber( d7+xAdd, ver);
  DataEnums[7]=new ENumber( d8+xAdd, ver);

  //dot33.FlushToAry();
  int year=year();
  int ye1=year/1000;
  int y2=year/100%10;
  int y3=year/10%10;
  int y4=year%10;

  DataEnums[0].matchNum(ye1);
  DataEnums[1].matchNum(y2);
  DataEnums[2].matchNum(y3);
  DataEnums[3].matchNum(y4);

  int mon=month();//0-12
  int m1=mon/10;
  int m2=mon%10;
  DataEnums[4].matchNum(m1);
  DataEnums[5].matchNum(m2);

  int day=day();//0-31
  int d1=day/10;
  int d2=day%10;
  DataEnums[6].matchNum(d1);
  DataEnums[7].matchNum(d2);
  ResetOriginPos();

  etime=getAppElapsedTimef();
}

void ResetOriginPos()
{
  timeEnums[0].resetpos();
  timeEnums[1].resetpos();
  timeEnums[2].resetpos();
  timeEnums[3].resetpos();

  DataEnums[0].resetpos();
  DataEnums[1].resetpos();
  DataEnums[2].resetpos();
  DataEnums[3].resetpos();
  DataEnums[4].resetpos();
  DataEnums[5].resetpos();
  DataEnums[6].resetpos();
  DataEnums[7].resetpos();

  dot3.MoveTo(d4+xAdd+6, ver+4);
  dot33.MoveTo(d6+xAdd+6, ver+4);
}

float freshInterval=1.f;
float etime=0;
boolean isSet=false;

void LEDDateUpdate()
{
  if (getAppElapsedTimef()-etime<0.2)
  {
    return;
  }
  etime=getAppElapsedTimef();
  zeroArray();
  //dot3.leftOneStep();
  //dot3.FlushToAry();
  dot33.leftOneStep();
  dot33.FlushToAry();
  for (int ndx=0; ndx<8; ndx++)
  {
    DataEnums[ndx].leftOnestep();
    DataEnums[ndx]. FlushToAry();
  }
}

void LEDTimeUpdate()
{
  if (getAppElapsedTimef()-etime<freshInterval)
  {
    return;
  }
  etime=getAppElapsedTimef();

  int hour=hour();
  int min=minute();
  int _1=hour/10;
  int _2=hour%10;
  int _3=min/10;
  int _4=min%10;

  timeEnums[0].matchNum(_1);
  timeEnums[0].FlushToAry();
  timeEnums[1].matchNum(_2);
  timeEnums[1].FlushToAry();
  timeEnums[2].matchNum(_3);
  timeEnums[2].FlushToAry();
  timeEnums[3].matchNum(_4);
  timeEnums[3].FlushToAry();

  if (timeEnums[2].getValue()==1)
  {
    if (!isSet)
    {
      isSet=true;
      setDotXpos(timeEnums[2].getXpos()-1);
    }
  } else
  {
    if ( isSet)
    {
      isSet=false;
      setDotXpos(timeEnums[2].getXpos()-3);
    }
  }
  updateDot();
}

void DarwtoPanel()
{
  push();
  background(50);
  colorMode(HSB, 360,100,100);
  for (int y=0; y<16; y++)
  {
    for (int x=0; x<32; x++)
    {
      if (G_Array[y][x]==1)
      {
        time_color_fg=color(frameCount%360,100,100);
        fill(time_color_fg);
      } else
      {
        fill(time_color_bg);
      }
      ellipse(x*30+startX, y*30+startY, 20, 20);
    }
  }
  pop();
}

final int w=5;//单个数字占用5列9行
final int h=9;

class ENumber
{
  int value;
  int curX=0, curY=0;
  int savePosX, savePosY;
  color c;
  int[][] m_array=new int[9][5];

  ENumber( int begeinx, int beginy)
  {
    savePosX=begeinx;
    savePosY=beginy;
    value=8;
    matchNum(value);
    moveDeltaXY(begeinx, beginy);
  }
  void resetpos()
  {
    curX=savePosX;
    curY=savePosY;
  }
  void setPos(int x, int  y)
  {
    curX=x;
    curY=y;
  }

  void moveDeltaXY(int offx, int offy)
  {
    curX+=offx;
    curY+=offy;
  }

  void leftOnestep()
  {
    moveDeltaXY(-1, 0);
  }
  void rightOnestep()
  {
    moveDeltaXY(1, 0);
  }
  void upOnestep()
  {
    moveDeltaXY(0, -1);
  }
  void downOnestep()
  {
    moveDeltaXY(0, 1);
  }

  int getXpos()
  {
    return curX;
  }
  int getValue()
  {
    return value;
  }

  void matchNum(int n)
  {
    value=n;
    switch(n)
    {
    case 0:
      m_array=zero;
      break;
    case 1:
      m_array=One;
      break;
    case 2:
      m_array=Two;
      break;
    case 3:
      m_array=Three;
      break;
    case 4:
      m_array=Four;
      break;
    case 5:
      m_array=Five;
      break;
    case 6:
      m_array=Six;
      break;
    case 7:
      m_array=Seven;
      break;
    case 8:
      m_array=Eigth;
      break;
    case 9:
      m_array=Nine;
      break;
    }
  }

  void FlushToAry()
  {
    for (int r=0; r<9; r++)
    {
      for (int c=0; c<5; c++)
      {
        int arow=r+curY;
        int acol=c+curX;
        if (curX==-5)
        {
          curX+=65;
        }
        if (curY==-9)
        {
          curY=33;
        }
        if (arow<16 && arow>=0 && acol<32 && acol>=0)
          G_Array[arow][acol]=m_array[r][c];
      }
    }
  }
}


class Dot
{
  int row, col, flag;
  Dot(int c, int r)
  {
    col=c;
    row=r;
    flag=1;
  }

  void left()
  {
    col-=1;
  }

  void setPos(int newx, int newy )
  {
    col=newx;
    row=newy;
  }
  void setFlg(int f)
  {
    f=constrain(f, 0, 1);
    flag=f;
  }

  void write()
  {
    if (row<16 && row>=0 && col<32 && col>=0)
      G_Array[row][col]=flag;
  }
}

class Dot3
{
  Dot[] dots=new Dot[3];
  int Row=0, Col=0;
  Dot3()
  {
    dots[0]=new Dot(0, 0);
    dots[1]=new Dot(1, 0);
    dots[2]=new Dot(2, 0);
  }

  void MoveTo(int tarCol, int tarRow)
  {
    Col=tarCol;
    Row=tarRow;
    dots[0].setPos(Col, Row );
    dots[1].setPos(Col+1, Row );
    dots[2].setPos(Col+2, Row);
  }

  void leftOneStep()
  {
    dots[0].left();
    dots[1].left();
    dots[2].left();
  }

  void FlushToAry()
  {
    int curX=dots[0].col;
    int curY=dots[0].row;

    for (int c=0; c<3; c++)
    {
      int acol=curX+c;
      int arow=dots[0].row;
      if (curX==-3)
      {
        dots[c].setPos(curX+65+c, curY);
      }
      if (curY==-9)
      {
        dots[c].setPos(curX, curY+16);
      }
      dots[c].write();
    }
  }
}

int dot1Col=15, dot1Row=7;
int dot2Col=16, dot2Row=7;
int dot3Col=15, dot3Row=9;
int dot4Col=16, dot4Row=9;

void dotMove(int offx)
{
  dot1Row+=offx;
  dot2Row+=offx;
  dot3Row+=offx;
  dot4Row+=offx;
}

void setDotXpos(int nx)
{
  setArray(dot1Row, dot1Col, 0);
  setArray(dot2Row, dot2Col, 0);
  setArray(dot3Row, dot3Col, 0);
  setArray(dot4Row, dot4Col, 0);

  dot1Col=nx;
  dot2Col=dot1Col+1;
  dot3Col=dot1Col;
  dot4Col=dot2Col;
}
void updateDot()
{
  G_Array[dot1Row][dot1Col]=1-G_Array[dot1Row][dot1Col];
  G_Array[dot2Row][dot2Col]=G_Array[dot1Row][dot1Col];
  G_Array[dot3Row][dot3Col]=G_Array[dot1Row][dot1Col];
  G_Array[dot4Row][dot4Col]=G_Array[dot1Row][dot1Col];
}


//数字二维数组
int[][] zero={
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 1, 1, 1, 1}
};
int[][] One={
  {0, 0, 0, 1, 0},
  {0, 0, 0, 1, 0},
  {0, 0, 0, 1, 0},
  {0, 0, 0, 1, 0},
  {0, 0, 0, 1, 0},
  {0, 0, 0, 1, 0},
  {0, 0, 0, 1, 0},
  {0, 0, 0, 1, 0},
  {0, 0, 0, 1, 0}
};
int[][] Two={
  {1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 0},
  {1, 0, 0, 0, 0},
  {1, 0, 0, 0, 0},
  {1, 1, 1, 1, 1}
};

int[][] Three={
  {1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1}
};

int[][] Four={
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1}
};

int[][] Five={
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 0},
  {1, 0, 0, 0, 0},
  {1, 0, 0, 0, 0},
  {1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1}
};

int[][] Six={
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 0},
  {1, 0, 0, 0, 0},
  {1, 0, 0, 0, 0},
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 1, 1, 1, 1}
};
int[][] Seven={
  {1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1}
};

int[][] Eigth={
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 1, 1, 1, 1}
};

int[][] Nine={
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 1, 1, 1, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1}
};

int[][] xox={
  {0, 0, 0},
  {0, 0, 0},
  {0, 0, 0},
  {0, 0, 0},
  {1, 1, 1},
  {0, 0, 0},
  {0, 0, 0},
  {0, 0, 0},
  {0, 0, 0}
};
