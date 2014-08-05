package me.army8735.xcution.proxy
{
  import flash.display.NativeMenu;
  import flash.display.NativeMenuItem;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.filesystem.File;
  import flash.net.FileFilter;
  import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  
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
    private var 按钮移除:Sprite;
    
    private var 拦截文本:TextField;
    private var 映射文本:TextField;
    private var 箭头:Sprite;
    
    private var 文件映射图标:Sprite;
    private var 路径映射图标:Sprite;
    private var 自定义映射图标:Sprite;
    
    private var 菜单:NativeMenu;
    private var 转为匿名:NativeMenu;
    private var 开启匿名:NativeMenuItem;
    private var 关闭匿名:NativeMenuItem;
    private var 编码菜单:NativeMenu;
    private var UTF8:NativeMenuItem;
    private var GBK:NativeMenuItem;
    
    public function ProxyRule(面板:ProxyPanel, 代理类型:int = 单个文件, 拦截内容:String = "", 映射内容:String = "", 状态值:Boolean = false, 匿名值:Boolean = false, 编码:String = "UTF-8")
    {
      x = ProxyRule.边距;
      y = ProxyRule.边距;
      
      this.状态值 = 状态值;
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
      [Embed(source="/img/remove2.png")]
      var 移除:Class;
      
      按钮开 = new Sprite();
      按钮开.addChild(new 打开());
      
      按钮关 = new Sprite();
      按钮关.addChild(new 关闭());
      
      按钮移除 = new Sprite();
      按钮移除.addChild(new 移除());
      
      按钮开.x = 按钮开.y = 按钮关.x = 按钮关.y = 按钮移除.y = 6;
      按钮开.alpha = 按钮关.alpha = 0.5;
      按钮开.buttonMode = 按钮关.buttonMode = 按钮移除.buttonMode = true;
      
      if(状态值) {
        按钮开.visible = true;
        按钮关.visible = false;
      }
      else {
        按钮开.visible = false;
        按钮关.visible = true;
      }
      按钮移除.alpha = 0.2;
      按钮移除.x = 26;
      
      var 规则:ProxyRule = this;
      按钮开.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        按钮开.visible = false;
        按钮关.visible = true;
        规则.状态值 = false;
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      按钮关.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        按钮开.visible = true;
        按钮关.visible = false;
        规则.状态值 = true;
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      按钮开.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void {
        按钮开.alpha = 1;
      });
      按钮开.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void {
        按钮开.alpha = 0.5;
      });
      按钮关.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void {
        按钮关.alpha = 1;
      });
      按钮关.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void {
        按钮关.alpha = 0.5;
      });
      
      按钮移除.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        面板.移除(规则);
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      按钮移除.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void {
        按钮移除.alpha = 1;
      });
      按钮移除.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void {
        按钮移除.alpha = 0.2;
      });
      
      addChild(按钮开);
      addChild(按钮关);
      addChild(按钮移除);
      
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      
      拦截文本 = new TextField();
      映射文本 = new TextField();
      箭头 = new Sprite();
      
      拦截文本.type = 映射文本.type = TextFieldType.INPUT;
      拦截文本.defaultTextFormat = 映射文本.defaultTextFormat = 样式;
      拦截文本.border = 映射文本.border = true;
      拦截文本.borderColor = 映射文本.borderColor = 0xDDDDDD;
      拦截文本.background = 映射文本.background = true;
      拦截文本.backgroundColor = 映射文本.backgroundColor = 0xFFFFFF;
      拦截文本.y = 映射文本.y = 5;
      拦截文本.height = 映射文本.height = 18;
      拦截文本.text = 拦截内容;
      映射文本.text = 映射内容;
      
      拦截文本.addEventListener(Event.CHANGE, function(event:Event):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      映射文本.addEventListener(Event.CHANGE, function(event:Event):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      
      箭头.y = 6;
      箭头.buttonMode = true;
      箭头.addEventListener(MouseEvent.CLICK, 选择文件侦听);
      箭头.addChild(new 方向());
      
      addChild(拦截文本);
      addChild(映射文本);
      addChild(箭头);
      
      文件映射图标 = new Sprite();
      文件映射图标.addChild(new 文件映射());
      路径映射图标 = new Sprite();
      路径映射图标.addChild(new 路径映射());
      自定义映射图标 = new Sprite();
      自定义映射图标.addChild(new 自定义映射());
      
      文件映射图标.buttonMode = 路径映射图标.buttonMode = 自定义映射图标.buttonMode = true;
      文件映射图标.y = 路径映射图标.y = 自定义映射图标.y = 6;
      文件映射图标.alpha = 0.2;
      路径映射图标.alpha = 0.2;
      自定义映射图标.alpha = 0.2;
      switch(代理类型) {
        case 单个文件:
          文件映射图标.alpha = 1;
          break;
        case 文件路径:
          路径映射图标.alpha = 1;
          break;
        case 正则匹配:
          自定义映射图标.alpha = 1;
          break;
      }
      
      function 文件映射图标点击(event:MouseEvent):void {
        改变类型(单个文件);
        文件映射图标.alpha = 1;
        路径映射图标.alpha = 0.2;
        自定义映射图标.alpha = 0.2;
      }
      文件映射图标.addEventListener(MouseEvent.CLICK, 文件映射图标点击);
      文件映射图标.addEventListener(MouseEvent.MIDDLE_CLICK, 文件映射图标点击);
//      文件映射图标.addEventListener(MouseEvent.CONTEXT_MENU, 文件映射图标点击);
      文件映射图标.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void {
        if(类型 != 单个文件) {
          文件映射图标.alpha = 0.6;
        }
      });
      文件映射图标.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void {
        if(类型 != 单个文件) {
          文件映射图标.alpha = 0.2;
        }
      });
      function 路径映射图标点击(event:MouseEvent):void {
        改变类型(文件路径);
        文件映射图标.alpha = 0.2;
        路径映射图标.alpha = 1;
        自定义映射图标.alpha = 0.2;
      }
      路径映射图标.addEventListener(MouseEvent.CLICK, 路径映射图标点击);
      路径映射图标.addEventListener(MouseEvent.MIDDLE_CLICK, 路径映射图标点击);
