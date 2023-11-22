
public static final byte[] intToByteArray(int value) {
  return new byte[] {
    (byte)(value >> 24),
    (byte)(value >> 16),
    (byte)(value >> 8),
    (byte)value};
}
import java.nio.ByteBuffer;
public static final int byteArrayToInt(byte[] btArray) {
   return ByteBuffer.wrap(btArray).getInt();
}
public static boolean contains(int[] array, int target) {
        for (int num : array) {
            if (num == target) {
                return true;
            }
        }
        return false;
    }


public static final byte[] shortToByteArray(short value) {
  return new byte[] {
    (byte)(value >> 8),
    (byte)value};
}


void ResetColorArray()
{
  for (int n=0; n<512; n++)
  {
    unit_fill_colors[n]=color(100);
  }
}

void ChangeMotorAcc(int spd)
{
  SliderSpeed.setValue(500);
  SliderAcc.setValue(spd);
}
void ResetSpdAcc()
{
  SliderSpeed.setValue(rememberSpd);
  SliderAcc.setValue(rememberAcc);
}


float getDistance(PVector p1, PVector p2) {
  return dist(p1.x, p1.y, p2.x, p2.y);
}
float getAppElapsedTimef()
{
  return millis()/1000.f;
}
//x*x/a/a+y*y/b/b < 1

void updateBackgroundWithAlpha(int alpha)
{
  noStroke();
  fill(0, 0, 0, alpha);
  rect(0, 0, width, height);
}

// method 1, int need 4 bytes, default ByteOrder.BIG_ENDIAN
public static byte[] convertIntToByteArray(int value) {
  return  ByteBuffer.allocate(4).putInt(value).array();
}

// method 2, bitwise right shift
public static byte[] convertIntToByteArray2(int value) {
  return new byte[] {
    (byte)(value >> 24),
    (byte)(value >> 16),
    (byte)(value >> 8),
    (byte)value };
}

public static String convertBytesToHex(byte[] bytes) {
  StringBuilder result = new StringBuilder();
  for (byte temp : bytes) {
    result.append(String.format("%02x", temp));
  }
  return result.toString();
}

//  byte[] byteArray = new byte[] {00, 00, 00, 01};
//  int num = ByteBuffer.wrap(bytes).getInt();

String GetDate()
{
  int year=year();
  int month=month();
  int day=day();
  return  str(year)+"-"+nf(month, 2)+nf(day);
}
String GetFormatedDateTime()
{
  int year=year();
  int month=month();
  int day=day();
  int hour=hour();
  int mint=minute();
  int second=second();
  return str(year)+"/"+nf(month, 2)+"/"+nf(day)+"-"+nf(hour, 2)+":"+nf(mint, 2)+":"+nf(second, 2)+" => ";
}

float[] rgbToHsv(int[] rgb) {
  //切割rgb数组
  int R = rgb[0];
  int G = rgb[1];
  int B = rgb[2];
  //公式运算 /255
  float R_1 = R / 255f;
  float G_1 = G / 255f;
  float B_1 = B / 255f;
  //重新拼接运算用数组
  float[] all = {R_1, G_1, B_1};
  float max = all[0];
  float min = all[0];
  //循环查找最大值和最小值
  for (int i = 0; i < all.length; i++) {
    if (max <= all[i]) {
      max = all[i];
    }
    if (min >= all[i]) {
      min = all[i];
    }
  }
  float C_max = max;
  float C_min = min;
  //计算差值
  float diff = C_max - C_min;
  float hue = 0f;
  //判断情况计算色调H
  if (diff == 0f) {
    hue = 0f;
  } else {
    if (C_max == R_1) {
      hue = (((G_1 - B_1) / diff) % 6) * 60f;
    }
    if (C_max == G_1) {
      hue = (((B_1 - R_1) / diff) + 2f) * 60f;
    }
    if (C_max == B_1) {
      hue = (((R_1 - G_1) / diff) + 4f) * 60f;
    }
  }
  //计算饱和度S
  float saturation;
  if (C_max == 0f) {
    saturation = 0f;
  } else {
    saturation = diff / C_max;
  }
  //计算明度V
  float value = C_max;
  float[] result = {hue, saturation, value};
  return result;
}

