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
    public function 解析(记录:ByteArray):ByteArray {
      var 结果:ByteArray = new ByteArray();
      var 内容类型:int = 记录.readUnsignedByte();
      if(内容类型 != 22) {
        trace("非握手协议：", 内容类型, 客户端.remoteAddress + ":" + 客户端.remotePort);
        客户端.close();
        客户端 = null;
        return null;
      }
      var 主版本:int = 记录.readByte();
      var 次版本:int = 记录.readByte();
      var 压缩长度:int = 记录.readShort();
      var 明文:ByteArray = new ByteArray();
      记录.readBytes(明文, 0, 压缩长度);
      var MAC:ByteArray = new ByteArray();
      记录.readBytes(明文, 0);
      trace("握手记录：", 内容类型, 主版本, 次版本, 压缩长度, MAC.length, 明文.length, 客户端.remoteAddress + ":" + 客户端.remotePort);
      var 返回报文:ByteArray = 解析报文(明文);
      结果.writeByte(22);
      结果.writeByte(3);
      结果.writeByte(1);
      结果.writeByte(返回报文.length);
      结果.writeBytes(返回报文);
      结果.writeByte(0);
      return 结果;
    }
    private function 解析报文(明文:ByteArray):ByteArray {
      var 结果:ByteArray = new ByteArray();
      var 类型:int = 明文.readByte();
      var 长度:ByteArray = new ByteArray();
      明文.readBytes(长度, 0, 3);
      var 长度值:int = 转为整型(长度);
      var 内容:ByteArray = new ByteArray();
      明文.readBytes(内容);
      trace(类型, 长度值, 内容.length);
      switch(类型) {
        case 1:
          结果.writeShort(2);
          var 返回你好:ByteArray = 你好(内容);
          break;
      }
      return 结果;
    }
    private function 你好(内容:ByteArray):ByteArray {
      var 结果:ByteArray = new ByteArray();
      var 主版本:int = 内容.readByte();
      var 次版本:int = 内容.readByte();
      var 随机数:ByteArray = new ByteArray();
      内容.readBytes(随机数, 0, 32);
      var 会话长:uint = 内容.readByte();
      var 会话:ByteArray = new ByteArray();
      if(会话长 > 0) {
        内容.readBytes(会话, 0, 会话长);
      }
      trace(主版本, 次版本, 随机数.length, 会话长, 会话.length);
      var 密钥套件列表:Array = [];
      var 密钥套件长:uint = 内容.readUnsignedShort();
      for(var 索引:int = 0; 索引 < 密钥套件长 / 2; 索引++) {
        密钥套件列表.push(内容.readUnsignedShort());
      }
      trace(密钥套件长, 密钥套件列表.join(','));
      var 压缩算法列表:Array = [];
      var 压缩算法长:uint = 内容.readUnsignedByte();
      for(索引 = 0; 索引 < 压缩算法长; 索引++) {
        压缩算法列表.push(内容.readByte());
      }
      trace(压缩算法长, 压缩算法列表.join(','), 内容.bytesAvailable);
      return 结果();
    }
    private function 转为整型(数据:ByteArray):int {
      var 值:int = 0;
      for(var i:int = 数据.length - 1; i > -1; i--) {
        值 += (数据[i] as int) << (数据.length - 1 - i);
      }
      return 值;
    }
  }
}