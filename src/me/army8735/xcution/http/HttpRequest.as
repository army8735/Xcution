package me.army8735.xcution.http
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.Socket;
  import flash.utils.ByteArray;
  
  import me.army8735.xcution.events.HttpEvent;
  
  public class HttpRequest extends EventDispatcher
  {
    private var 套接字:Socket;
    private var 行:HttpLine;
    private var 头:HttpHead;
    private var 体:HttpBody;
    
    private var 接收数据:ByteArray;
    private var 状态:int;
    private static const 开始:int = 0;
    private static const 完成头:int = 1;
    
    public function HttpRequest(原始内容:String, 行:HttpLine, 头:HttpHead, 体:HttpBody)
    {
      this.行 = 行;
      this.头 = 头;
      this.体 = 体;
    }
    public function 链接():void {
      套接字 = new Socket();
      套接字.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
        trace(event);
      });
      套接字.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
        trace(event);
      });
      套接字.addEventListener(Event.CONNECT, function(event:Event):void {
        trace(event);
        套接字.writeUTFBytes(行.兼容内容);
        套接字.writeUTFBytes(头.内容);
        套接字.writeUTFBytes(体.内容);
        套接字.flush();
      });
      套接字.addEventListener(ProgressEvent.SOCKET_DATA, function(event:ProgressEvent):void {
        trace(event);
        if(接收数据 === null) {
          接收数据 = new ByteArray();
          状态 = 开始;
        }
        if(套接字.bytesAvailable > 0) {
          套接字.readBytes(接收数据);
          分析数据();
        }
      });
      套接字.addEventListener(Event.CLOSE, function(event:Event):void {
        trace(event);
        var 剩余数据:ByteArray = new ByteArray();
        if(套接字.bytesAvailable > 0) {
          套接字.readBytes(剩余数据);
        }
        dispatchEvent(new HttpEvent(HttpEvent.关闭, 剩余数据));
        套接字 = null;
      });
      套接字.connect(行.主机, 行.端口);
    }
    private function 分析数据():void {
      var 数据:ByteArray = new ByteArray();
      switch(状态) {
        case 开始:
          for(var 索引:int = 0; 索引 < 接收数据.bytesAvailable; 索引++) {
            if(接收数据[索引] == 13
              && 接收数据[索引+1] == 10
              && 接收数据[索引+2] == 13
              && 接收数据[索引+3] == 10) {
              接收数据.readBytes(数据, 0, 索引+4);
              状态 = 完成头;
              trace("完成头");
              trace(数据.toString());
              dispatchEvent(new HttpEvent(HttpEvent.流, 数据));
              if(接收数据.bytesAvailable > 0) {
                分析数据();
              }
              break;
            }
          }
          break;
        case 完成头:
          if(接收数据.bytesAvailable > 0) {
            接收数据.readBytes(数据);
            trace("继续体");
            trace(数据.toString());
            dispatchEvent(new HttpEvent(HttpEvent.流, 数据));
          }
          break;
      }
    }
  }
}