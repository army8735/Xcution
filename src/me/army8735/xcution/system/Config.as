package me.army8735.xcution.system
{
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  import flash.net.SharedObject;
  
  import fl.controls.Button;
  
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  
  public class Config extends Sprite
  {
    public var 存储名:String = "Xcution-config";
    public static const 宽度:int = 400;
    public static const 高度:int = 300;
    
    private var HTTP文本框:TextField;
    private var HTTP输入:TextField;
    private var SSL文本框:TextField;
    private var SSL输入:TextField;
    private var 确定:Button;
    
    public function Config()
    {
      HTTP文本框 = new TextField();
      HTTP输入 = new TextField();
      SSL文本框 = new TextField();
      SSL输入 = new TextField();
      
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      样式.size = 12;
      样式.align = TextFormatAlign.RIGHT;
      HTTP文本框.defaultTextFormat = HTTP输入.defaultTextFormat = 样式;
      HTTP文本框.text = "HTTP端口号（不填或0为随机）";
      HTTP文本框.x = 20;
      HTTP文本框.y = 20;
      HTTP文本框.width = HTTP文本框.textWidth;
      HTTP文本框.height = 20;
      
      HTTP输入.type = TextFieldType.INPUT;
      HTTP输入.restrict = "0-9";
      HTTP输入.x = 20;
      HTTP输入.y = 40;
      HTTP输入.width = 50;
      HTTP输入.height = 18;
      HTTP输入.border = true;
      HTTP输入.borderColor = 0x999999;
      
      
      SSL文本框.defaultTextFormat = HTTP输入.defaultTextFormat = 样式;
      SSL文本框.text = "SSL端口号（不填或0为随机）";
      SSL文本框.x = 20;
      SSL文本框.y = 80;
      SSL文本框.width = HTTP文本框.textWidth;
      SSL文本框.height = 20;
      
      SSL输入.type = TextFieldType.INPUT;
      SSL输入.restrict = "0-9";
      SSL输入.x = 20;
      SSL输入.y = 100;
      SSL输入.width = 50;
      SSL输入.height = 18;
      SSL输入.border = true;
      SSL输入.borderColor = 0x999999;
      
      var 存储:SharedObject = SharedObject.getLocal(存储名);
      if(存储.data.端口号) {
        HTTP输入.text = 存储.data.HTTP端口号;
        SSL输入.text = 存储.data.SSL端口号;
      }
      
      确定 = new Button();
      确定.setStyle("textFormat", 样式);
      确定.label = "确定";
      确定.x = (宽度 - 确定.width) >> 1;
      确定.y = 250;
      确定.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        存储.data.HTTP端口号 = HTTP输入.text;
        存储.data.SSL端口号 = SSL输入.text;
        存储.flush();
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.关闭设置));
      });
      
      addChild(HTTP文本框);
      addChild(HTTP输入);
      addChild(SSL文本框);
      addChild(SSL输入);
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
    public function get HTTP端口号():int {
      if(HTTP输入.text.length > 0) {
        return parseInt(HTTP输入.text);
      }
      return 0;
    }
    public function get SSL端口号():int {
      if(SSL输入.text.length > 0) {
        return parseInt(HTTP输入.text);
      }
      return 0;
    }
  }
}