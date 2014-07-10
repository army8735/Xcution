package me.army8735.xcution.proxy
{
  import flash.display.Sprite;
  
  import fl.controls.ScrollBar;
  
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  
  public class ProxyPanel extends Sprite
  {
    private var 内容:Sprite;
    private var 滚动条:ScrollBar;
    
    public function ProxyPanel()
    {
      super();
      x = ProxyRule.边距;
      y = ProxyRule.边距;
      
      内容 = new Sprite();
      addChild(内容);
      
      滚动条 = new ScrollBar();
      addChild(滚动条);
      
      EventBus.addEventListener(CustomEvent.添加规则, function(event:CustomEvent):void {
        var 规则:ProxyRule = new ProxyRule();
        规则.y = 内容.numChildren * (ProxyRule.高度 + ProxyRule.边距) + ProxyRule.边距;
        内容.addChild(规则);
      });
    }
    public function 重置():void {
      for(var i:int = 0; i < 内容.numChildren; i++) {
        (内容.getChildAt(i) as ProxyRule).重置();
      }
      graphics.clear();
      graphics.beginFill(0xFFFCF9);
      graphics.drawRoundRect(0, 0, stage.stageWidth - ProxyRule.边距 * 6, (stage.stageHeight >> 1) - ProxyRule.边距 * 2, 3);
      graphics.endFill();
      graphics.lineStyle(1, 0xCCCCCC);
      graphics.drawRoundRect(0, 0, stage.stageWidth - ProxyRule.边距 * 6, (stage.stageHeight >> 1) - ProxyRule.边距 * 2, 3);
      
      滚动条.x = stage.stageWidth - ProxyRule.边距 * 5;
      滚动条.height = (stage.stageHeight >> 1) - ProxyRule.边距 * 2;
    }
    public function 排序():void {
      for(var i:int = 0; i < 内容.numChildren; i++) {
        (内容.getChildAt(i) as ProxyRule).y = i * ProxyRule.高度 + ProxyRule.边距;
      }
    }
  }
}