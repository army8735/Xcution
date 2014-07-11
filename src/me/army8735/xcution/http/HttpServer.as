package me.army8735.xcution.http
{
  import flash.desktop.NativeApplication;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.ServerSocketConnectEvent;
  import flash.net.ServerSocket;
  import flash.net.Socket;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.utils.ByteArray;
  
  import me.army8735.xcution.MsgField;
  import me.army8735.xcution.btns.Btns;
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  import me.army8735.xcution.proxy.ProxyPanel;
  import me.army8735.xcution.system.Config;

  public class HttpServer extends Sprite
  {
    private var 服务器:ServerSocket;
    private var 地址:String;
    private var 端口号:int;
    private var 消息框:TextField;
    private var 规则面板:ProxyPanel;
    private var 控制台:MsgField;
    private var 按钮们引用:Btns;
    private var 配置:Config;
    
    public function HttpServer(规则面板:ProxyPanel, 控制台:MsgField, 地址:String, 配置:Config)
    {
      this.规则面板 = 规则面板;
      this.控制台 = 控制台;
      this.配置 = 配置;
      
      消息框 = new TextField();
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      消息框.defaultTextFormat = 样式;
      消息框.text = '---';
      addChild(消息框);
      
      NativeApplication.nativeApplication.addEventListener(Event.EXITING, function(event:Event):void {
        trace(event);
        if(服务器) {
          if(服务器.bound) {
            服务器.close();
          }
          服务器.removeEventListener(ServerSocketConnectEvent.CONNECT, 新链接侦听);
        }
        服务器 = null;
      });
    }
    public function get 服务地址():String {
      return 地址 + ":" + 端口号;
    }
    public function 重置():void {
      消息框.width = 消息框.textWidth + 4;
      消息框.height = 消息框.textHeight + 4;
      x = stage.stageWidth - 消息框.width - 5;
      y = stage.stageHeight - 消息框.height - 15;
    }
    public function 开启(地址:String):void {
      关闭();
      服务器 = new ServerSocket();
      切换地址(地址);
    }
    public function 切换地址(地址:String):void {
      if(!服务器 || 服务器.bound) {
        return;
      }
      try {
        服务器.bind(配置.端口号, 地址);
      } catch(error:Error) {
        trace(error.getStackTrace());
        控制台.追加错误(error.message);
        关闭();
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.启动错误));
        return;
      }
      this.地址 = 服务器.localAddress;
      端口号 = 服务器.localPort;
      
      消息框.text = 地址 + ":" + 端口号;
      重置();
      
      服务器.addEventListener(ServerSocketConnectEvent.CONNECT, 新链接侦听);
      try {
        服务器.listen();
      } catch(error:Error) {
        trace(error.getStackTrace());
        控制台.追加错误(error.message);
        关闭();
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.启动错误));
        return;
      }
      
      控制台.追加警告("已开启端口：" + 地址 + ":" + 端口号);
      EventBus.dispatchEvent(new CustomEvent(CustomEvent.开启));
    }
    public function 关闭():void {
      if(服务器) {
        if(服务器.bound) {
          服务器.close();
          控制台.追加高亮("已关闭端口：" + 服务地址);
        }
        服务器.removeEventListener(ServerSocketConnectEvent.CONNECT, 新链接侦听);
      }
      服务器 = null;
      消息框.text = "---";
      重置();
      EventBus.dispatchEvent(new CustomEvent(CustomEvent.关闭));
    }
    public function set 按钮们(按钮们引用:Btns):void {
      this.按钮们引用 = 按钮们引用;
    }
    private function 新链接侦听(event:ServerSocketConnectEvent):void {
      var 套接字:Socket = event.socket;
      trace("监听本地连接：", 套接字.remoteAddress + ":" + 套接字.remotePort);
      套接字.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
        trace(event.text);
        if(套接字.connected) {
          套接字.close();
        }
      });
      套接字.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
        trace(event.text);
        if(套接字.connected) {
          套接字.close();
        }
      });
      套接字.addEventListener(Event.CLOSE, function(event:Event):void {
        if(套接字.connected) {
          套接字.close();
        }
      });
      套接字.addEventListener(ProgressEvent.SOCKET_DATA, 数据侦听);
    }
    private function 数据侦听(event:ProgressEvent):void {
      var 套接字:Socket = event.target as Socket;
      var 缓冲:ByteArray = new ByteArray();
      套接字.readBytes(缓冲, 0, 套接字.bytesAvailable);
      var 内容:String = 缓冲.toString();
      if(套接字 != null && 套接字.connected)
      {
        var 索引:int = 内容.indexOf("\r\n");
        var 行:RequestLine = new RequestLine(内容.substring(0, 索引));
        var 头体:Array = 内容.substr(索引 + 2).split("\r\n\r\n");
        var 头:HttpHead = new HttpHead(头体[0]);
        var 体:HttpBody = new HttpBody(头体[1]);
        远程连接(套接字, 内容, 行, 头, 体);
      }
      else 
      {
        trace("No socket connection.");
      }
    }
    private function 远程连接(套接字:Socket, 内容:String, 行:RequestLine, 头:HttpHead, 体:HttpBody):void {
      var 请求:HttpRequest = new HttpRequest(套接字, 行, 头, 体, 控制台, 规则面板);
      套接字.addEventListener(Event.CLOSE, function(event:Event):void {
        trace("本地连接主动关闭：", 行.地址);
        if(请求) {
          请求.关闭();
        }
        if(套接字 && 套接字.connected) {
          套接字.close()
        }
        套接字 = null;
        请求 = null;
      });
      套接字.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
        trace("本地连接异常：", 套接字.remoteAddress + ":" + 套接字.remotePort);
        if(请求) {
          请求.关闭();
        }
        if(套接字 && 套接字.connected) {
          套接字.close()
        }
        套接字 = null;
        请求 = null;
      });
      套接字.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
        trace("本地连接安全异常：", 套接字.remoteAddress + ":" + 套接字.remotePort);
        if(请求) {
          请求.关闭();
        }
        if(套接字 && 套接字.connected) {
          套接字.close();
        }
        套接字 = null;
        请求 = null;
      });
      请求.链接();
    }
  }
}