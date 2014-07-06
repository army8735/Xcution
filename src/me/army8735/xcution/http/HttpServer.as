package me.army8735.xcution.http
{
  import flash.desktop.NativeApplication;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.ProgressEvent;
  import flash.events.ServerSocketConnectEvent;
  import flash.net.ServerSocket;
  import flash.net.Socket;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.utils.ByteArray;
  
  import me.army8735.xcution.MsgField;

  public class HttpServer extends Sprite
  {
    private var 服务器:ServerSocket = new ServerSocket();
    private var 地址:String;
    private var 端口号:int;
    private var 套接字:Socket;
    private var 消息框:TextField;
    
    public function HttpServer(控制台:MsgField, 地址列表:Vector.<String>)
    {
      if(服务器.bound) {
        服务器.close();
        服务器 = new 服务器();
      }
      服务器.bind(0, 地址列表[0]);
      
      地址 = 服务器.localAddress;
      端口号 = 服务器.localPort;
      trace("服务器:", 地址, "端口号：", 端口号);
      控制台.追加警告("已开启随机端口：" + 地址 + ":" + 端口号);
      
      消息框 = new TextField();
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      消息框.defaultTextFormat = 样式;
      消息框.text = 地址 + ":" + 端口号;
      消息框.width = 消息框.textWidth + 4;
      消息框.height = 消息框.textHeight + 4;
      addChild(消息框);
      
      服务器.addEventListener(ServerSocketConnectEvent.CONNECT, 新链接侦听);
      服务器.listen();
      
      NativeApplication.nativeApplication.addEventListener(Event.EXITING, function():void {
        服务器.close();
      });
    }
    public function get 服务地址():String {
      return 地址 + ":" + 端口号;
    }
    public function 重置():void {
      x = stage.stageWidth - 消息框.width - 5;
      y = 5;
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