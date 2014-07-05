package me.army8735.xcution
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class Btn extends SimpleButton
	{
    private var 状态标识:Boolean;
    private var 文字1:String;
    private var 文字2:String;
    private var 文字3:String;
    private var 文字4:String;
    
    private var 普通文本:TextField;
    private var 移入文本:TextField;
    private var 按下文本:TextField;
    
		public function Btn(文字1:String = "已停止", 文字2:String = "开启", 文字3:String = "正运行", 文字4:String = "停止")
		{
      状态标识 = false;
      this.文字1 = 文字1;
      this.文字2 = 文字2;
      this.文字3 = 文字3;
      this.文字4 = 文字4;
      
			[Embed(source="/img/normal.png")]
			var 普通:Class;
			[Embed(source="/img/hover.png")]
			var 移入:Class;
			[Embed(source="/img/down.png")]
			var 按下:Class;
			
			var 样式:TextFormat = new TextFormat();
			样式.font = "宋体";
			样式.align = TextFormatAlign.CENTER;
			
			普通文本 = new TextField();
			移入文本 = new TextField();
			按下文本 = new TextField();
      
      普通文本.defaultTextFormat = 移入文本.defaultTextFormat = 按下文本.defaultTextFormat = 样式;
      普通文本.y = 移入文本.y = 按下文本.y = 8;
      普通文本.text = 文字1;
      移入文本.text =  按下文本.text = 文字2;
			
			var 普通显示:Sprite = new Sprite();
			普通显示.addChild(new 普通());
			普通文本.width = 普通显示.width;
			普通显示.addChild(普通文本);
			
			var 移入显示:Sprite = new Sprite();
			移入显示.addChild(new 移入());
			移入文本.width = 移入显示.width;
			移入显示.addChild(移入文本);
			
			var 按下显示:Sprite = new Sprite();
			按下显示.addChild(new 按下());
			按下文本.width = 按下显示.width;
			按下显示.addChild(按下文本);

			super(普通显示, 移入显示, 按下显示, 按下显示);
		}
    
    public function alt():Boolean {
      状态标识 = !状态标识;
      if(状态标识)
      {
        普通文本.text = 文字3;
        移入文本.text = 按下文本.text = 文字4;
      }
      else {
        普通文本.text = 文字1;
        移入文本.text = 按下文本.text = 文字2;
      }
      return 状态();
    }
    public function 状态():Boolean {
      return 状态标识;
    }
	}
}