package me.army8735.xcution.system
{
  import flash.events.StatusEvent;
  
  import air.net.SecureSocketMonitor;
  import air.net.SocketMonitor;
  
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  
  public class CheckSSL 
  {
    private static var 监听器:SocketMonitor;
    private static var 安全监听器:SecureSocketMonitor;
    private static var 结果:Boolean;
    private static var 上次地址:String;
    private static var 上次端口:int;
    
    public function CheckSSL()
    {
    }
    
    public static function 监听(地址:String, 端口:int):void {
      if(端口 == 0) {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.监听结果, true));
        return;
      }
      结果 = false;
      上次地址 = 地址;
      上次端口 = 端口;
      if(监听器) {
        监听器.stop();
        监听器.removeEventListener(StatusEvent.STATUS, 监听回调);
        监听器 = null;
      }
      监听器 = new SocketMonitor(上次地址, 上次端口);
      监听器.addEventListener(StatusEvent.STATUS, 监听回调);
      监听器.start();
    }
    private static function 监听回调(event:StatusEvent):void {
      if(监听器.available) {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.监听结果, 监听器.available));
      }
      else {
        监听安全();
      }
    }
    private static function 监听安全():void {
      if(安全监听器) {
        安全监听器.stop();
        安全监听器.removeEventListener(StatusEvent.STATUS, 安全监听回调);
        安全监听器 = null;
      }
      安全监听器 = new SecureSocketMonitor(上次地址, 上次端口);
      安全监听器.addEventListener(StatusEvent.STATUS, 安全监听回调);
      安全监听器.start();
    }
    private static function 安全监听回调(event:StatusEvent):void {trace(安全监听器.available)
      EventBus.dispatchEvent(new CustomEvent(CustomEvent.监听结果, 安全监听器.available));
    }
  }
}