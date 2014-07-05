package me.army8735.xcution
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class Btns extends Sprite
	{
		private var 运行:Btn;
		
		public function Btns()
		{
      运行 = new Btn();
      运行.x = 10;
      运行.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        运行.alt();
      });
      addChild(运行);
		}
		
		public function 重置():void {
			运行.y = stage.stageHeight - 37;
		}
	}
}