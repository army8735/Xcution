package me.army8735.xcution.btns
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import me.army8735.xcution.MsgField;
	import me.army8735.xcution.events.CustomEvent;
	import me.army8735.xcution.events.EventBus;
	import me.army8735.xcution.http.HttpServer;
	import me.army8735.xcution.system.Proxy;
	
	public class Btns extends Sprite
	{
		private var 运行:CustomButton;
    private var 切换:CustomButton;
    private var 当前地址:String;
    private var 添加:SingleButton;
    private var 清空规则:SingleButton;
    private var 清空消息:SingleButton;
		
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
        服务器.切换地址(当前地址);
      });
      EventBus.addEventListener(CustomEvent.启动错误, function(event:CustomEvent):void {
        运行.enabled = true;
        运行.切换();
        切换.enabled = false;
      });
      
      添加 = new SingleButton("添加规则");
      添加.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.添加规则));
      });
      添加.x = 切换.x + 切换.width + 10;
      addChild(添加);
      
      清空规则 = new SingleButton("清空规则");
      清空规则.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.清空规则));
      });
      清空规则.x = 添加.x + 添加.width + 10;
      addChild(清空规则);
      
      清空消息 = new SingleButton("清空消息");
      清空消息.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        EventBus.dispatchEvent(new CustomEvent(CustomEvent.清空消息));
      });
      清空消息.x = 清空规则.x + 清空规则.width + 10;
      addChild(清空消息);
		}
		public function 重置():void {
			运行.y = 切换.y = 添加.y = 清空规则.y = 清空消息.y = stage.stageHeight - 34;
		}
    public function get 运行按钮():CustomButton {
      return 运行;
    }
    public function get 切换按钮():CustomButton {
      return 切换;
    }
	}
}