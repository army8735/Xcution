package me.army8735.xcution
{
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  
  import me.army8735.xcution.http.HttpServer;
  
  public class Xcution extends Sprite
  {
    private var 服务器:HttpServer;
    private var 控制台:MsgField;
    private var 按钮们:Btns;
    
    public function Xcution()
    {
      visible = false;
      
      stage.frameRate = 30;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      
      控制台 = new MsgField();
      addChild(控制台);
      
      服务器 = new HttpServer(控制台);
      addChild(服务器);
      
      按钮们 = new Btns(控制台, 服务器);
      addChild(按钮们);
      
      stage.addEventListener(Event.RESIZE, 重置);
      重置();
    }
    private function 重置(event:Event = null):void {
      服务器.重置();
      控制台.重置();
      按钮们.重置();
      
      visible = true;
    }
  }
}