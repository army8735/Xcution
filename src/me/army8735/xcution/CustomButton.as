package me.army8735.xcution
{
  import flash.text.TextFormat;
  
  import fl.controls.Button;
  
  public class CustomButton extends Button
  {
    private var 状态标识:Boolean;
    private var 文字1:String;
    private var 文字2:String;
    private var 文字3:String;
    private var 文字4:String;
    
    public function CustomButton(文字1:String, 文字2:String)
    {
      super();
      状态标识 = false;
      this.文字1 = 文字1;
      this.文字2 = 文字2;
      
      var 样式:TextFormat = new TextFormat();
      样式.font = "宋体";
      样式.size = 12;
      setStyle("textFormat", 样式);
      
      label = 文字1;
    }
    public function 切换():Boolean {
      状态标识 = !状态标识;
      if(状态标识)
      {
        label = 文字2;
      }
      else {
        label = 文字1;
      }
      return 状态;
    }
    public function get 状态():Boolean {
      return 状态标识;
    }
  }
}