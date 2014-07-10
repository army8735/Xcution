package me.army8735.xcution.events
{
  import flash.events.EventDispatcher;

  public class EventBus
  {
    private static const event:EventDispatcher = new EventDispatcher();
    
    public static function addEventListener(类型:String, 侦听:Function):void {
      event.addEventListener(类型, 侦听);
    }
    public static function removeEventListener(类型:String, 侦听:Function):void {
      event.removeEventListener(类型, 侦听);
    }
    public static function dispatchEvent(自定义事件:CustomEvent):void {
      event.dispatchEvent(自定义事件);
    }
    
    public function EventBus()
    {
    }
  }
}