package me.army8735.xcution.proxy
{
  public class ProxyFile
  {
    public static const 单个文件:int = 0;
    public static const 文件路径:int = 1;
    public static const 正则匹配:int = 2;
    
    private var 代理类型:int;
    
    public function ProxyFile(代理类型:int)
    {
      this.代理类型 = 代理类型;
    }
    public function get 类型():int {
      return 代理类型;
    }
  }
}