package me.army8735.xcution.http
{
  import flash.events.ProgressEvent;
  import flash.events.ServerSocketConnectEvent;
  import flash.net.ServerSocket;
  import flash.net.Socket;
  import flash.utils.ByteArray;
  
  import me.army8735.xcution.proxy.Proxy;

  public class HttpServer
  {
    private var 服务器:ServerSocket = new ServerSocket();
    private var 地址:String;
    private var 端口号:Number;
    private var 套接字:Socket;
    private var 代理:Proxy;
    
    public function HttpServer()
    {
      if(服务器.bound) {
        服务器.close();
        服务器 = new 服务器();
      }
      服务器.bind();
      
      地址 = 服务器.localAddress;
      端口号 = 服务器.localPort;
      Proxy.设置(地址, 端口号);
      trace("服务器:" + 地址, "端口号：", 端口号);
      
      服务器.addEventListener(ServerSocketConnectEvent.CONNECT, 新链接侦听);
      服务器.listen();
    }
    private function 新链接侦听(event:ServerSocketConnectEvent):void {
      套接字 = event.socket;
      套接字.addEventListener(ProgressEvent.SOCKET_DATA, 数据侦听);
      trace("新链接来自：", 套接字.remoteAddress + ":" + 套接字.remotePort);
    }
    private function 数据侦听(event:ProgressEvent):void {
      var 缓冲:ByteArray = new ByteArray();
      套接字.readBytes(缓冲, 0, 套接字.bytesAvailable);
      var 内容:String = 缓冲.toString();
      trace("接收数据：\n", 内容.replace(/\r\n/g, "\n"));
      try
      {
        if(套接字 != null && 套接字.connected)
        {
          if(内容 == "") {
            套接字.writeUTFBytes("HTTP/1.1 100 Continue\r\n");
            套接字.flush();
          }
          else {
            var 头:HttpHeader = new HttpHeader(内容);
          }
          trace("Sent message to", 套接字.remoteAddress, ":", 套接字.remotePort);
        }
        else 
        {
          trace("No socket connection.");
        }
      }
      catch (error:Error)
      {
        trace(error.message);
      }
    }
  }
}