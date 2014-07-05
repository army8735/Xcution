package me.army8735.xcution
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import me.army8735.xcution.http.HttpServer;
	import me.army8735.xcution.proxy.Proxy;
	
	public class Btns extends Sprite
	{
		private var 运行:Btn;
		
		public function Btns(控制台:MsgField, 服务器:HttpServer)
		{
      运行 = new Btn();
      运行.x = 10;
      运行.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        运行.alt();
        var 状态:Boolean = 运行.状态();
        if(状态) {
          Proxy.设置(服务器.服务地址, 控制台);
        }
        else {
          Proxy.取消(控制台);
        }
      });
      addChild(运行);
		}
		
		public function 重置():void {
			运行.y = stage.stageHeight - 37;
		}
	}
}