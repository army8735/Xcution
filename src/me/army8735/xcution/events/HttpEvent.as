package me.army8735.xcution.events
{
  import flash.events.Event;
  import flash.utils.ByteArray;
  
  public class HttpEvent extends Event
  {
    public static const 流:String = "流";
    public static const 关闭:String = "关闭";
    
    private var 值:ByteArray;
    
    public function HttpEvent(类型:String, 值:ByteArray = null)
    {
      super(类型);
      this.值 = 值;
    }
    public function get 数据():ByteArray {
      return 值;
    }
  }
}