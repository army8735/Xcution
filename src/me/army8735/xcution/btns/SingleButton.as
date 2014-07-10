package me.army8735.xcution.btns
{
  import flash.text.TextFormat;
  
  import fl.controls.Button;
  
  public class SingleButton extends Button
  {
    private var 状态标识:Boolean;
    private var 文字:String;
    
    public function SingleButton(文字:String)
    {
      super();
      状态标识 = false;
      this.文字 = 文字;
      
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      样式.size = 12;
      setStyle("textFormat", 样式);
      
      label = 文字;
    }
  }
}