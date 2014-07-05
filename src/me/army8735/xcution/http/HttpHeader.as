package me.army8735.xcution.http
{
  public class HttpHeader
  {
    private var 字符串:String;
    private var 方法名:String;
    private var 路径名:String;
    
    public function HttpHeader(字符串:String)
    {
      this.字符串 = 字符串;
      解析(字符串);
    }
    private function 解析(字符串:String):void {
      var 列表:Array = 字符串.split("\r\n");
      列表.forEach(function(项:String, 索引:int, 列表:Array):void {
        var 数据:Array = 项.split(" ");
        var 键:String = 数据[0];
        if(键 == "GET" || 键 == "POST") {
          this.方法名 = 键;
          this.路径名 = 数据[1];
        }
      });
    }
    private function get 方法():String {
      return this.方法名;
    }
    private function get 路径():String {
      return this.路径名;
    }
    private function get 内容():String {
      return this.字符串;
    }
  }
}