CRC16Util crc16 = new CRC16Util();
public class CRC16Util {
  byte[] crc16_tab_h = {(byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0,
    (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1,
    (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0,
    (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0,
    (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x01, (byte) 0xC0, (byte) 0x80, (byte) 0x41, (byte) 0x00, (byte) 0xC1, (byte) 0x81, (byte) 0x40};

  byte[] crc16_tab_l = {(byte) 0x00, (byte) 0xC0, (byte) 0xC1, (byte) 0x01, (byte) 0xC3, (byte) 0x03, (byte) 0x02, (byte) 0xC2, (byte) 0xC6, (byte) 0x06, (byte) 0x07, (byte) 0xC7, (byte) 0x05, (byte) 0xC5, (byte) 0xC4, (byte) 0x04, (byte) 0xCC, (byte) 0x0C, (byte) 0x0D, (byte) 0xCD, (byte) 0x0F, (byte) 0xCF, (byte) 0xCE, (byte) 0x0E, (byte) 0x0A, (byte) 0xCA, (byte) 0xCB, (byte) 0x0B, (byte) 0xC9, (byte) 0x09, (byte) 0x08, (byte) 0xC8, (byte) 0xD8, (byte) 0x18, (byte) 0x19, (byte) 0xD9, (byte) 0x1B, (byte) 0xDB, (byte) 0xDA, (byte) 0x1A, (byte) 0x1E, (byte) 0xDE, (byte) 0xDF, (byte) 0x1F, (byte) 0xDD, (byte) 0x1D, (byte) 0x1C, (byte) 0xDC, (byte) 0x14, (byte) 0xD4, (byte) 0xD5, (byte) 0x15, (byte) 0xD7, (byte) 0x17, (byte) 0x16, (byte) 0xD6, (byte) 0xD2, (byte) 0x12,
    (byte) 0x13, (byte) 0xD3, (byte) 0x11, (byte) 0xD1, (byte) 0xD0, (byte) 0x10, (byte) 0xF0, (byte) 0x30, (byte) 0x31, (byte) 0xF1, (byte) 0x33, (byte) 0xF3, (byte) 0xF2, (byte) 0x32, (byte) 0x36, (byte) 0xF6, (byte) 0xF7, (byte) 0x37, (byte) 0xF5, (byte) 0x35, (byte) 0x34, (byte) 0xF4, (byte) 0x3C, (byte) 0xFC, (byte) 0xFD, (byte) 0x3D, (byte) 0xFF, (byte) 0x3F, (byte) 0x3E, (byte) 0xFE, (byte) 0xFA, (byte) 0x3A, (byte) 0x3B, (byte) 0xFB, (byte) 0x39, (byte) 0xF9, (byte) 0xF8, (byte) 0x38, (byte) 0x28, (byte) 0xE8, (byte) 0xE9, (byte) 0x29, (byte) 0xEB, (byte) 0x2B, (byte) 0x2A, (byte) 0xEA, (byte) 0xEE, (byte) 0x2E, (byte) 0x2F, (byte) 0xEF, (byte) 0x2D, (byte) 0xED, (byte) 0xEC, (byte) 0x2C, (byte) 0xE4, (byte) 0x24, (byte) 0x25, (byte) 0xE5, (byte) 0x27, (byte) 0xE7,
    (byte) 0xE6, (byte) 0x26, (byte) 0x22, (byte) 0xE2, (byte) 0xE3, (byte) 0x23, (byte) 0xE1, (byte) 0x21, (byte) 0x20, (byte) 0xE0, (byte) 0xA0, (byte) 0x60, (byte) 0x61, (byte) 0xA1, (byte) 0x63, (byte) 0xA3, (byte) 0xA2, (byte) 0x62, (byte) 0x66, (byte) 0xA6, (byte) 0xA7, (byte) 0x67, (byte) 0xA5, (byte) 0x65, (byte) 0x64, (byte) 0xA4, (byte) 0x6C, (byte) 0xAC, (byte) 0xAD, (byte) 0x6D, (byte) 0xAF, (byte) 0x6F, (byte) 0x6E, (byte) 0xAE, (byte) 0xAA, (byte) 0x6A, (byte) 0x6B, (byte) 0xAB, (byte) 0x69, (byte) 0xA9, (byte) 0xA8, (byte) 0x68, (byte) 0x78, (byte) 0xB8, (byte) 0xB9, (byte) 0x79, (byte) 0xBB, (byte) 0x7B, (byte) 0x7A, (byte) 0xBA, (byte) 0xBE, (byte) 0x7E, (byte) 0x7F, (byte) 0xBF, (byte) 0x7D, (byte) 0xBD, (byte) 0xBC, (byte) 0x7C, (byte) 0xB4, (byte) 0x74,
    (byte) 0x75, (byte) 0xB5, (byte) 0x77, (byte) 0xB7, (byte) 0xB6, (byte) 0x76, (byte) 0x72, (byte) 0xB2, (byte) 0xB3, (byte) 0x73, (byte) 0xB1, (byte) 0x71, (byte) 0x70, (byte) 0xB0, (byte) 0x50, (byte) 0x90, (byte) 0x91, (byte) 0x51, (byte) 0x93, (byte) 0x53, (byte) 0x52, (byte) 0x92, (byte) 0x96, (byte) 0x56, (byte) 0x57, (byte) 0x97, (byte) 0x55, (byte) 0x95, (byte) 0x94, (byte) 0x54, (byte) 0x9C, (byte) 0x5C, (byte) 0x5D, (byte) 0x9D, (byte) 0x5F, (byte) 0x9F, (byte) 0x9E, (byte) 0x5E, (byte) 0x5A, (byte) 0x9A, (byte) 0x9B, (byte) 0x5B, (byte) 0x99, (byte) 0x59, (byte) 0x58, (byte) 0x98, (byte) 0x88, (byte) 0x48, (byte) 0x49, (byte) 0x89, (byte) 0x4B, (byte) 0x8B, (byte) 0x8A, (byte) 0x4A, (byte) 0x4E, (byte) 0x8E, (byte) 0x8F, (byte) 0x4F, (byte) 0x8D, (byte) 0x4D,
    (byte) 0x4C, (byte) 0x8C, (byte) 0x44, (byte) 0x84, (byte) 0x85, (byte) 0x45, (byte) 0x87, (byte) 0x47, (byte) 0x46, (byte) 0x86, (byte) 0x82, (byte) 0x42, (byte) 0x43, (byte) 0x83, (byte) 0x41, (byte) 0x81, (byte) 0x80, (byte) 0x40};

  /**
   * 计算CRC16校验  对外的接口
   * @param data 需要计算的数组
   * @return CRC16校验值
   */
  public  int calcCrc16(byte[] data) {
    return calcCrc16(data, 0, data.length);
  }

  /**
   * 计算CRC16校验
   *
   * @param data   需要计算的数组
   * @param offset 起始位置
   * @param len    长度
   * @return CRC16校验值
   */
  public  int calcCrc16(byte[] data, int offset, int len) {
    return calcCrc16(data, offset, len, 0xffff);
  }

  /**
   * 计算CRC16校验
   *
   * @param data   需要计算的数组
   * @param offset 起始位置
   * @param len    长度
   * @param preval 之前的校验值
   * @return CRC16校验值
   */
  int calcCrc16(byte[] data, int offset, int len, int preval) {
    int ucCRCHi = (preval & 0xff00) >> 8;
    int ucCRCLo = preval & 0x00ff;
    int iIndex;
    for (int i = 0; i < len; ++i) {
      iIndex = (ucCRCHi ^ data[offset + i]) & 0x00ff;
      ucCRCHi = ucCRCLo ^ crc16_tab_h[iIndex];
      ucCRCLo = crc16_tab_l[iIndex];
    }
    return ((ucCRCHi & 0x00ff) << 8) | (ucCRCLo & 0x00ff) & 0xffff;
  }
  public byte[] getCrcByte(int res)
  {
    byte[]hl=new byte[2];
    hl[0]=(byte)((res>>8)&0xff);
    hl[1]=(byte)res;
    return hl;
  }
  /**
   * 将计算的CRC值 转换为加空格的  比如  ： crc值为 A30A -> A3 0A
   * @param res
   * @return
   */
  public  String getCrc(int res) {
    String format = String.format("%04x", res);
    String substring = format.substring(0, 2);
    String substring1 = format.substring(2, 4);
    return substring.concat(" ").concat(substring1).concat(" ");
  }
}
