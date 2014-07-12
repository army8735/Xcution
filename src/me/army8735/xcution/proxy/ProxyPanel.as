package me.army8735.xcution.proxy
{
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.net.SharedObject;
  
  import fl.controls.ScrollBar;
  import fl.events.ScrollEvent;
  
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  
  public class ProxyPanel extends Sprite
  {
    public var 存储名:String = "Xcution-list";
    
    private var 内容:Sprite;
    private var 遮罩:Sprite;
    private var 滚动条:ScrollBar;
    
    public function ProxyPanel()
    {
      super();
      x = ProxyRule.边距;
      y = ProxyRule.边距;
      
      内容 = new Sprite();
      addChild(内容);
      
      遮罩 = new Sprite();
      内容.mask = 遮罩;
      addChild(遮罩);
      
      滚动条 = new ScrollBar();
      滚动条.addEventListener(ScrollEvent.SCROLL, function(event:ScrollEvent):void {
        内容.y = -内容.height * event.position / 遮罩.height;
      });
      addChild(滚动条);
      
      addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void {
        滚动条.scrollPosition -= event.delta * 10;
      });
      
      var 面板:ProxyPanel = this;
      EventBus.addEventListener(CustomEvent.添加规则, function(event:CustomEvent):void {
        var 规则:ProxyRule = new ProxyRule(面板, event.值 as int);
        添加(规则);
      });
      EventBus.addEventListener(CustomEvent.添加地址规则, function(event:CustomEvent):void {
        var 规则:ProxyRule = new ProxyRule(面板, ProxyRule.单个文件, event.值 as String);
        添加(规则);
      });
      
      var 存储:SharedObject = SharedObject.getLocal(存储名);
      EventBus.addEventListener(CustomEvent.规则变化, function(event:CustomEvent):void {
        var 数组:Vector.<String> = new Vector.<String>();
        for(var i:int = 0; i < 内容.numChildren; i++) {
          var 规则:ProxyRule = 内容.getChildAt(i) as ProxyRule;
          数组.push(规则.序列化());
        }
        if(数组.length) {
          存储.data.规则 = JSON.stringify(数组);
          存储.flush();
        }
      });
      if(存储.data.规则) {
        var 数组:Array = JSON.parse(存储.data.规则) as Array;
        if(数组) {
          for(var i:int = 0; i < 数组.length; i++) {
            var 数据:Array = ProxyRule.反序列化(数组[i]);
            var 规则:ProxyRule = new ProxyRule(面板, 数据[0], 数据[1], 数据[2], 数据[3]);
            添加(规则);
          }
        }
      }
      
      EventBus.addEventListener(CustomEvent.清空规则, function(event:CustomEvent):void {
        内容.removeChildren();
        存储.data.规则 = null;
        存储.flush();
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
      
      遮罩.graphics.clear();
      遮罩.graphics.beginFill(0xFFFFFF);
      遮罩.graphics.drawRect(0, ProxyRule.边距 - 1, stage.stageWidth - ProxyRule.边距 * 6, (stage.stageHeight >> 1) - ProxyRule.边距 * 4);
      遮罩.graphics.endFill();
      
      滚动条.x = stage.stageWidth - ProxyRule.边距 * 5;
      滚动条.height = (stage.stageHeight >> 1) - ProxyRule.边距 * 2;
      更新滚动条();
    }
    public function 排序():void {
      for(var i:int = 0; i < 内容.numChildren; i++) {
        (内容.getChildAt(i) as ProxyRule).y = i * (ProxyRule.高度 + ProxyRule.边距) + ProxyRule.边距;
      }
    }
    public function 移除(规则:ProxyRule):void {
      内容.removeChild(规则);
      排序();
      更新滚动条();
    }
    public function 获取映射(路径:String):String {
      for(var i:int = 0; i < 内容.numChildren; i++) {
        var 规则:ProxyRule = 内容.getChildAt(i) as ProxyRule;
        if(规则.命中(路径)) {
          return 规则.映射(路径);
        }
      }
      return null;
    }
    private function 添加(规则:ProxyRule):void {
      规则.y = 内容.numChildren * (ProxyRule.高度 + ProxyRule.边距) + ProxyRule.边距;
      内容.addChild(规则);
      更新滚动条();
    }
    private function 更新滚动条():void {
      滚动条.setScrollProperties(遮罩.height, 0, 内容.height - 遮罩.height, ProxyRule.高度 + ProxyRule.边距);
    }
  }
}