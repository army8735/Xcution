package me.army8735.xcution.http
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.net.SecureSocket;
  import flash.net.Socket;
  import flash.utils.ByteArray;
  
  import me.army8735.xcution.MsgField;
  import me.army8735.xcution.proxy.ProxyPanel;
  
  public class HttpRequest extends EventDispatcher
  {
    private var 客户端:Socket;
    private var 控制台:MsgField;
    private var 规则面板:ProxyPanel;
    
    private var 套接字:Socket;
    private var 缓存:ByteArray;
    private var 行:RequestLine;
    private var 头:HttpHead;
    private var 体:HttpBody;
    
    private var 累计:uint;
    private var 总长度:int;
    private var 块传输:Boolean;
    private var 状态:int;
    private static const 开始:int = 0;
    private static const 完成头:int = 1;
    private static const 结束:int = 2;
    
    private static const 正确码:String = "HTTP/1.1 200 OK\r\n";
    private static const 错误码:String = "HTTP/1.1 404 Not found\r\n";
    
    private var 安全套接字:SecureSocket;
    
    public function HttpRequest(客户端:Socket, 行:RequestLine, 头:HttpHead, 体:HttpBody, 控制台:MsgField, 规则面板:ProxyPanel)
    {
      this.客户端 = 客户端;
      this.控制台 = 控制台;
      this.规则面板 = 规则面板;
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
      var 映射:String = 规则面板.获取映射(行.地址);
      if(映射) {
        写入本地内容(映射);
        return;
      }
      累计 = 0;
      总长度 = -1;
      块传输 = false;
      状态 = 开始;
      缓存 = new ByteArray();
      
      套接字 = new Socket();
      套接字.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
        trace(event.text);
        var 数据:ByteArray = new ByteArray();
        if(累计 == 0) {
          数据.writeUTFBytes(错误码);
          数据.writeUTFBytes("\r\n\r\n");
        }
        if(套接字.bytesAvailable > 0) {
          套接字.readBytes(数据, 数据.length);
        }
        数据.writeUTFBytes(event.text);
        if(客户端 && 客户端.connected) {
          客户端.writeBytes(数据);
          客户端.flush();
          客户端.close();
          客户端 = null;
        }
        if(套接字 && 套接字.connected) {
          套接字.close();
          套接字 = null;
        }
      });
      套接字.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
        trace(event.text);
        var 数据:ByteArray = new ByteArray();
        if(累计 == 0) {
          数据.writeUTFBytes(错误码);
          数据.writeUTFBytes("\r\n\r\n");
        }
        if(套接字.bytesAvailable > 0) {
          套接字.readBytes(数据, 数据.length);
        }
        if(客户端 && 客户端.connected) {
          客户端.writeBytes(数据);
          客户端.flush();
          客户端.close();
          客户端 = null;
        }
        数据.writeUTFBytes(event.text);
        if(套接字 && 套接字.connected) {
          套接字.close();
          套接字 = null;
        }
      });
      套接字.addEventListener(Event.CONNECT, function(event:Event):void {
        控制台.代理(行.地址);
        trace("成功远程链接：", 行.地址);
        套接字.writeUTFBytes(行.兼容内容);
        套接字.writeUTFBytes(头.内容);
        套接字.writeUTFBytes(体.内容);
        套接字.flush();
      });
      套接字.addEventListener(ProgressEvent.SOCKET_DATA, function(event:ProgressEvent):void {
        trace("远程链接数据：", 套接字.bytesAvailable, 行.地址);
        if(套接字.bytesAvailable > 0) {
          var 数据:ByteArray = new ByteArray();
          if(缓存.bytesAvailable > 0) {
            数据.readBytes(缓存);
          }
          套接字.readBytes(数据, 0, 套接字.bytesAvailable);
          分析数据(数据);
        }
      });
      套接字.addEventListener(Event.CLOSE, function(event:Event):void {
        trace("远程链接关闭：", 行.地址);
        var 数据:ByteArray = new ByteArray();
        if(缓存.bytesAvailable > 0) {
          数据.readBytes(缓存);
        }
        if(套接字 && 套接字.bytesAvailable > 0) {
          套接字.readBytes(数据, 0, 套接字.bytesAvailable);
        }
        if(客户端 && 客户端.connected) {
          客户端.writeBytes(数据);
          客户端.flush();
          客户端.close();
          客户端 = null;
        }
        if(套接字 && 套接字.connected) {
          套接字.close();
          套接字 = null;
        }
      });
      trace("发出远程链接：", 行.地址, 行.主机, 行.端口);
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
          缓存.readBytes(数据);
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
                客户端 = null;
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
            else if(总长度 > -1 && 累计 >= 总长度) {
              trace("总长度主动关闭：", 累计, 总长度, this.行.地址);
              客户端.writeBytes(数据);
              客户端.flush();
              客户端.close();
              客户端 = null;
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
    private function 写入本地内容(映射:String):void {
      控制台.追加高亮("映射：" + 行.地址 + " ☞ " + 映射);
      var 文件:File = new File(映射);
      if(!文件.exists) {
        本地文件不存在(映射);
      }
      var 文件流:FileStream = new FileStream();
      文件流.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
        本地文件不存在(映射, event.text);
      });
      文件流.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
        本地文件不存在(映射, event.text);
      });
      文件流.open(文件, FileMode.READ);
      var 数据:ByteArray = new ByteArray();
      文件流.readBytes(数据);
      客户端.writeUTFBytes(正确码);
      客户端.writeUTFBytes("Cache-Control: no-cache\r\n");
      客户端.writeUTFBytes("Content-Type: ");
      var 扩展名:String = /\.(\w+)$/.test(映射) ? (/\.(\w+)$/.exec(映射)[1]) : "";
      switch(扩展名) {
        case "js":
          客户端.writeUTFBytes("application/javascript; charset=utf-8");
          break;
        case "css":
          客户端.writeUTFBytes("text/css; charset=utf-8");
          break;
        case "html":
          客户端.writeUTFBytes("text/html; charset=utf-8");
          break;
        case "tpl":
        case "txt":
        case "vm":
          客户端.writeUTFBytes("text/plain; charset=utf-8");
          break;
        case "jpg":
        case "jpeg":
          客户端.writeUTFBytes("image/jpeg");
          break;
        case "gif":
          客户端.writeUTFBytes("image/gif");
          break;
        case "png":
          客户端.writeUTFBytes("image/png");
          break;
        default:
          客户端.writeUTFBytes("application/octet-stream");
      }
      客户端.writeUTFBytes("\r\n\r\n\r\n");
      客户端.writeBytes(数据);
      客户端.flush();
      客户端.close();
      客户端 = null;
    }
    private function 本地文件不存在(映射:String, 消息:String = null):void {
      客户端.writeUTFBytes(错误码);
      客户端.writeUTFBytes("Content-Type: text/html; charset=utf-8\r\n");
      客户端.writeUTFBytes("Cache-Control: no-cache\r\n");
      客户端.writeUTFBytes("\r\n\r\n");
      客户端.writeUTFBytes("<!DOCTYPE html><html><head><title>404</title></head><body><p>404:<br/>");
      客户端.writeUTFBytes(映射);
      客户端.writeUTFBytes("</p>");
      if(消息) {
        客户端.writeUTFBytes(消息);
      }
      客户端.writeUTFBytes("</body></html>");
      客户端.flush();
      客户端.close();
      客户端 = null;
    }
  }
}