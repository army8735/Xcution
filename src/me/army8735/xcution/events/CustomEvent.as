package me.army8735.xcution.events
{
  import flash.events.Event;
  
  public class CustomEvent extends Event
  {
    public static const 刷新:String = "刷新";
    public static const 切换地址:String = "切换地址";
    public static const 启动错误:String = "启动错误";
    public static const 添加规则:String = "添加规则";
    public static const 规则变化:String = "规则变化";
    public static const 清空规则:String = "清空规则";
    public static const 清空消息:String = "清空消息";
    
    private var 数据:*;
    
    public function CustomEvent(类型:String, 数据:* = null)
    {
      super(类型);
      this.数据 = 数据;
    }
    
    public function get 值():* {
      return 数据;
    }
  }
}