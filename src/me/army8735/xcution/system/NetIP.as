package me.army8735.xcution.system
{
  import flash.net.NetworkInfo;
  import flash.net.NetworkInterface;
  import flash.net.InterfaceAddress;

  public class NetIP
  {
    public static function 获取列表():Vector.<String> {
      var 列表:Vector.<String> = new Vector.<String>();
      var 网络列表:Vector.<NetworkInterface> =  NetworkInfo.networkInfo.findInterfaces();
      网络列表.forEach(function(接口:NetworkInterface, 索引:int, 网络列表:Vector.<NetworkInterface>):void {
        接口.addresses.forEach(function(地址:InterfaceAddress, 索引2:int, 地址列表:Vector.<InterfaceAddress>):void {
          列表.push(地址.address);
          trace(地址.address);
        });
      });
      return 列表;
    }
    
    public function NetIP()
    {
    }
    
  }
}