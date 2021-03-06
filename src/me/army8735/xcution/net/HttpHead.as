package me.army8735.xcution.net
{
  import flash.utils.Dictionary;

  public class HttpHead
  {
    private var 字符串:String;
    private var 字典:Dictionary;
    
    public function HttpHead(字符串:String)
    {
      this.字符串 = 字符串;
      字典 = new Dictionary();
      var 上次键:String;
      字符串.split("\r\n").forEach(function(项:String, 索引:int, 列表:Array):void {
        if(/^\s/.test(项)) {
          字典[上次键] += 项.replace(/^\s/, "");
          return;
        }
        var 索引2:int = 项.indexOf(":");
        var 键:String = 项.substring(0, 索引2);
        var 值:String = 项.substr(索引2 + 1).replace(/^\s/, "");
        字典[键] = 值;
        上次键 = 键;
      });
    }
    public function get 键值对():Dictionary {
      return this.字典;
    }
    public function 获取(键:String):String {
      if(键值对.hasOwnProperty(键)) {
        return 键值对[键];
      }
      return null;
    }
    public function get 内容():String {
      return 字符串 + "\r\n\r\n";
    }
  }
}