//      路径映射图标.addEventListener(MouseEvent.CONTEXT_MENU, 路径映射图标点击);
      路径映射图标.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void {
        if(类型 != 文件路径) {
         路径映射图标.alpha = 0.6;
        }
      });
      路径映射图标.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void {
        if(类型 != 文件路径) {
          路径映射图标.alpha = 0.2;
        }
      });
      function 自定义映射图标点击(event:MouseEvent):void {
        改变类型(正则匹配);
        文件映射图标.alpha = 0.2;
        路径映射图标.alpha = 0.2;
        自定义映射图标.alpha = 1;
      }
      自定义映射图标.addEventListener(MouseEvent.CLICK, 自定义映射图标点击);
      自定义映射图标.addEventListener(MouseEvent.MIDDLE_CLICK, 自定义映射图标点击);
//      自定义映射图标.addEventListener(MouseEvent.CONTEXT_MENU, 自定义映射图标点击);
      自定义映射图标.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void {
        if(类型 != 正则匹配) {
          自定义映射图标.alpha = 0.6;
        }
      });
      自定义映射图标.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void {
        if(类型 != 正则匹配) {
          自定义映射图标.alpha = 0.2;
        }
      });
      文件映射图标.addEventListener(MouseEvent.MIDDLE_CLICK, 选择文件侦听);
      路径映射图标.addEventListener(MouseEvent.MIDDLE_CLICK, 选择文件侦听);
      自定义映射图标.addEventListener(MouseEvent.MIDDLE_CLICK, 选择文件侦听);
