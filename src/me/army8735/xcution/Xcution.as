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
  
  import me.army8735.xcution.http.HttpServer;
  import me.army8735.xcution.system.NetIP;
  
  public class Xcution extends Sprite
  {
    private var 服务器:HttpServer;
    private var 控制台:MsgField;
    private var 按钮们:Btns;
    private var 上次选择:NativeMenuItem;
    
    public function Xcution()
    {
      visible = false;
      
      stage.frameRate = 30;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      
      var 地址列表:Vector.<String> = NetIP.获取列表();
      var 首选地址:String = NetIP.首选地址(地址列表);
      
      控制台 = new MsgField();
      addChild(控制台);
      
      服务器 = new HttpServer(控制台, 首选地址);
      addChild(服务器);
      
      初始化菜单(地址列表, 首选地址, 服务器);
      
      按钮们 = new Btns(控制台, 服务器);
      addChild(按钮们);
      
      stage.addEventListener(Event.RESIZE, 重置);
      重置();
    }
    private function 重置(event:Event = null):void {
      控制台.重置();
      服务器.重置();
      按钮们.重置();
      
      visible = true;
    }
    private function 初始化菜单(地址列表:Vector.<String>, 首选地址:String, 服务器:HttpServer):void {
      var 文件:NativeMenu = new NativeMenu();
      var 退出:NativeMenuItem = new NativeMenuItem("退出");
      退出.addEventListener(Event.SELECT, function(event:Event):void {
        stage.nativeWindow.close();
      });
      文件.addItem(退出);
      
      var 设置:NativeMenu = new NativeMenu();
      设置.addItem(new NativeMenuItem("设置"));
      
      var 选择:NativeMenu = new NativeMenu();
      var 列表:NativeMenu = new NativeMenu();
      添加列表(列表, 地址列表, 首选地址, 服务器);
      上次选择 = 列表.getItemAt(0);
      上次选择.checked = true;
      选择.addSubmenu(列表, "列表");
      var 刷新:NativeMenuItem = new NativeMenuItem("刷新");
      刷新.addEventListener(Event.SELECT, function(event:Event):void {
        添加列表(列表, NetIP.获取列表(), 上次选择.label, 服务器);
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
    private function 添加列表(列表:NativeMenu, 地址列表:Vector.<String>, 首选地址:String, 服务器:HttpServer):void {
      列表.removeAllItems();
      地址列表.forEach(function(地址:String, 索引:int, 地址列表:Vector.<String>):void {
        if(/\d+\.\d+\.\d+\.\d+/.test(地址)) {
          var 项:NativeMenuItem = new NativeMenuItem(地址);
          项.checked = false;
          项.addEventListener(Event.SELECT, function(event:Event):void {
            if(!项.checked) {
              上次选择.checked = false;
              项.checked = true;
              服务器.切换地址(项.label);
              上次选择 = 项;
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