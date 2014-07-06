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
  
  import me.army8735.xcution.Btns;
  import me.army8735.xcution.MsgField;
  import me.army8735.xcution.proxy.Proxy;
  
  import org.httpclient.HttpClient;
  import org.httpclient.HttpRequest;
  import org.httpclient.events.HttpErrorEvent;
  import org.httpclient.events.HttpResponseEvent;
  import org.httpclient.http.Get;
  import org.httpclient.http.Post;
  
  import com.adobe.net.URI;

  public class HttpServer extends Sprite
  {
    private var 服务器:ServerSocket = new ServerSocket();
    private var 地址:String;
    private var 端口号:int;
    private var 套接字:Socket;
    private var 消息框:TextField;
    private var 控制台:MsgField;
    private var 按钮们引用:Btns;
    
    public function HttpServer(控制台:MsgField, 地址:String)
    {
      this.控制台 = 控制台;
      
      消息框 = new TextField();
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      消息框.defaultTextFormat = 样式;
      addChild(消息框);
      
      切换地址(地址, true);
    }
    public function get 服务地址():String {
      return 地址 + ":" + 端口号;
    }
    public function 重置():void {
      x = stage.stageWidth - 消息框.width - 5;
      y = 5;
    }
    public function 切换地址(地址:String, 首次:Boolean = false):void {
      if(服务器.bound) {
        服务器.close();
        控制台.追加高亮("已关闭随机端口：" + 服务地址);
        服务器 = new ServerSocket();
      }
      trace("地址:", 地址);
      服务器.bind(0, 地址);
      this.地址 = 服务器.localAddress;
      端口号 = 服务器.localPort;
      trace("服务器:", 服务地址);
      控制台.追加警告("已开启随机端口：" + 地址 + ":" + 端口号);
      
      消息框.text = 地址 + ":" + 端口号;
      消息框.width = 消息框.textWidth + 4;
      消息框.height = 消息框.textHeight + 4;
      if(!首次) {
        重置();
        var 状态:Boolean = 按钮们引用.运行按钮.状态();
        if(状态) {
          Proxy.设置(服务地址, 控制台);
        }
      }
      
      服务器.addEventListener(ServerSocketConnectEvent.CONNECT, 新链接侦听);
      服务器.listen();
      
      NativeApplication.nativeApplication.addEventListener(Event.EXITING, function():void {
        if(服务器.bound) {
          服务器.close();
        }
      });
    }
    public function set 按钮们(按钮们引用:Btns):void {
      this.按钮们引用 = 按钮们引用;
    }
    private function 新链接侦听(event:ServerSocketConnectEvent):void {
      套接字 = event.socket;
      trace("新链接来自：", 套接字.remoteAddress + ":" + 套接字.remotePort);
      套接字.addEventListener(ProgressEvent.SOCKET_DATA, 数据侦听);
    }
    private function 数据侦听(event:ProgressEvent):void {
      var 缓冲:ByteArray = new ByteArray();
      套接字.readBytes(缓冲, 0, 套接字.bytesAvailable);
      var 内容:String = 缓冲.toString();
      trace("接收数据：", 内容.replace(/\r\n/g, "\n"));
      try
      {
        if(套接字 != null && 套接字.connected)
        {
          if(内容 == "") {
            套接字.writeUTFBytes("HTTP/1.1 100 Continue\r\n");
            套接字.flush();
          }
          else {
            var 索引:int = 内容.indexOf("\r\n");
            var 行:HttpLine = new HttpLine(内容.substring(0, 索引));
            var 头体:Array = 内容.substr(索引 + 2).split("\r\n\r\n");
            var 头:HttpHead = new HttpHead(头体[0]);
            var 体:HttpBody = new HttpBody(头体[1]);
            
            var 请求端:HttpClient = new HttpClient();
            var 请求:HttpRequest = 行.方法 == "GET" ? new Get() : new Post();
            for(var 键:String in 头.键值对) {
              请求.addHeader(键, 头.获取(键));
            }
            请求.body = 头体[1];
            请求端.listener.onComplete = function(event:HttpResponseEvent):void {
              trace(event);
              trace(event.response);
            };
            请求端.listener.onError = function(event:HttpErrorEvent):void {
              trace(event);
              trace(event.text);
            };
            请求端.request(new URI(行.路径), 请求);
            控制台.追加高亮("远程连接：" + 行.路径 + ":" + 行.端口);
          }
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