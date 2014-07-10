package me.army8735.xcution.proxy
{
  import flash.display.Sprite;
  import flash.events.Event;
  
  public class ProxyRule extends Sprite
  {
    public static const 高度:int = 50;
    public static const 边距:int = 10;
    
    public static const 单个文件:int = 0;
    public static const 文件路径:int = 1;
    public static const 正则匹配:int = 2;
    
    private var 代理类型:int;
    
    public function ProxyRule(代理类型:int = 0)
    {
      this.代理类型 = 代理类型;
      addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void {
        重置();
      });
    }
    public function get 类型():int {
      return 代理类型;
    }
    public function 重置():void {
      graphics.clear();
      graphics.beginFill(0xFF0000);
      graphics.drawRect(0, 0, 边距, 高度);
    }
  }
}