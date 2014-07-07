package me.army8735.xcution.http
{
  public class HttpLine
  {
    private var 字符串:String;
    private var 方法名:String;
    private var 地址名:String;
    private var 主机名:String;
    private var 路径名:String;
    private var 协议名:String;
    private var 端口号:int;
    
    public function HttpLine(字符串:String)
    {
      this.字符串 = 字符串;
      解析(字符串);
    }
    private function 解析(字符串:String):void {
      var 数据:Array = 字符串.split(" ");
      方法名 = 数据[0];
      地址名 = 数据[1];
      协议名 = 数据[2];
      var 匹配:Array = 地址名.match(/^(.+?:\/\/[^\/]+)(?:\:(\d+))?(.*)/);
      主机名 = 匹配[1];
      端口号 = 匹配[2] || 80;
      路径名 = 匹配[3];
    }
    public function get 内容():String {
      return this.字符串;
    }
    public function get 方法():String {
      return this.方法名;
    }
    public function get 地址():String {
      return this.地址名;
    }
    public function get 主机():String {
      return this.主机名;
    }
    public function get 路径():String {
      return this.路径名;
    }
    public function get 端口():int {
      return 端口号;
    }
    public function get 协议():String {
      return 协议名;
    }
  }
}