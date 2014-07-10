package me.army8735.xcution.system
{
  import flash.desktop.NativeApplication;
  import flash.desktop.NativeProcess;
  import flash.desktop.NativeProcessStartupInfo;
  import flash.errors.IOError;
  import flash.events.Event;
  import flash.events.ProgressEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.system.Capabilities;
  
  import me.army8735.xcution.events.EventBus;
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.MsgField;
  
  public class Proxy
  {
    private static const 设置头:String = '@echo off\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyServer /d "';
    private static const 设置尾:String = '" /f\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyOverride /t REG_SZ /d "<local>" /f\r\n@echo switch on ';
    private static const 取消体:String = '@echo off\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyServer /d "" /f\r\nreg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" /v ProxyOverride /t REG_SZ /d 0 /f\r\n@echo switch off';
    private static const 编码:String = File.systemCharset;
    private static var 执行文件:File = File.userDirectory.resolvePath("xcution.temp.bat");
    private static var 设置退出侦听:Boolean = false;
    
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
        文件流.writeMultiByte(服务地址, 编码);
        trace(设置头.replace(/\r\n/g, "\n") + 服务地址 + 设置尾);
        文件流.close();
        
        var 进程信息:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var 本地进程:NativeProcess = new NativeProcess();
        NativeApplication.nativeApplication.autoExit = true;
        
        var 盘符:String = File.desktopDirectory.nativePath.substr(0, 3);
        trace("OS installed Drive:", 盘符);
        var cmd:File = new File(盘符).resolvePath("Windows/System32/cmd.exe");
        trace("cmd", cmd.url);
        进程信息.executable = cmd;
        var 参数:Vector.<String> = new Vector.<String>();
        参数.push("/c");
        参数.push(执行文件.url.replace(/^file:\/+/, ""));
        进程信息.arguments = 参数;
        
        本地进程.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardOutput.readMultiByte(本地进程.standardOutput.bytesAvailable, 编码);
          控制台.追加(s);
          if(s.indexOf("switch on") >= 0) {
            控制台.追加高亮("开启代理模式");
            if(执行文件.exists) {
              try {
                执行文件.deleteFile();
              } catch(error:IOError) {}
            }
            刷新(控制台);
          }
        });
        本地进程.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardError.readMultiByte(本地进程.standardError.bytesAvailable, 编码);
          控制台.追加错误(s);
          if(执行文件.exists) {
            try {
              执行文件.deleteFile();
            } catch(error:IOError) {}
          }
        });
        if(!设置退出侦听) {
          设置退出侦听 = true;
          NativeApplication.nativeApplication.addEventListener(Event.EXITING, function():void {
            取消(控制台);
            刷新(控制台);
    			});
        }
        本地进程.start(进程信息);
      }
      else {
        控制台.追加警告("Mac系统暂不支持自动切换");
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.刷新));
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
        var cmd:File = new File(盘符).resolvePath("Windows/System32/cmd.exe");
        trace("cmd", cmd.url);
        进程信息.executable = cmd;
        var 参数:Vector.<String> = new Vector.<String>();
        参数.push("/c");
        参数.push(执行文件.url.replace(/^file:\/+/, ""));
        进程信息.arguments = 参数;
        
        本地进程.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardOutput.readMultiByte(本地进程.standardOutput.bytesAvailable, 编码);
          控制台.追加(s);
          if(s.indexOf("switch off") >= 0) {
            控制台.追加高亮("关闭代理模式");
            if(执行文件.exists) {
              try {
                执行文件.deleteFile();
              } catch(error:IOError) {}
            }
            刷新(控制台);
          }
        });
        本地进程.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardError.readMultiByte(本地进程.standardError.bytesAvailable, 编码);
          控制台.追加错误(s);
          if(执行文件.exists) {
            try {
              执行文件.deleteFile();
            } catch(error:IOError) {}
          }
        });
        本地进程.start(进程信息);
      }
      else {
        控制台.追加警告("Mac系统暂不支持自动切换");
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.刷新));
      }
    }
    public static function 刷新(控制台:MsgField):void {
      if(/windows/i.test(Capabilities.os))
      {
        var 进程信息:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var 本地进程:NativeProcess = new NativeProcess();
        
        var 盘符:String = File.desktopDirectory.nativePath.substr(0, 3);
        trace("OS installed Drive:", 盘符);
        var ipconfig:File = new File(盘符).resolvePath("Windows/System32/ipconfig.exe");
        trace("cmd", ipconfig.url);
        进程信息.executable = ipconfig;
        var 参数:Vector.<String> = new Vector.<String>();
        参数.push("/flushdns");
        进程信息.arguments = 参数;
        
        本地进程.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardOutput.readMultiByte(本地进程.standardOutput.bytesAvailable, 编码);
          控制台.追加(s);
          EventBus.dispatchEvent(new CustomEvent(CustomEvent.刷新));
        });
        本地进程.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function(event:ProgressEvent):void {
          var s:String = 本地进程.standardError.readMultiByte(本地进程.standardError.bytesAvailable, 编码);
          控制台.追加错误(s);
          EventBus.dispatchEvent(new CustomEvent(CustomEvent.刷新));
        });
        本地进程.start(进程信息);
      }
    }
    
    public function Proxy()
    {
    }
  }
}