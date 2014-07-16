package me.army8735.xcution.http
{
  import flash.net.Socket;
  import flash.utils.ByteArray;

  public class SSLConnect
  {
    private var 请求:HttpsRequest;
    private var 客户端:Socket;
    
    public function SSLConnect(请求:HttpsRequest, 客户端:Socket)
    {
      this.请求 = 请求;
      this.客户端 = 客户端;
    }
    public function 解析(记录:ByteArray):void {
      var 内容类型:int = 记录.readUnsignedByte();
      if(内容类型 != 22) {
        trace("非握手协议：", 内容类型, 客户端.remoteAddress + ":" + 客户端.remotePort);
        客户端.close();
        客户端 = null;
        return;
      }
      var 主版本:int = 记录.readByte();
      var 次版本:int = 记录.readByte();
      var 压缩长度:int = 记录.readByte();
      var 明文:ByteArray = new ByteArray();
      记录.readBytes(明文, 0, 压缩长度);
      var MAC:ByteArray = new ByteArray();
      记录.readBytes(明文, 0);
      trace("握手记录：", 内容类型, 主版本, 次版本, 压缩长度, MAC.length, 明文.length, 客户端.remoteAddress + ":" + 客户端.remotePort);
      解析报文(明文);
    }
    private function 解析报文(明文:ByteArray):void {
      var 类型:int = 明文.readByte();
      var 长度:ByteArray = new ByteArray();
      明文.readBytes(长度, 0, 3);
      var 长度值:int = ((长度[0] as int) << 2) + ((长度[1] << 1 as int)) + (长度[2] as int);
      var 内容:ByteArray = new ByteArray();
      明文.readBytes(内容);
      解析内容(内容);
      trace(类型, 长度值, 内容.length);
    }
    private function 解析内容(内容:ByteArray):void {
      var 主版本:int = 内容.readByte();
      var 次版本:int = 内容.readByte();
      var 系统时间:uint = 内容.readUnsignedInt();
      var 随机数:ByteArray = new ByteArray();
      内容.readBytes(随机数, 0, 28);
      trace(主版本, 次版本);
    }
    private function 转换(数据:ByteArray):int {
      var 值:int = 0;
      for(var i:int = 0; i < 数据.length; i++) {
        
      }
      return 0;
    }
  }
}