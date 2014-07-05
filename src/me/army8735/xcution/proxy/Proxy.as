package me.army8735.xcution.proxy
{
  public class Proxy
  {
    public static const 设置头:String = '@echo off\r\nreg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f\r\nreg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "';
    public static const 设置尾:String = '" /f';
    public static const 取消体:String = '@echo off\r\nreg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f\r\nreg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "" /f';
    
    public static function 设置(地址:String, 端口号:Number):void {
      
    }
    public function Proxy()
    {
    }
  }
}