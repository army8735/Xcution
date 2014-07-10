package me.army8735.xcution
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import me.army8735.xcution.events.EventBus;
  import me.army8735.xcution.events.CustomEvent;
	import me.army8735.xcution.http.HttpServer;
	import me.army8735.xcution.system.Proxy;
	
	public class Btns extends Sprite
	{
		private var 运行:CustomButton;
    private var 切换:CustomButton;
    private var 当前地址:String;
		
		public function Btns(控制台:MsgField, 服务器:HttpServer, 首选地址:String)
		{
      服务器.按钮们 = this;
      当前地址 = 首选地址;
      
      运行 = new CustomButton("开启服务器", "关闭服务器");
      运行.x = 5;
      运行.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        if(!运行.enabled) {
          return;
        }
        运行.enabled = false;
        运行.切换();
        if(运行.状态) {
          服务器.开启(当前地址);
          Proxy.设置(服务器.服务地址, 控制台);
        }
        else {
          服务器.关闭();
          Proxy.取消(控制台);
        }
      });
      addChild(运行);
      
      切换 = new CustomButton("自动代理", "手动代理");
      切换.enabled = false;
      切换.x = 运行.x + 运行.width + 10;
      切换.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        if(!切换.enabled) {
          return;
        }
        切换.enabled = false;
        切换.切换();
        if(切换.状态) {
          if(运行.状态) {
            Proxy.设置(服务器.服务地址, 控制台);
          }
          else {
            控制台.追加错误("尚未开启服务器！");
            切换.切换();
            切换.enabled = false;
          }
        }
        else {
          Proxy.取消(控制台);
        }
      });
      addChild(切换);
      
      EventBus.addEventListener(CustomEvent.刷新, function(event:CustomEvent):void {
        运行.enabled = true;
        切换.enabled = 运行.状态;
      });
      EventBus.addEventListener(CustomEvent.切换地址, function(event:CustomEvent):void {
        当前地址 = event.值 as String;
      });
      EventBus.addEventListener(CustomEvent.启动错误, function(event:CustomEvent):void {
        运行.enabled = true;
        运行.切换();
        切换.enabled = false;
      });
		}
		public function 重置():void {
			运行.y = 切换.y = stage.stageHeight - 34;
		}
    public function get 运行按钮():CustomButton {
      return 运行;
    }
    public function get 切换按钮():CustomButton {
      return 切换;
    }
	}
}