package me.army8735.xcution
{
  import flash.desktop.NativeApplication;
  import flash.display.NativeMenu;
  import flash.display.NativeMenuItem;
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.net.URLRequest;
  import flash.net.navigateToURL;
  
  import me.army8735.xcution.btns.Btns;
  import me.army8735.xcution.events.CustomEvent;
  import me.army8735.xcution.events.EventBus;
  import me.army8735.xcution.net.HttpServer;
  import me.army8735.xcution.proxy.ProxyPanel;
  import me.army8735.xcution.system.Config;
  import me.army8735.xcution.system.Mask;
  import me.army8735.xcution.system.NetIP;
  
  public class Xcution extends Sprite
  {
    private var 规则面板:ProxyPanel;
    private var 服务器:HttpServer;
    private var 控制台:MsgField;
    private var 按钮们:Btns;
    private var 上次选择:NativeMenuItem;
    private var 遮罩:Mask;
    private var 配置:Config;
    
    public function Xcution()
    {
      visible = false;
      
      stage.color = 0xDDDDDD;
      stage.frameRate = 30;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      stage.frameRate = 1;
      
      规则面板 = new ProxyPanel();
      addChild(规则面板);
      
      var 地址列表:Vector.<String> = NetIP.获取列表();
      var 首选地址:String = NetIP.首选地址(地址列表);
      
      控制台 = new MsgField();
      addChild(控制台);
      
      配置 = new Config();
      服务器 = new HttpServer(规则面板, 控制台, 首选地址, 配置);
      addChild(服务器);
      
      初始化菜单(地址列表, 首选地址, 服务器);
      
      按钮们 = new Btns(控制台, 服务器, 首选地址);
      addChild(按钮们);
      
      遮罩 = new Mask();
      遮罩.visible = false;
      addChild(遮罩);
      
      配置.visible = false;
      addChild(配置);
      
      stage.addEventListener(Event.RESIZE, 重置);
      重置();
    }
    private function 重置(event:Event = null):void {
      规则面板.重置();
      控制台.重置();
      服务器.重置();
      按钮们.重置();
      配置.重置();
      遮罩.重置();
      
      visible = true;
    }
    private function 初始化菜单(地址列表:Vector.<String>, 首选地址:String, 服务器:HttpServer):void {
      var 文件:NativeMenu = new NativeMenu();
      var 新建规则:NativeMenu = new NativeMenu();
      
      var 单个文件:NativeMenuItem = new NativeMenuItem("单个文件");
      var 文件路径:NativeMenuItem = new NativeMenuItem("文件路径");
      var 正则匹配:NativeMenuItem = new NativeMenuItem("正则匹配");
      
      单个文件.addEventListener(Event.SELECT, function(event:Event):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.添加规则, 0));
      });
      文件路径.addEventListener(Event.SELECT, function(event:Event):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.添加规则, 1));
      });
      正则匹配.addEventListener(Event.SELECT, function(event:Event):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.添加规则, 2));
      });
      
      新建规则.addItem(单个文件);
      新建规则.addItem(文件路径);
      新建规则.addItem(正则匹配);
      
      文件.addSubmenu(新建规则, "新建规则");
      
      var 退出:NativeMenuItem = new NativeMenuItem("退出");
      退出.addEventListener(Event.SELECT, function(event:Event):void {
        stage.nativeWindow.close();
      });
      文件.addItem(退出);
      
      var 设置:NativeMenu = new NativeMenu();
      var 设置按钮:NativeMenuItem = new NativeMenuItem("设置");
      设置按钮.addEventListener(Event.SELECT, function(event:Event):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.设置));
      });
      设置.addItem(设置按钮);
      
      var 选择:NativeMenu = new NativeMenu();
      var 列表:NativeMenu = new NativeMenu();
      添加列表(列表, 地址列表, 首选地址);
      上次选择 = 列表.getItemAt(0);
      上次选择.checked = true;
      选择.addSubmenu(列表, "列表");
      var 刷新:NativeMenuItem = new NativeMenuItem("刷新");
      刷新.addEventListener(Event.SELECT, function(event:Event):void {
        添加列表(列表, NetIP.获取列表(), 上次选择.label);
      });
      选择.addItem(刷新);
      
      var 帮助:NativeMenu = new NativeMenu();
      帮助.addItem(new NativeMenuItem("MIT License"));
      var 链接:NativeMenuItem = new NativeMenuItem("view on git");
      链接.addEventListener(Event.SELECT, function(event:Event):void {
        navigateToURL(new URLRequest("https://github.com/army8735/Xcution"));
      });
      帮助.addItem(链接);
      
      var 菜单:NativeMenu = new NativeMenu();
      菜单.addSubmenu(文件, "文件");
      菜单.addSubmenu(选择, "选择");
      菜单.addSubmenu(设置, "设置");
      菜单.addSubmenu(帮助, "帮助");
      
      stage.nativeWindow.menu = 菜单;
      NativeApplication.nativeApplication.menu = 菜单;
    }
    private function 添加列表(列表:NativeMenu, 地址列表:Vector.<String>, 首选地址:String):void {
      列表.removeAllItems();
      地址列表.forEach(function(地址:String, 索引:int, 地址列表:Vector.<String>):void {
        if(/\d+\.\d+\.\d+\.\d+/.test(地址)) {
          var 项:NativeMenuItem = new NativeMenuItem(地址);
          项.checked = false;
          项.addEventListener(Event.SELECT, function(event:Event):void {
            if(!项.checked) {
              上次选择.checked = false;
              项.checked = true;
              上次选择 = 项;
              EventBus.dispatchEvent(new CustomEvent(CustomEvent.切换地址, 项.label));
            }
          });
          if(地址 == 首选地址) {
            项.checked = true;
            列表.addItemAt(项, 0);
          }
          else {
           列表.addItem(项);
          }
        }
      });
    }
  }
}