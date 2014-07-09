package me.army8735.xcution
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import me.army8735.xcution.http.HttpServer;
	import me.army8735.xcution.proxy.Proxy;
	import me.army8735.xcution.events.EventBus;
	
	public class Btns extends Sprite
	{
		private var 运行:CustomButton;
		
		public function Btns(控制台:MsgField, 服务器:HttpServer)
		{
      服务器.按钮们 = this;
      
      运行 = new CustomButton();
      运行.x = 5;
      运行.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        if(!运行.enabled) {
          return;
        }
        运行.alt();
        var 状态:Boolean = 运行.状态();
        if(状态) {
          Proxy.设置(服务器.服务地址, 控制台);
        }
        else {
          Proxy.取消(控制台);
        }
        运行.enabled = false;
      });
      addChild(运行);
      
      EventBus.addEventListener(EventBus.刷新, function(event:Event):void {
        运行.enabled = true;
      });
		}
		public function 重置():void {
			运行.y = stage.stageHeight - 34;
		}
    public function get 运行按钮():CustomButton {
      return 运行;
    }
	}
}