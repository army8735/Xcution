package me.army8735.xcution.http
{
  import com.hurlant.crypto.prng.Random;
  
  import flash.net.Socket;
  import flash.utils.ByteArray;

  public class SSLConnect
  {
    private var 请求:HttpsRequest;
    private var 客户端:Socket;
    private var 状态:int;
    
    public function SSLConnect(请求:HttpsRequest, 客户端:Socket)
    {
      this.请求 = 请求;
      this.客户端 = 客户端;
      状态 = 0;
    }
    public function 解析(记录:ByteArray, 套接字:Socket):void {
      var 结果:ByteArray = new ByteArray();
      var 内容类型:int = 记录.readUnsignedByte();
      if(内容类型 != 22) {
        trace("非握手协议类型：", 内容类型, 客户端.remoteAddress + ":" + 客户端.remotePort);
        客户端.close();
        客户端 = null;
        return;
      }
      trace(客户端.remoteAddress + ":" + 客户端.remotePort);
      var 主版本:int = 记录.readByte();
      var 次版本:int = 记录.readByte();
      var 压缩长度:int = 记录.readShort();
      var 明文:ByteArray = new ByteArray();
      记录.readBytes(明文, 0, 压缩长度);
      var MAC:ByteArray = new ByteArray();
      记录.readBytes(明文, 0);
      trace("类型", 内容类型, "主版本", 主版本, "次版本", 次版本, "长度", 压缩长度, "MAC", MAC.length, "明文长", 明文.length);
      解析报文(明文, 套接字);
//      var 返回报文:ByteArray = 解析报文(明文, 套接字);
//      结果.writeByte(22);
//      结果.writeByte(3);
//      结果.writeByte(0);
//      结果.writeByte(返回协议报文.length);
//      结果.writeBytes(返回报文);
//      return 结果;
    }
    private function 解析报文(明文:ByteArray, 套接字:Socket):ByteArray {
      var 类型:int = 明文.readByte();
      var 长度:ByteArray = new ByteArray();
      明文.readBytes(长度, 0, 3);
      var 长度值:int = 转为整型(长度);
      var 内容:ByteArray = new ByteArray();
      明文.readBytes(内容);
      trace("类型", 类型, "标长", 长度值, "内容长", 内容.length);
      var 结果:ByteArray = new ByteArray();
      switch(类型) {
        case 1:
          var 返回你好:ByteArray = 你好报文(内容);
          结果.writeByte(2);
          结果.writeBytes(转为字节(返回你好.length));
          结果.writeBytes(返回你好);
          var 返回长:int = 结果.length;
          结果.position = 0;
          结果.writeByte(22);
          结果.writeByte(3);
          结果.writeByte(0);
          结果.writeShort(返回长);
          if(客户端 && 客户端.connected) {
            客户端.writeBytes(结果);
            客户端.flush();
            发送证书(客户端);
          }
          break;
      }
      return 结果;
    }
    private function 你好报文(内容:ByteArray):ByteArray {
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
      trace("主版本", 主版本, "次版本", 次版本, "随机数长", 随机数.length, "会话标长", 会话长, "会话长", 会话.length);
      var 密钥套件列表:Array = [];
      var 密钥套件长:uint = 内容.readUnsignedShort();
      for(var 索引:int = 0; 索引 < 密钥套件长 / 2; 索引++) {
        密钥套件列表.push(内容.readUnsignedShort());
      }
      trace("密钥标长", 密钥套件长, "密钥列表", 密钥套件列表.join(','));
      var 压缩算法列表:Array = [];
      var 压缩算法长:uint = 内容.readUnsignedByte();
      for(索引 = 0; 索引 < 压缩算法长; 索引++) {
        压缩算法列表.push(内容.readByte());
      }
      trace("压缩算法标长", 压缩算法长, "压缩算法列表", 压缩算法列表.join(','));
      trace("扩展内容长", 内容.bytesAvailable);
      结果.writeByte(3);
      结果.writeByte(0);
      var 随机数生成器:Random = new Random();
      var 返回随机数:ByteArray = new ByteArray();
      随机数生成器.nextBytes(返回随机数, 32);
      结果.writeBytes(返回随机数);
      结果.writeByte(32);
      随机数生成器.nextBytes(结果, 32);
      结果.writeShort(4);
      结果.writeByte(0);
      return 结果;
    }
    private function 转为整型(数据:ByteArray):int {
      var 值:int = 0;
      for(var i:int = 数据.length - 1; i > -1; i--) {
        值 += (数据[i] as int) << (数据.length - 1 - i);
      }
      return 值;
    }
    private function 转为字节(数据:uint, 长度:int = 0):ByteArray {
      var 值:ByteArray = new ByteArray();
      值.writeUnsignedInt(数据);
      if(长度 > 0) {
        var 返回:ByteArray = new ByteArray();
        返回.writeBytes(值, 32 - 长度);
        return 返回;
      }
      return 值;
    }
    private function 发送证书(客户端:Socket):void {
      
    }
  }
}