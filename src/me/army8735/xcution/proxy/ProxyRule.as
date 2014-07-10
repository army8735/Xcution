package me.army8735.xcution.proxy
{
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.net.FileReference;
  import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  
  public class ProxyRule extends Sprite
  {
    public static const 高度:int = 28;
    public static const 边距:int = 5;
    
    public static const 单个文件:int = 0;
    public static const 文件路径:int = 1;
    public static const 正则匹配:int = 2;
    
    private var 代理类型:int;
    private var 类型图标:Sprite;
    
    private var 状态值:Boolean;
    private var 按钮开:Sprite;
    private var 按钮关:Sprite;
    
    private var 拦截文本:TextField;
    private var 目标文本:TextField;
    private var 箭头:Sprite;
    
    private var 文件映射图标:Sprite;
    private var 路径映射图标:Sprite;
    private var 自定义映射图标:Sprite;
    
    public function ProxyRule(代理类型:int = 单个文件)
    {
      x = ProxyRule.边距;
      y = ProxyRule.边距;
      
      状态值 = false;
      this.代理类型 = 代理类型;
      
      [Embed(source="/img/okay.png")]
      var 打开:Class;
      [Embed(source="/img/pause.png")]
      var 关闭:Class;
      [Embed(source="/img/arrow.png")]
      var 方向:Class;
      [Embed(source="/img/file.png")]
      var 文件映射:Class;
      [Embed(source="/img/folder.png")]
      var 路径映射:Class;
      [Embed(source="/img/custom.png")]
      var 自定义映射:Class;
      
      按钮开 = new Sprite();
      按钮开.addChild(new 打开());
      
      按钮关 = new Sprite();
      按钮关.addChild(new 关闭());
      
      按钮开.x = 按钮开.y = 按钮关.x = 按钮关.y = 6;
      按钮开.buttonMode = 按钮关.buttonMode = true;
      按钮开.visible = false;
      
      按钮开.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        按钮开.visible = false;
        按钮关.visible = true;
      });
      按钮关.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        按钮开.visible = true;
        按钮关.visible = false;
      });
      
      addChild(按钮开);
      addChild(按钮关);
      
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      
      拦截文本 = new TextField();
      目标文本 = new TextField();
      箭头 = new Sprite();
      
      拦截文本.type = 目标文本.type = TextFieldType.INPUT;
      拦截文本.defaultTextFormat = 目标文本.defaultTextFormat = 样式;
      拦截文本.border = 目标文本.border = true;
      拦截文本.borderColor = 目标文本.borderColor = 0xDDDDDD;
      拦截文本.background = 目标文本.background = true;
      拦截文本.backgroundColor = 目标文本.backgroundColor = 0xFFFFFF;
      拦截文本.y = 目标文本.y = 5;
      拦截文本.height = 目标文本.height = 18;
      
      箭头.y = 6;
      箭头.buttonMode = true;
      箭头.addEventListener(MouseEvent.CLICK, function(event:Event):void {
        var 文件:FileReference = new FileReference();
        文件.browse();
      });
      箭头.addChild(new 方向());
      
      addChild(拦截文本);
      addChild(目标文本);
      addChild(箭头);
      
      文件映射图标 = new Sprite();
      文件映射图标.addChild(new 文件映射());
      路径映射图标 = new Sprite();
      路径映射图标.addChild(new 路径映射());
      自定义映射图标 = new Sprite();
      自定义映射图标.addChild(new 自定义映射());
      
      文件映射图标.buttonMode = 路径映射图标.buttonMode = 自定义映射图标.buttonMode = true;
      文件映射图标.y = 路径映射图标.y = 自定义映射图标.y = 6;
      文件映射图标.alpha = 1;
      路径映射图标.alpha = 0.1;
      自定义映射图标.alpha = 0.1;
      
      文件映射图标.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        改变类型(单个文件);
        文件映射图标.alpha = 1;
        路径映射图标.alpha = 0.1;
        自定义映射图标.alpha = 0.1;
      });
      路径映射图标.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        改变类型(文件路径);
        文件映射图标.alpha = 0.1;
        路径映射图标.alpha = 1;
        自定义映射图标.alpha = 0.1;
      });
      自定义映射图标.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        改变类型(正则匹配);
        文件映射图标.alpha = 0.1;
        路径映射图标.alpha = 0.1;
        自定义映射图标.alpha = 1;
      });
      
      addChild(文件映射图标);
      addChild(路径映射图标);
      addChild(自定义映射图标);
      
      addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void {
        重置();
      });
    }
    public function get 类型():int {
      return 代理类型;
    }
    public function 重置():void {
      graphics.clear();
      graphics.beginFill(0xFCFCFC);
      graphics.drawRoundRect(0, 0, stage.stageWidth - 边距 * 8, 高度, 5);
      graphics.endFill();
      graphics.lineStyle(1, 0x99CCFF);
      graphics.drawRoundRect(0, 0, stage.stageWidth - 边距 * 8, 高度, 5);
      
      拦截文本.width = 目标文本.width = (stage.stageWidth - 边距 * 30) >> 1;
      拦截文本.x = 28;
      目标文本.x = 拦截文本.x + 拦截文本.width + 边距 * 5;
      箭头.x = 拦截文本.x + 拦截文本.width + 边距 * 1;
      文件映射图标.x = 目标文本.width + 目标文本.x + 边距;
      路径映射图标.x = 文件映射图标.x + 18;
      自定义映射图标.x = 路径映射图标.x + 18;
    }
    public function 状态():Boolean {
      return 状态值;
    }
    public function 改变类型(代理类型:int = 单个文件):void {
      this.代理类型 = 代理类型;
    }
  }
}