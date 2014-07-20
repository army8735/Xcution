package me.army8735.xcution.net
{
  import com.hurlant.crypto.prng.Random;
  import com.hurlant.crypto.tls.SSLSecurityParameters;
  import com.hurlant.util.Base64;
  
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.net.Socket;
  import flash.utils.ByteArray;

  public class SSLConnect
  {
    private var 请求:HttpsRequest;
    private var 客户端:Socket;
    private var 状态:int;
    private var 记录:ByteArray;
    
    public function SSLConnect(请求:HttpsRequest, 客户端:Socket)
    {
      this.请求 = 请求;
      this.客户端 = 客户端;
      状态 = 0;
      记录 = new ByteArray();
    }
    public function 解析(记录:ByteArray):void {
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
      解析报文(明文);
    }
    private function 发送报文(类型:int, 数据:ByteArray):void {
      if(客户端 && 客户端.connected) {
        var 长度:int = 数据.length + 4;
        客户端.writeByte(22);
        客户端.writeByte(3);
        客户端.writeByte(0);
        客户端.writeShort(长度);
        
        记录.writeByte(类型);
        记录.writeBytes(转为字节(数据.length, 3));
        记录.writeBytes(数据);
        
        客户端.writeByte(类型);
        客户端.writeBytes(转为字节(数据.length, 3));
        客户端.writeBytes(数据);
        
        客户端.flush();
      }
    }
    private function 解析报文(明文:ByteArray):void {
      var 类型:int = 明文.readByte();
      var 长度:ByteArray = new ByteArray();
      明文.readBytes(长度, 0, 3);
      var 长度值:int = 转为整型(长度);
      var 内容:ByteArray = new ByteArray();
      明文.readBytes(内容);
      trace("类型", 类型, "标长", 长度值, "内容长", 内容.length);
      if(长度值 != 内容.length) {
        trace("握手包长度标识出错！");
      }
      switch(类型) {
        case 1:
          记录.writeBytes(明文, 0, 长度值 + 4);
          var 返回你好:ByteArray = 你好报文(内容);
          发送报文(2, 返回你好);
          var 证书:ByteArray = 生成证书();
          发送报文(11, 证书);
          发送报文(14, new ByteArray());
          break;
        case 20:
          结束报文(内容, 长度值);
          break;
      }
    }
    private function 你好报文(内容:ByteArray):ByteArray {
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
      var 结果:ByteArray = new ByteArray();
      结果.writeByte(3);
      结果.writeByte(0);
      var 随机数生成器:Random = new Random();
      var 返回随机数:ByteArray = new ByteArray();
      随机数生成器.nextBytes(返回随机数, 32);
      结果.writeBytes(返回随机数);
      结果.writeByte(32);
      随机数生成器.nextBytes(结果, 32);
      结果.writeShort(4); //TLS_RSA_WITH_RC4_128_MD5
      结果.writeByte(0); //无压缩
      return 结果;
    }
    private function 转为整型(数据:ByteArray):int {
      return (数据.readUnsignedByte() << 16) | 数据.readUnsignedShort();
    }
    private function 转为字节(数据:uint, 长度:int = 0):ByteArray {
      var 值:ByteArray = new ByteArray();
      值.writeUnsignedInt(数据);
      if(长度 > 0) {
        var 返回:ByteArray = new ByteArray();
        值.position = 值.length - 长度;
        值.readBytes(返回);
        return 返回;
      }
      return 值;
    }
    private function 生成证书():ByteArray {
      var 文件:File = new File(File.applicationDirectory.resolvePath("XcutionRoot.cer").nativePath);
      if(!文件.exists) {
        throw new Error('证书不存在：' + 文件.nativePath);
      }
      var 文件流:FileStream = new FileStream();
      文件流.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
        throw new Error(event.text);
      });
      文件流.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
        throw new Error(event.text);
      });
      文件流.open(文件, FileMode.READ);
      var 数据:ByteArray = new ByteArray();
      文件流.readBytes(数据);
      var 文本:String = 数据.toString();
      文本 = 文本.replace('-----BEGIN CERTIFICATE-----', '')
        .replace('-----END CERTIFICATE-----', '')
        .replace(/\s/g, '');
      var 证书:ByteArray = Base64.decodeToByteArray(文本);
      var 返回:ByteArray = new ByteArray();
      var 长度:int = 证书.length;
      var 总长度:int = 长度 + 3;
      trace("总长", 长度, "证书长", 长度);
      返回.writeBytes(转为字节(总长度, 3));
      返回.writeBytes(转为字节(长度, 3));
      返回.writeBytes(证书);
      return 返回;
    }
    private function 结束报文(内容:ByteArray, 长度:int):ByteArray {
      var 数据:ByteArray = new ByteArray();
      内容.readBytes(数据, 0, 长度);
      var 解密:SSLSecurityParameters = new SSLSecurityParameters(1);
      var 返回:ByteArray = new ByteArray();
      return 返回;
    }
  }
}