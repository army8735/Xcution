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
    private var 客户端:Socket;
    
    private var 套接字:Socket;
    private var 行:RequestLine;
    private var 头:HttpHead;
    private var 体:HttpBody;
    
    private var 接收数据:ByteArray;
    private var 累计:uint;
    private var 总长度:int;
    private var 块传输:Boolean;
    private var 状态:int;
    private static const 开始:int = 0;
    private static const 完成头:int = 1;
    private static const 结束:int = 2;
    
    private static const 错误码:String = "HTTP/1.1 404 Not found\r\n";
    
    public function HttpRequest(客户端:Socket, 行:RequestLine, 头:HttpHead, 体:HttpBody)
    {
      this.客户端 = 客户端;
      this.行 = 行;
      this.头 = 头;
      this.体 = 体;
    }
    public function 关闭():void {
      if(套接字 && 套接字.connected) {
        套接字.close();
      }
      套接字 = null;
    }
    public function 链接():void {
      累计 = 0;
      总长度 = -1;
      块传输 = false;
      接收数据 = new ByteArray();
      状态 = 开始;
      
      套接字 = new Socket();
      套接字.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
        if(累计 == 0) {
          接收数据.writeUTFBytes(错误码);
          接收数据.writeUTFBytes("\r\n\r\n");
        }
        接收数据.writeUTFBytes(event.text);
        dispatchEvent(new HttpEvent(HttpEvent.关闭, 接收数据));
      });
      套接字.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
        if(累计 == 0) {
          接收数据.writeUTFBytes(错误码);
          接收数据.writeUTFBytes("\r\n\r\n");
        }
        接收数据.writeUTFBytes(event.text);
        dispatchEvent(new HttpEvent(HttpEvent.关闭, 接收数据));
      });
      套接字.addEventListener(Event.CONNECT, function(event:Event):void {
        trace("发出远程链接：", 行.地址);
        套接字.writeUTFBytes(行.兼容内容);
        套接字.writeUTFBytes(头.内容);
        套接字.writeUTFBytes(体.内容);
        套接字.flush();
      });
      套接字.addEventListener(ProgressEvent.SOCKET_DATA, function(event:ProgressEvent):void {
        trace("远程链接数据：", 套接字.bytesAvailable, 行.地址);
        if(套接字.bytesAvailable > 0) {
          var 数据:ByteArray = new ByteArray();
          套接字.readBytes(数据, 0, 套接字.bytesAvailable);
          分析数据(数据);
        }
      });
      套接字.addEventListener(Event.CLOSE, function(event:Event):void {
        trace("远程链接关闭：", 行.地址);
        if(套接字 && 套接字.bytesAvailable > 0) {
          var 数据:ByteArray = new ByteArray();
          套接字.readBytes(数据, 0, 套接字.bytesAvailable);
          if(客户端 && 客户端.connected) {
            客户端.writeBytes(数据);
            客户端.flush();
            客户端.close();
            客户端 = null;
          }
        }
        if(套接字 && 套接字.connected) {
          套接字.close();
          套接字 = null;
        }
      });
      套接字.connect(行.主机, 行.端口);
    }
    private function 分析数据(数据:ByteArray):void {
      var 索引:uint;
      switch(状态) {
        case 开始:
          for(索引 = 0; 索引 < 数据.bytesAvailable; 索引++) {
            if(数据[索引] == 13
              && 数据[索引+1] == 10
              && 数据[索引+2] == 13
              && 数据[索引+3] == 10) {
              状态 = 完成头;
              var 头数据:ByteArray = new ByteArray();
              数据.readBytes(头数据, 0, 索引+4);
              客户端.writeBytes(头数据);
              客户端.flush();
              
              var 内容:String = 头数据.toString();
              索引 = 内容.indexOf("\r\n");
              var 行:ResponseLine = new ResponseLine(内容.substring(0, 索引));
              if(行.状态码 == 304) {
                套接字.dispatchEvent(new Event(Event.CLOSE));
                return;
              }
              var 头体:Array = 内容.substr(索引 + 4).split("\r\n\r\n");
              var 头:HttpHead = new HttpHead(头体[0]);
              var 长度:String = 头.获取("Content-Length");
              if(长度 !== null) {
                总长度 = parseInt(长度);
              }
              var 传输编码:String = 头.获取("Transfer-Encoding");
              if(传输编码 == "chunked") {
                块传输 = true;
              }
              if(数据.bytesAvailable > 0) {
                var 剩余数据:ByteArray = new ByteArray();
                数据.readBytes(剩余数据);
                分析数据(剩余数据);
              }
              break;
            }
          }
          break;
        case 完成头:
          if(数据.bytesAvailable > 0) {
            累计 += 数据.bytesAvailable;
            if(块传输) {
              索引 = 数据.length - 1;
              if(数据[索引] == 10
                && 数据[索引-1] == 13
                && 数据[索引-2] == 10
                && 数据[索引-3] == 13
                && 数据[索引-4] == 48) {
                trace("块结束主动关闭：", 累计, 总长度, this.行.地址);
                客户端.writeBytes(数据);
                客户端.flush();
                客户端.close();
                if(套接字 && 套接字.connected) {
                  套接字.close();
                }
                套接字 = null;
              }
              else {
                客户端.writeBytes(数据);
                客户端.flush();
              }
            }
            else if(总长度 > -1 && 累计 == 总长度) {
              trace("总长度主动关闭：", 累计, 总长度, this.行.地址);
              客户端.writeBytes(数据);
              客户端.flush();
              客户端.close();
              if(套接字 && 套接字.connected) {
                套接字.close();
              }
              套接字 = null;
            }
            else {
              客户端.writeBytes(数据);
              客户端.flush();
            }
          }
          break;
      }
    }
  }
}