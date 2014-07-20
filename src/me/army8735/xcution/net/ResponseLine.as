package me.army8735.xcution.net
{
  public class ResponseLine
  {
    private var 字符串:String;
    private var 协议名:String;
    private var 版本名:String;
    private var 状态码名:int;
    private var 消息描述:String;
    
    public function ResponseLine(字符串:String)
    {
      this.字符串 = 字符串;
      解析(字符串);
    }
    private function 解析(字符串:String):void {
      var 数据:Array = 字符串.split(" ");
      var 协议版本:Array = 数据[0].split("/");
      协议名 = 协议版本[0];
      版本名 = 协议版本[1];
      状态码名 = parseInt(数据[1]);
      消息描述 = 数据[2];
    }
    public function get 内容():String {
      return 字符串 + "\r\n";
    }
    public function get 协议():String {
      return 协议名;
    }
    public function get 版本():String {
      return 版本名;
    }
    public function get 状态码():int {
      return 状态码名;
    }
    public function get 消息():String {
      return 消息描述;
    }
  }
}