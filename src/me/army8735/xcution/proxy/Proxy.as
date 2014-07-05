package me.army8735.xcution.proxy
{
  import flash.desktop.NativeApplication;
  import flash.desktop.NativeProcess;
  import flash.desktop.NativeProcessStartupInfo;
  import flash.events.Event;
  import flash.events.ProgressEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.system.Capabilities;
  
  import me.army8735.xcution.MsgField;
  
  public class Proxy
  {
    private static const 设置头:String = '@echo off\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyServer /d "';
    private static const 设置尾:String = '" /f';
    private static const 取消体:String = '@echo off\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyServer /d "" /f';
    private static const 编码:String = File.systemCharset;
    private static var 执行文件:File = new File(File.userDirectory.url + File.separator + "temp.bat");
    
    public static function 设置(服务地址:String, 控制台:MsgField):void {
      if(/windows/i.test(Capabilities.os))
      {
        if(执行文件.exists) {
          执行文件.deleteFile();
        }
        trace(Capabilities.os);
        执行文件 = 执行文件.resolvePath("");
        trace(执行文件.url);
        var 文件流:FileStream = new FileStream();
        文件流.open(执行文件, FileMode.WRITE);
        文件流.writeMultiByte(设置头, 编码);
        文件流.writeMultiByte(服务地址, 编码);
        文件流.writeMultiByte(设置尾, 编码);
        trace(设置头.replace(/\r\n/g, "\n") + 服务地址 + 设置尾);
        文件流.close();
        
        var 进程信息:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var 本地进程:NativeProcess = new NativeProcess();
        var 盘符:String = File.desktopDirectory.nativePath.substr(0, 3);
        trace("OS installed Drive:", 盘符);
        var cmd:File = new File(盘符).resolvePath("Windows/system32/cmd.exe");
        trace("cmd", cmd.url);
        进程信息.executable = cmd;
        var 参数:Vector.<String> = new Vector.<String>();
        参数.push("/c");
        参数.push(执行文件.url.replace(/^file:\/+/, ""));
        进程信息.arguments = 参数;
        本地进程.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardOutput.readMultiByte(本地进程.standardOutput.bytesAvailable, 编码);
         s = s.replace(/\r\n/g, "\n");
          trace(s);
          控制台.追加(s);
          控制台.追加高亮("开启代理模式");
          本地进程.exit(true);
        });
        本地进程.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardError.readMultiByte(本地进程.standardError.bytesAvailable, 编码);
          s = s.replace(/\r\n/g, "\n");
          trace(s);
          控制台.追加错误(s);
          本地进程.exit(true);
        });
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, function():void {
          本地进程.exit(true);
  			});
        本地进程.start(进程信息);
  			NativeApplication.nativeApplication.addEventListener(Event.EXITING, function():void {
          本地进程.exit(true);
  			});
      }
    }
    public static function 取消(控制台:MsgField):void {
      if(/windows/i.test(Capabilities.os))
      {
        if(执行文件.exists) {
          执行文件.deleteFile();
        }
        trace(Capabilities.os);
        执行文件 = 执行文件.resolvePath("");
        trace(执行文件.url);
        var 文件流:FileStream = new FileStream();
        文件流.open(执行文件, FileMode.WRITE);
        文件流.writeMultiByte(取消体, 编码);
        trace(取消体.replace(/\r\n/g, "\n"));
        文件流.close();
        
        var 进程信息:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var 本地进程:NativeProcess = new NativeProcess();
        var 盘符:String = File.desktopDirectory.nativePath.substr(0, 3);
        trace("OS installed Drive:", 盘符);
        var cmd:File = new File(盘符).resolvePath("Windows/system32/cmd.exe");
        trace("cmd", cmd.url);
        进程信息.executable = cmd;
        var 参数:Vector.<String> = new Vector.<String>();
        参数.push("/c");
        参数.push(执行文件.url.replace(/^file:\/+/, ""));
        进程信息.arguments = 参数;
        本地进程.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardOutput.readMultiByte(本地进程.standardOutput.bytesAvailable, 编码);
          s = s.replace(/\r\n/g, "\n");
          trace(s);
          控制台.追加(s);
          控制台.追加高亮("关闭代理模式");
          本地进程.exit(true);
        });
        本地进程.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardError.readMultiByte(本地进程.standardError.bytesAvailable, 编码);
          s = s.replace(/\r\n/g, "\n");
          trace(s);
          控制台.追加错误(s);
          本地进程.exit(true);
        });
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, function():void {
          本地进程.exit(true);
        });
        本地进程.start(进程信息);
      }
    }
    public function Proxy()
    {
    }
  }
}