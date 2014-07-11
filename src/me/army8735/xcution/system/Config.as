package me.army8735.xcution.system
{
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  import flash.net.SharedObject;
  
  import fl.controls.Button;
  
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  
  public class Config extends Sprite
  {
    public var 存储名:String = "Xcution-config";
    public static const 宽度:int = 400;
    public static const 高度:int = 300;
    
    private var 文本框:TextField;
    private var 输入:TextField;
    private var 确定:Button;
    
    public function Config()
    {
      文本框 = new TextField();
      输入 = new TextField();
      
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      文本框.defaultTextFormat = 输入.defaultTextFormat = 样式;
      文本框.text = "默认端口号（不填或0为随机）";
      文本框.x = 10;
      文本框.y = 20;
      文本框.width = 文本框.textWidth;
      文本框.height = 20;
      
      输入.type = TextFieldType.INPUT;
      输入.restrict = "0-9";
      输入.x = 10;
      输入.y = 50;
      输入.width = 200;
      输入.height = 20;
      输入.border = true;
      输入.borderColor = 0x999999;
      
      var 存储:SharedObject = SharedObject.getLocal(存储名);
      if(存储.data.端口号) {
        输入.text = 存储.data.端口号;
      }
      
      确定 = new Button();
      确定.setStyle("textFormat", 样式);
      确定.label = "确定";
      确定.x = 10;
      确定.y = 80;
      确定.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        存储.data.端口号 = 输入.text;
        存储.flush();
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.关闭设置));
      });
      
      addChild(文本框);
      addChild(输入);
      addChild(确定);
      
      graphics.beginFill(0xFFFFFF);
      graphics.drawRoundRect(0, 0, 宽度, 高度, 5);
      graphics.endFill();
      
      var 配置:Config = this;
      EventBus.addEventListener(CustomEvent.设置, function(event:CustomEvent):void {
        配置.visible = true;
      });
      EventBus.addEventListener(CustomEvent.关闭设置, function(event:CustomEvent):void {
        配置.visible = false;
      });
    }
    public function 重置():void {
      x = (stage.stageWidth - 宽度) >> 1;
      y = (stage.stageHeight - 高度) >> 1;
    }
    public function get 端口号():int {
      if(输入.text.length > 0) {
        return parseInt(输入.text);
      }
      return 0;
    }
  }
}