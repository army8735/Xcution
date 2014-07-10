package me.army8735.xcution.proxy
{
  import flash.display.Sprite;
  
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  
  public class ProxyPanel extends Sprite
  {
    public function ProxyPanel()
    {
      super();
      EventBus.addEventListener(CustomEvent.添加规则, function(event:CustomEvent):void {
        var 规则:ProxyRule = new ProxyRule();
        规则.y = numChildren * ProxyRule.高度 + ProxyRule.边距;
        addChild(规则);
      });
    }
    public function 重置():void {
      x = ProxyRule.边距;
      width = stage.stageWidth - ProxyRule.边距 * 2;
      for(var i:int = 0; i < numChildren; i++) {
        (getChildAt(0) as ProxyRule).重置();
      }
    }
    public function 排序():void {
      for(var i:int = 0; i < numChildren; i++) {
        (getChildAt(0) as ProxyRule).y = i * ProxyRule.高度 + ProxyRule.边距;
      }
    }
  }
}