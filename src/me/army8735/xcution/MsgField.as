package me.army8735.xcution
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import fl.controls.UIScrollBar;
	
	public class MsgField extends Sprite
	{
		private var 文本框:TextField;
		private var 滚动条:UIScrollBar;
		private var 默认样式:TextFormat;
		private var 高亮样式:TextFormat;
    private var 警告样式:TextFormat;
		private var 错误样式:TextFormat;
		
		public function MsgField()
		{
			文本框 = new TextField();
      文本框.background = true;
      文本框.backgroundColor = 0xF0F0F0;
			文本框.multiline = true;
			默认样式 = new TextFormat();
			默认样式.font = "宋体";
			默认样式.color = 0x404040;
      默认样式.leading = 4;
			文本框.defaultTextFormat = 默认样式;
			文本框.x = 10;
			文本框.y = 5;
			文本框.wordWrap = true;
			addChild(文本框);
			
			滚动条 = new UIScrollBar();
			滚动条.y = 0;
			滚动条.scrollTarget = 文本框;
			addChild(滚动条);
		
			
			高亮样式 = new TextFormat();
			高亮样式.color = 0x0000FF;
      警告样式 = new TextFormat();
      警告样式.color = 0xFF9900;
			错误样式 = new TextFormat();
			错误样式.color = 0xFF0000;
		}
		
		public function 重置():void {
			graphics.clear();
			graphics.lineStyle(1, 0xA0A0A0);
			graphics.beginFill(0xFCFCFC);
			graphics.drawRoundRect(5, 0, stage.stageWidth - 30, (stage.stageHeight >> 1) - 40, 3);
			graphics.endFill();
			
			文本框.width = stage.stageWidth - 40;
			文本框.height = (stage.stageHeight >> 1) - 50;
			滚动条.x = 文本框.x + 文本框.width + 10;
			滚动条.height = 文本框.height + 10;
			
			y = stage.stageHeight >> 1;
		}
		public function 追加(s:String):void {
      s = s.replace(/[\r\n]+/g, "\n").replace(/^\s+/, "").replace(/\s+$/, "");
      trace(s);
      s += "\n";
			文本框.appendText(s);
			文本框.setTextFormat(默认样式, 文本框.text.length - s.length, 文本框.text.length);
			文本框.scrollV = 文本框.numLines;
			滚动条.update();
		}
		public function 追加高亮(s:String):void {
      s = s.replace(/[\r\n]+/g, "\n").replace(/^\s+/, "").replace(/\s+$/, "");
      trace(s);
      s += "\n";
			文本框.appendText(s);
			文本框.setTextFormat(高亮样式, 文本框.text.length - s.length, 文本框.text.length);
			文本框.scrollV = 文本框.numLines;
			滚动条.update();
		}
    public function 追加警告(s:String):void {
      s = s.replace(/[\r\n]+/g, "\n").replace(/^\s+/, "").replace(/\s+$/, "");
      trace(s);
      s += "\n";
      文本框.appendText(s);
      文本框.setTextFormat(警告样式, 文本框.text.length - s.length, 文本框.text.length);
      文本框.scrollV = 文本框.numLines;
      滚动条.update();
    }
		public function 追加错误(s:String):void {
      s = s.replace(/[\r\n]+/g, "\n").replace(/^\s+/, "").replace(/\s+$/, "");
      trace(s);
      s += "\n";
			文本框.appendText(s);
			文本框.setTextFormat(错误样式, 文本框.text.length - s.length, 文本框.text.length);
			文本框.scrollV = 文本框.numLines;
			滚动条.update();
		}
		public function 清空():void {
			文本框.text = "";
			滚动条.update();
		}
	}
}