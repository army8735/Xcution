package me.army8735.xcution.http
{
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.net.SecureSocket;
  import flash.net.Socket;
  import flash.security.X509Certificate;
  import flash.utils.ByteArray;
  
  import me.army8735.xcution.MsgField;
  import me.army8735.xcution.proxy.ProxyPanel;
  
  public class HttpsRequest
  {
    private var 客户端:Socket;
    private var 控制台:MsgField;
    private var 规则面板:ProxyPanel;
    
    private var 套接字:SecureSocket;
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
    
    public function HttpsRequest(客户端:Socket, 行:RequestLine, 头:HttpHead, 体:HttpBody, 控制台:MsgField, 规则面板:ProxyPanel)
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
        return;
      }
      
      累计 = 0;
      总长度 = -1;
      块传输 = false;
      状态 = 开始;
      缓存 = new ByteArray();
      
      套接字 = new SecureSocket();
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
        trace("成功安全远程链接：", 行.地址);
        var 证书:X509Certificate = 套接字.serverCertificate;
        var 名称:String = 证书.subject.commonName;
        if(客户端 && 客户端.connected) {
          客户端.writeUTFBytes("HTTP/1.0 200 OK\r\n");
          客户端.writeUTFBytes("Host: " + 行.主机 + ":" + 行.端口 + "\r\n");
          客户端.writeUTFBytes("\r\n");
          客户端.flush();
        }
//        if(套接字 && 套接字.connected) {
//          套接字.writeUTFBytes(行.兼容内容);
//          套接字.writeUTFBytes(头.内容);
//          套接字.writeUTFBytes(体.内容);
//          套接字.flush();
//        }
      });
      套接字.addEventListener(ProgressEvent.SOCKET_DATA, function(event:ProgressEvent):void {
        trace("安全远程链接数据：", 套接字.bytesAvailable, 行.地址);
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
        trace("安全远程链接关闭：", 行.地址);
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
      trace("发出安全远程链接：", 行.地址, 行.主机, 行.端口);
      套接字.connect(行.主机, 行.端口);
    }
    private function 分析数据(数据:ByteArray):void {
      
    }
  }
}