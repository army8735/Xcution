Xcution
=======

一款基于Adobe AIR的客户端http代理调试工具，类似跨平台的Fillder。

Xcution取自漫画《死神Bleach》中初代代理死神银城空吾的组织名。

![preview](https://raw.githubusercontent.com/army8735/Xcution/master/snapshot.png)

bin目录下为二进制安装包，目前有exe和dmg。运行前确保安装了Adobe AIR运行时：
http://get.adobe.com/cn/air/

Xcution会遍历机器上的所有网卡接口，并以列表形式展现让你选择，优先选择非127.0.0.1的地址。端口号可自定配置义，不填或0为随机。

添加规则可添加拦截URI规则，有三种方式：
* 单个文件
  * 绝对的URI路径映射到本地单个文件
* 文件路径
  * 匹配前段路径相同映射到本地文件夹
* 自定义正则
  * 自定义规则

设置若干个规则后可以点击其左侧启用或禁用按钮。规则优先按上下顺序。

开启服务器后，建议手动设置浏览器http代理到右下角显示的地址上。自动切换代理会有延迟，但好处是免去手工设定；可以重启浏览器来避免延迟。

https代理研究中，需要帮助……

捐赠:

![preview](https://raw.githubusercontent.com/army8735/Xcution/master/contribute.png)