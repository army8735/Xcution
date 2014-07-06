package me.army8735.xcution
{
  import flash.events.Event;
  import flash.events.EventDispatcher;

  public class EventBus
  {
    private static const event:EventDispatcher = new EventDispatcher();
    
    public static const 刷新:String = "刷新";
    
    public static function addEventListener(类型:String, 侦听:Function):void {
      event.addEventListener(类型, 侦听);
    }
    public static function removeEventListener(类型:String, 侦听:Function):void {
      event.removeEventListener(类型, 侦听);
    }
    public static function dispatchEvent(事件:Event):void {
      event.dispatchEvent(事件);
    }
    
    public function EventBus()
    {
    }
  }
}