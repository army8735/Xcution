package me.army8735.xcution.system
{
  import flash.display.Sprite;
  
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  
  public class Mask extends Sprite
  {
    public function Mask()
    {
      alpha = 0.5;
      var 遮罩:Mask = this;
      EventBus.addEventListener(CustomEvent.设置, function(event:CustomEvent):void {
        遮罩.visible = true;
      });
      EventBus.addEventListener(CustomEvent.关闭设置, function(event:CustomEvent):void {
        遮罩.visible = false;
      });
    }
    public function 重置():void {
      graphics.clear();
      graphics.beginFill(0x000000);
      graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
      graphics.endFill();
    }
  }
}