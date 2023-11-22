import java.io.OutputStream; //<>// //<>//
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

JSONObject json;
String yunzhijieUrl;


void RobotMsg(String contents, boolean bAt)
{
  json=loadJSONObject("json.json");
  String time=str(year())+"/"+str(month())+"/"+str(day())+" "+nf(hour())+":"+nf(minute(), 2)+":"+nf(second(), 2);
  String newCon=time+" <==> "+ contents;
  json.setString("content", newCon);
  if (!bAt)
  {
    json.remove("notifyParams");
  }
  String  postData=json.toString();
  try {
    URL urlObj = new URL(yunzhijieUrl);
    HttpURLConnection connection = (HttpURLConnection) urlObj.openConnection();

    // Set up the connection for POST
    connection.setRequestMethod("POST");
    connection.setDoOutput(true);
    connection.setRequestProperty("Content-Type", "application/json;charset=utf-8");

    // Write data to the connection
    try (OutputStream os = connection.getOutputStream()) {
      byte[] postDataBytes = postData.getBytes(StandardCharsets.UTF_8);
      os.write(postDataBytes);
    }
    // Get the response
    int responseCode = connection.getResponseCode();
    System.out.println("Response Code: " + responseCode);
    connection.disconnect();
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}
