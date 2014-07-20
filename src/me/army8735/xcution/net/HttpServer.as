package me.army8735.xcution.net
{
  import flash.desktop.NativeApplication;
  import flash.desktop.NativeProcess;
  import flash.desktop.NativeProcessStartupInfo;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.NativeProcessExitEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.ServerSocketConnectEvent;
  import flash.filesystem.File;
  import flash.net.ServerSocket;
  import flash.net.Socket;
  import flash.system.Capabilities;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.utils.ByteArray;
  import flash.utils.Dictionary;
  
  import me.army8735.xcution.MsgField;
  import me.army8735.xcution.btns.Btns;
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  import me.army8735.xcution.proxy.ProxyPanel;
  import me.army8735.xcution.system.CheckSSL;
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
    private var 安全字典:Dictionary;
    private static const JAR文件:File = new File(File.applicationDirectory.resolvePath("ssl.jar").nativePath);
    private static const 编码:String = File.systemCharset;
    
    public function HttpServer(规则面板:ProxyPanel, 控制台:MsgField, 地址:String, 配置:Config)
    {
      this.规则面板 = 规则面板;
      this.控制台 = 控制台;
      this.配置 = 配置;
      安全字典 = new Dictionary();
      
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
      if(配置.启用SSL) {
        监听SSL端口(地址);
      }
      else {
        切换地址(地址);
      }
    }
    public function 监听SSL端口(地址:String):void {
      function 回调(event:CustomEvent):void {
        var 占用:Boolean = event.值 as Boolean;
        if(!占用) {
          切换地址(地址);
          调用JAVA(地址);
        }
        else {
          EventBus.dispatchEvent(new CustomEvent(CustomEvent.启动错误, "SSL端口号不可用：" + 配置.SSL端口号));
        }
        EventBus.removeEventListener(CustomEvent.监听结果, 回调);
      }
      EventBus.addEventListener(CustomEvent.监听结果, 回调);
      CheckSSL.监听(地址, 配置.SSL端口号);
    }
    private function 调用JAVA(地址:String):void {
      if(JAR文件.exists == false) {
        控制台.追加错误("找不到JAR文件：" + JAR文件.nativePath);
        return;
      }
      if(/windows/i.test(Capabilities.os))
      {
        var 进程信息:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var 本地进程:NativeProcess = new NativeProcess();
        NativeApplication.nativeApplication.autoExit = true;
        
        var 盘符:String = File.desktopDirectory.nativePath.substr(0, 3);
        trace("OS installed Drive:", 盘符);
        var cmd:File = new File(盘符).resolvePath("Windows/System32/cmd.exe");
        trace("cmd", cmd.url);
        进程信息.executable = cmd;
        
        var 参数:Vector.<String> = new Vector.<String>();
        参数.push("java");
        参数.push("-jar");
        参数.push(JAR文件.nativePath);
        参数.push(地址);
        参数.push(配置.SSL端口号);
        参数.push(配置.HTTP端口号);
        进程信息.arguments = 参数;
        
        本地进程.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardOutput.readMultiByte(本地进程.standardOutput.bytesAvailable, 编码);
          控制台.追加(s);
        });
        本地进程.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardError.readMultiByte(本地进程.standardError.bytesAvailable, 编码);
          控制台.追加错误(s);
        });
        本地进程.addEventListener(NativeProcessExitEvent.EXIT, function(event:NativeProcessExitEvent):void {
          NativeApplication.nativeApplication.removeEventListener(Event.EXITING, 退出);
        });
        
        function 退出(event:Event):void {
          本地进程.exit(true);
        }
        本地进程.start(进程信息);
        
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, 退出);
      }
      else {
        控制台.追加警告("Mac系统暂不支持JAR调用");
      }
    }
    public function 切换地址(地址:String):void {
      if(!服务器 || 服务器.bound) {
        return;
      }
      try {
        服务器.bind(配置.HTTP端口号, 地址);
      } catch(error:Error) {
        trace(error.getStackTrace());;
        关闭();
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.启动错误, error.message));
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
          EventBus.dispatchEvent(new CustomEvent(CustomEvent.关闭));
        }
        服务器.removeEventListener(ServerSocketConnectEvent.CONNECT, 新链接侦听);
      }
      服务器 = null;
      消息框.text = "---";
      重置();
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
      var 键:String = 套接字.remoteAddress + ":" + 套接字.remotePort;
      if(套接字 != null && 套接字.connected)
      {
        if(安全字典[键] !== undefined) {
          var SSL握手:SSLConnect = 安全字典[键] as SSLConnect;
          SSL握手.解析(缓冲);
        }
        else {
          var 内容:String = 缓冲.toString();
          var 索引:int = 内容.indexOf("\r\n");
          var 行:RequestLine = new RequestLine(内容.substring(0, 索引));
          var 头体:Array = 内容.substr(索引 + 2).split("\r\n\r\n");
          var 头:HttpHead = new HttpHead(头体[0]);
          var 体:HttpBody = new HttpBody(头体[1]);
          if(行.方法 == "CONNECT") {
            var 请求:HttpsRequest = 远程安全连接(套接字, 内容, 行, 头, 体);
            安全字典[键] = new SSLConnect(请求, 套接字);
          }
          else {
            远程连接(套接字, 内容, 行, 头, 体);
          }
        }
      }
      else 
      {
        trace("No socket connection.");
      }
    }
    private function 远程连接(套接字:Socket, 内容:String, 行:RequestLine, 头:HttpHead, 体:HttpBody):HttpRequest {
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
      return 请求;
    }
    private function 远程安全连接(套接字:Socket, 内容:String, 行:RequestLine, 头:HttpHead, 体:HttpBody):HttpsRequest {
      var 请求:HttpsRequest = new HttpsRequest(套接字, 行, 头, 体, 控制台, 规则面板);
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
      return 请求;
    }
  }
}