//      文件映射图标.addEventListener(MouseEvent.CONTEXT_MENU, 选择文件侦听);
//      路径映射图标.addEventListener(MouseEvent.CONTEXT_MENU, 选择文件侦听);
//      自定义映射图标.addEventListener(MouseEvent.CONTEXT_MENU, 选择文件侦听);
      
      addChild(文件映射图标);
      addChild(路径映射图标);
      addChild(自定义映射图标);
      
      addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void {
        重置();
      });
      
      菜单 = new NativeMenu();
      转为匿名 = new NativeMenu();
      关闭匿名 = new NativeMenuItem("关闭");
      关闭匿名.addEventListener(Event.SELECT, function(event:Event):void {
        关闭匿名.checked = true;
        开启匿名.checked = false;
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      开启匿名 = new NativeMenuItem("开启");
      开启匿名.addEventListener(Event.SELECT, function(event:Event):void {
        关闭匿名.checked = false;
        开启匿名.checked = true;
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      匿名值 ? 开启匿名.checked = true : 关闭匿名.checked = true;
      编码菜单 = new NativeMenu();
      UTF8 = new NativeMenuItem("UTF8");
      GBK = new NativeMenuItem("GBK");
      UTF8.addEventListener(Event.SELECT, function(event:Event):void {
        UTF8.checked = true;
        GBK.checked = false;
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      GBK.addEventListener(Event.SELECT, function(event:Event):void {
        UTF8.checked = false;
        GBK.checked = true;
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
      编码 == "UTF-8" ? UTF8.checked = true : GBK.checked = true;
      
      转为匿名.addItem(关闭匿名);
      转为匿名.addItem(开启匿名);
      编码菜单.addItem(UTF8);
      编码菜单.addItem(GBK);
      菜单.addSubmenu(转为匿名, "转为匿名");
      菜单.addSubmenu(编码菜单, "编码");
      contextMenu = 菜单;
    }
    public function get 类型():int {
      return 代理类型;
    }
    private function 绘制边框():void {
      switch(类型) {
        case 单个文件:
          graphics.lineStyle(1, 0x99CC99);
          break;
        case 文件路径:
          graphics.lineStyle(1, 0xFFCC99);
          break;
        case 正则匹配:
          graphics.lineStyle(1, 0x99CCFF);
          break;
      }
      graphics.drawRoundRect(0, 0, stage.stageWidth - 边距 * 8, 高度, 5);
      graphics.endFill();
    }
    public function 重置():void {
      graphics.clear();
      graphics.beginFill(0xFCFCFC);
      graphics.drawRoundRect(0, 0, stage.stageWidth - 边距 * 8, 高度, 5);
      graphics.endFill();
      绘制边框();
      
      拦截文本.width = 映射文本.width = (stage.stageWidth - 边距 * 34) >> 1;
      拦截文本.x = 46;
      映射文本.x = 拦截文本.x + 拦截文本.width + 边距 * 5;
      箭头.x = 拦截文本.x + 拦截文本.width + 边距 * 1;
      文件映射图标.x = 映射文本.width + 映射文本.x + 边距;
      路径映射图标.x = 文件映射图标.x + 18;
      自定义映射图标.x = 路径映射图标.x + 18;
    }
    public function get 状态():Boolean {
      return 状态值;
    }
    public function 改变类型(代理类型:int = 单个文件):void {
      this.代理类型 = 代理类型;
      绘制边框();
      EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
    }
    public function get 拦截路径():String {
      return 拦截文本.text.replace(/^\s+/, "").replace(/\s+$/, "");
    }
    public function get 映射路径():String {
      return 映射文本.text.replace(/^\s+/, "").replace(/\s+$/, "");
    }
    public function get 匿名转换():Boolean {
      return 开启匿名.checked;
    }
    public function get 编码():String {
      return UTF8.checked ? "UTF-8" : "GBK";
    }
    private function 选择文件侦听(event:MouseEvent):void {
      var 文件:File = new File();
      var 过滤:Array = new Array();
      switch(类型) {
        case 单个文件:
          文件.browseForOpen("选择单个文件", [
            new FileFilter("img", "*.jpg;*.jpeg;*.gif;*.png"),
            new FileFilter("css", "*.css"),
            new FileFilter("js", "*.js"),
            new FileFilter("all", "*.*")
          ]);
          break;
        case 文件路径:
          文件.browseForDirectory("选择文件目录");
          break;
        case 正则匹配:
          stage.focus = 映射文本;
          return;
      }
      文件.addEventListener(Event.SELECT, function(event:Event):void {
        映射文本.text = 文件.nativePath;
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.规则变化));
      });
    }
    public function 命中(路径:String):Boolean {
      if(!状态) {
        return false;
      }
      switch(类型) {
        case 单个文件:
          return 路径 == 拦截路径;
        case 文件路径:
          return 路径.indexOf(拦截路径) == 0;
        case 正则匹配:
          return new RegExp(拦截路径).test(路径);
      }
      return false;
    }
    public function 映射(路径:String):String {
      switch(类型) {
        case 单个文件:
          return 映射路径;
        case 文件路径:
          return 映射路径 + 路径.slice(拦截路径.length).replace(/\//g, File.separator);
        case 正则匹配:
          return 路径.replace(new RegExp(拦截路径), 映射路径);
      }
      throw new Error("未知错误，命中却无映射");
    }
    public function 序列化():String {
      return 类型 + "\r\n" + 拦截路径 + "\r\n" + 映射路径 + "\r\n" + 状态 + "\r\n" + 匿名转换 + "\r\n" + 编码;
    }
    public static function 反序列化(值:String):Array {
      var 数组:Array = 值.split("\r\n");
      数组[0] = parseInt(数组[0]);
      数组[3] = 数组[3] === "true";
      数组[4] = 数组[4] === "true";
      return 数组;
    }
  }
}