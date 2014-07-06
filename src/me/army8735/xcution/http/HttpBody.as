package me.army8735.xcution.http
{
  public class HttpBody
  {
    private var 字符串:String;
    
    public function HttpBody(字符串:String)
    {
      this.字符串 = 字符串;
    }
    public function get 内容():String {
      return 字符串;
    }
  }
}