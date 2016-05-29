##手把手教你制作一款iOS越狱App，伪装微信位置

[TOC]

### 说明
####缘由
本文是我个人在对逆向工程强烈的兴趣驱使下，拜读《iOS应用逆向工程》，所实现的一个好玩的功能，与大家分享，也是对自己学习的一个简单总结。BTW iOS逆向论坛 [iOSRe](http://bbs.iosre.com/) 是一个很好的iOS逆向交流社区。

本示例所有代码以及工具都已托管GitHub 请查看 [https://github.com/jackrex/FakeWeChatLoc](https://github.com/jackrex/FakeWeChatLoc)

####严重声明

**本文所有纯属个人娱乐学习值用,相关技术仅用于学习交流，请勿用于非法目的，不得有其他任何商业用途！！！**

### 概念
####越狱的原理：
iOS系统越狱，其实说白了，和Android的Root类似，相当于对手机权限的提升，使得让你可以操纵之前你操纵不了的事物。

由于Objective-C 是面向对象的高级语言，iOS 采用的文件格式 Mach-O 包含了很多metadata 信息可以让我们使用 class-dump 还原其头文件，这个为iOS 的逆向有了很好的开端。

MobileSubstrate 是一个能够让iOS 开发方便hook的一个framework，MobileSubstrate由如下三部分组成：
> MobileSubstrate  
1.  MobileHooker 利用iOS Runtime  动态替换函数，转发消息达到所谓的hook技术
2. MobileLoader 主要用来加载第三方动态库 即是tweak/*.dylib
3. Safe Mode 安全模式，防止第三方插件的Crash对主体App造成的影响

-   由此可见 有了MobileSubstrate 作为基石，加上逆向工程，我们几乎可以完成我们想做的任何事情

####iOS 目录层级结构

![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463232711046.png)
这种基于Unix 衍生的操作系统一般目录层级都有相通之初，不妨可以对比Android 以及 MacOS，会发现好多目录名是一致的，我么来挑一些简单讲解下：
```
/bin binnary ，系统常用的基本二进制文件 例如 cd, ls, ps 等
/usr 包含大多用户工具库
/var variable 存放经常更改的东西，例如 logs，用户数据，/var/mobile/Applications 是纺织AppStore 下载的 App
/Applications 存放所有系统App，以及从Cydia下载的App路径
/Library  存放了系统App的数据，其中有一个/Library/MobileSubstrate 目录，MobileSubstrate 是一个hook 功能开发平台，其中内容如下图所示，我们所开发的插件都被放置到这个里面
/Library/MobileSubstrate 里面文件类型主要有 dylib，plist
dylib 是动态加载库，就是tweak
plist 配合dylib 使用的filter 文件，指定注入目标，及hook的目标
/System 存放iOS 各种系统framework
/User 指向 /var/mobile 即是我们一般用户的主目录 
```
#### iOS 程序类型
- iOS 安装包格式
1. ipa 苹果推出的iOS 专有安装包，一般从AppStore下载的包格式，安装路径/var/mobile/Applications，长按可删除
2. deb 是属于Debain系(使用过debain linux 系统的都知道)特有的安装包，iOS 系统起源于Unix，所以兼容deb安装包，Cydia下载的App就是deb格式的，安装路径为到 /Applications ，长按不可删除，必须使用root 权限的命令行或者Cydia移除
3. __pxl__ （~~这种格式起源于Mac上的pkg，现在已经废弃~~原本是91手机助手自己创建的基于zip封装的格式，该格式所有的app都作为root安装，好不优雅）

- iOS 安装包对比
**其实各大软件包虽然格式不一样，诸如 .apk, .ipa .deb .app 等等，其实实质都是一个zip 将二进制和资源文件合理的规划罗列出来**
1. 包内容对比：
 ![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463271536818.png)
 Payload文件夹:里面包含了app使用的图片以及二进制文件等
 iTunesArtwork:实际上是无后缀的png图片，在iTunes等上显示用
 iTunesMetadata.plist记录购买者的信息，软件版本，售价等
 com.apple.ZipMetadata.plist 是
 
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463271594174.png)
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463272025376.png)

Deb 结构其实是对Library Applications gzip 为 data.tar.gz里面
control 文件放到 control.tar.gz 中

2. 权限： deb 安装到/Applications 下属于 root 用户组，所以可以读写权限和 一般的 .ipa mobile 用户不一样
3. Deb 文件的安装方式就例如把本身自己文件路径完全拷贝到iOS 系统中，当control包中有postinst等脚本时按照规则执行脚本


- 其他iOS程序类型
1. Dynamic Library
我们上面说的DynamicLibraries 就是MobileSubstrate放置动态库的地方，该目录下的会被ms自动选择性加载
2. Daemon
这个是后台运行程序，守护进程的程序，例如一直监听通话来电的进程 等等，这个就不多讲了。

### 准备工作
#### 硬件设备：
-  Mac
-  已越狱的iDevice
####辅助软件 : 
- [iOSOpenDev](http://iosopendev.com/)
- [TheOS](http://iphonedevwiki.net/index.php/Theos/Setup)

####Mac 需要的工具
在逆向工程中常见的 动态调试和静态分析使用的工具:
- [class-dump](https://www.github.com/nygard/class-dump)
> class-dump  用来dump 出越狱后的App 所有头文件的工具

- IDA
>IDA 是最好的反编译工具，其实简单的逆向只用IDA就可以完全搞定了

- Hopper
>OS X下可以使用授权费用低廉的[Hopper Disassembler](https://www.hopperapp.com)

- LLDB
> 动态调试的利器 配合 IDA 一动一静

- [Reveal](https://www.hopperapp.com)
> 一个方便UI调试定位的Debug的工具，我们可以快速的对应某个App界面对应的是某个类

- iFunBox
> 方便的文件管理辅助软件


#####iOS 需要使用的辅助开发工具
- OpenSSH
> OpenSSH 可以让你的电脑远程登录你的手机

- Cycript
> 非常强大的工具，可以让开发者在命令行下和应用交互，在运行时查看和修改应用

- iFile
>  一个在手机方便管理文件系统的软件，犹如iFunbox ，Android 的Re管理器，可以方便的修改文件 安装Deb二进制文件

- APPSync 
> APPsync是iPhone、iPad、iPod touch越狱后最常安装的补丁，安装后可以绕过系统签名验证，随意安装、运行破解的ipa软件。


### 逆向过程

#### 静态分析
根据上述所理解的情况，由于我们是想在微信中模拟定位，所以我们把微信作为我们的分析对象。
使用 [class-dump](https://github.com/nygard/class-dump) 导出微信的头文件, 虽然我们在class-dump 官网上看到 直接导出的方式 class-dump -H xxx -o output/ 但是我们直接解压ipa 中的wechat 里面 去dump 是不行，我们会发现在output 文件夹里只有 CDStructures.h文件，而且是空的
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463304272242.png)

这个原因是因为在上传AppStore 之后，AppStore自动给所有的ipa 进行了加密处理，所以我们要dump之前需要对微信的二进制文件进行砸壳处理

##### 给App砸壳
我们首先应当尝试更加方便的[Clutch](https://github.com/KJCracks/Clutch)

当Clutch失败时，尝试如下步骤
我们需要一个dumpdecrypted.dylib 这样一个工具对我们的App 砸壳
我们 先ssh 到我们的iOS手机上，我们把所有的程序都结束掉，单单开微信一个然后执行
``` powershell
ps -e //列出当前运行的进程
```
TODO
可以看到以/var/mobile/Containers/ 开头列出的进程就是WeChat进程，我们知道所有App的的沙盒路径在 /var/mobile/Containers/Bundle/Application/03B61840-2349-4559-B28E-0E2C6541F879/ 中，但是我们并不知道 **03B61840-2349-4559-B28E-0E2C6541F879** 到底是哪一个App ，如果我们去目录中一个一个找的话，就太不容易了

这时候 cycript 就派上用处了，执行 
```
 cycript -p WeChat 
 cy# [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]
#"file:///var/mobile/Containers/Data/Application/D41C4343-63AA-4BFF-904B-2146128611EE/Documents/"
```

这样我们就得到了微信Documents 目录，接下来使用scp 或者 ifunbox 吧拷贝到微信的Documents目录下 dumpdecrypted.dylib 

开始砸壳
```
DYLD_INSERT_LIBRARIES=/path/to/dumpdecrypted.dylib /path/to/executable
```
当前目录下会生成WeChat.decrypted
这个就是砸过壳的WeChat，我们可以对它进行dump
dump 之前我们可以用otool 工具看下Match-o的文件信息

otool -H WeChat.decrypted

使用otool -l WeChat.decrypted寻找cryptid，使用lipo拆分出解密的架构

执行
```
./class-dump -H WeChat.decrypted --arch armv7  -o output/
```
在当前目录下生成一个Output文件夹里面具有微信导出所有的头文件，包括第三方sdk等，我们把这些所有头文件放到一个空的Xcode 工程中方便查看。

![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463308416430.png)

我们根据直觉发现 Appdelegate 是微信的MircoMessengerAppDelegate，可以大概看到微信的项目结构等，其实逆向也是学习的一种方式

接着我们来想想我们要实现的功能，我们要改变我们的位置从而改变附近的人，我们大致可以猜想这个类应该交 Nearby Location 之类的，我们可以搜索对应的头文件。

我们发现搜Nearby 之后有这么多，到底哪一个是呢
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463308602134.png)

其实我们除了排除法和一个一个推测之外，我们可以使用Reveal 这个强大的工具帮我们定位

##### 使用IDA静态分析
可以说class-dump 帮我们列出了整个header 文件，让我们对项目的整体结构有了一个大概的认识，但是对应具体.m 中的实现方案是哪一种，对于我们来说还是黑盒。这个时候我们就需要使用IDA强大的工具 进行分析。

打开IDA，选择new
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463309017324.png)

我们把从Wechat.app 里面的WeChat 二进制拿出来，拖到上面IDA中，
由于我使用的是itouch 5 cpu 架构是armv7 所有用第一个，如果用错的话，则打断点得到的offset 是错误的，从而不能正常的debg
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463309168962.png)

处理完成后如下图所示
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464188771235.png)


其中我们可以轻易的看到 MicroMessengerAppDelegate 里面具体方法的实现，按空格键展开到视图模式
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464188817891.png)

这里我们就可以看到.m中的实现了

#### 动态调试
动态调试是我们没有源码的情况下，使用lldb 对代码的位置设断点进行调试，主要是算得相应代码的执行地址，以及如何Debug 获取我们想要的值。更具上述所说我们使用IDA的反编译结果

1.  iOS 开启debugserver 监听1234端口
debugserver *:1234 -a "WeChat"

2. Mac端运行lldb 和iOS server保持连接
运行 lldb
process connect connect://iOSIP:1234

![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464189237752.png)


3. 获取ASLR的offset 
image list -o -f
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464189320392.png)

offset 是 0xd000

4. 获取断点地址 
br s -a 0xd000+0x649D8 // 下断点

5. 开始调试
ni po 等调试命令

直接启动一个App ：debugserver -x backboard *:1234 /path/to/app/executable


### iOS 工程目录
libsubstrate.dylib



### 制作Tweak
#### Tweak 是什么
Tweak 在单词中的意思是"微调"的意思，其实就是第三方动态链接库dylib
Tweak 是基于MobileSubstrate 编写的，可以在运行时更改hook的App

#### 了解 Theos
[Theos](http://iphonedevwiki.net/index.php/Theos/Getting_Started) 是一个越狱开发工具包，在《iOS应用逆向工程书中》也是介绍了这种方式，但是我个人更喜欢使用iOSOpenDev 的方式去创建项目(ps: 就和熟悉了git 命令行之后觉得用sourceTree 更直观)，所以这里简单提及一下，感觉iOSOpenDev 像是把命令行式的NIC模板变成了可视化的，其实差不多都没有多难。

####安装iOSOpenDev
1. 安装很简单，大家下载 [installer ](http://iosopendev.com/download/) 进行安装
2. 安装完成后，创建新项目会在template 中iOS出现 iOSOpenDev 
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463269166273.png)

3. 在这里我们选择Logos Tweak，创建完成如下
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463273711206.png)

其中有一个fakeloc.xm 的文件，这个就是我们要进行代码编写的地方。打开fakeloc.xm文件我们可以看到里面的代码使用 logos 完成的，对于logos 这种新的一门语言，大家不用担心，其基本的语法和Objc类似，有几个特定的语法需要特别注意下：

> Logos 基本语法 :
%hook  指定需要hook的类， 必须和 %end 结尾
%log 将函数信息写入syslog 进行打印信息
%orig 执行被hook住的函数，只能在 %hook 具体方法内执行

fakeloc.xm 对应的是 fakeloc.mm

我们在上述
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463303717846.png)


在build Settings 上可以看到，底下有一栏是User-Define，这里是我们自定义的部分，在 **iOSOpenDevDevice** 的地方写上我们iOS 设备的ip地址 （局域网地址 如 192.168.1.103),前提是iOS 设备安装 OpenSSH
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463303094444.png)

![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464190757164.png)
ssh 认证错误
iosod sshkey -h 192.168.1.109


### 制作App
最开始还以为创建越狱的App 都要用 Logos 语法去写，吓死宝宝了，其实iOS 越狱App的开发几乎和正常App 一模一样

首先我们还是创建一个工程，和普通创建工程一样，也可以用CocoaPods来管理你对于的第三方库

先创建一个新的项目和正常一样,按照[如下方法配置](https://github.com/kokoabim/iOSOpenDev/wiki/Convert-to-iOSOpenDev-Project)后更改Build Settings。

![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464223875136.png)

增加Run Script，把control 从copy bundle resources 移除
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464225043534.png)

项目整体结构 
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464225149037.png)


Build for Profiling 执行程序



### App和Tweak通信交换数据

#### App如何加载Tweak
在生成了App 和 Tweak 之后，那我们App 中如何调用Tweak 呢？
答案是采用 dlopen
```
 void *handle = dlopen(TWEAK_PATH, RTLD_LAZY); //TWEAK_PATH 是dylib 的地址
    if (handle) {
        NSLog(@"handle");
        if (0 != dlclose(handle)) {
            printf("dlclose failed! %s\n", dlerror());
        }else {

        }
    } else {
         NSLog(@"nohandle");
        printf("dlopen failed! %s\n", dlerror());
    }
```

然后动态的获取对应的自定义类
   > Class TweakBridge = NSClassFromString(@"TweakBridge");


#### App如何和Tweak 交互传输数据
这个问题最开始我也百思不得其解，最后采用了最稳定，最为简单的方法实现，就是往同一个文件中读写数据，这个文件可以作为传输数据的媒介。
但是刚开始笔者把文件放到 /var/mobile/xxx.plist， tweak 总是读取不到值，纠其原因是因为tweak 和我们的App 权限不一样，所以需要找到一个可以公共写的地方，这个地方是 **/var/mobile/Library/Preferences/ **  所以我们App 和 Tweak 信息交互采用一个写，另一个读的方式达到传输的目的，如果你有更好更直接的方法，可以提出来大家一起讨论

所以最后的代码是：
```
- (void)setLocWithLat:(double)lat andLng:(double)lng {
    NSLog(@"set lat & lng is %f &&&& %f", lat, lng);
    Class TweakBridge = NSClassFromString(@"TweakBridge");
    void *handle = dlopen(TWEAK_PATH, RTLD_LAZY);
    if (handle) {
        NSLog(@"handle");
        TweakBridge = NSClassFromString(@"TweakBridge");
        NSDictionary *dict = @{@"lat":[NSNumber numberWithDouble:lat], @"long":[NSNumber numberWithDouble:lng]};
        BOOL isSuccess = [dict writeToFile:LOCATION_PATH atomically:YES];
        NSLog(@"isSuccess, %d", isSuccess);
        CLLocation *location = [[TweakBridge shareInstance] getCoreLocation];
        if (0 != dlclose(handle)) {
            printf("dlclose failed! %s\n", dlerror());
        }else {

        }
    } else {
         NSLog(@"nohandle");
        printf("dlopen failed! %s\n", dlerror());
    }
}

```



### 打包安装

#### 整理目录结构
那我们如何将我们的Tweak 和 我们的App 结合在一起，让用户安装后就可以直接使用呢，鉴于我们上文说到的deb 格式，打包的方式和结构和zip 其实是一致的
iOS 系统可安装的包格式和结构我们在上文已经阐述过，现在是如何生成Deb 包

我们分别取出 dylib 和 app 的生成的目录
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464392205173.png)

统一都放到一个单独的Package 目录下，最后的目录结构如下图
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464392336275.png)


#### 执行打包命令
我们按照Deb 排布的目录结构把所有的文件按照下图层级排放，然后使用 dpkg-deb 方式进行打包，注意打包的时候deb 中最好不要有 .DS_Store 文件，我写了如下的脚本去去除，同时生成Deb文件

```
#!/bin/bash
find ./Package -name ".DS_Store" -depth -exec rm {} \;
dpkg-deb -Zgzip -b Package fakeLoc.deb

```
生成的安装包如下，然后我们scp 到设备中
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464392408794.png)
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464392560839.png)


我们使用iFunbox 把生成好的fakeLoc .deb 拖到根目录下，然后在手机上打开iFile，点击fakeLoc.deb  安装程序，安装完之后我们把AppSync 重新安装一遍重启手机，然后就能打开我们的App了，同时发现长按我们的App 和系统应用， Cydia 等一样，是不可以卸载的，应
为我们是安装到了/Applications 下面，卸载可以使用命令行删除，或者使用Cydia。

安装完成，之后重启设备就行
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464392859055.png)



#### 安装验证
打开App 让我们输入精度和纬度，然后执行，最后打开微信附近的人看看，是不是附近的人发生了改变，如果做的更好，精度纬度在地图上选取，当让我们的核心功能就讲解到这里为止了，我们简单的测试结果如下：

我们可以在 [地图选址器](http://lbs.qq.com/tool/getpoint/index.html) 选择不同的位置，进行测试

1. 首先我们先输入北京的坐标
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464391571144.png)
2. 然后打开微信附件的人
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464391610634.png)

可以看到大部分人都是北京的
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464391642329.png)

3. 我们在重新输入一个地址，比如广州，然后在打开微信
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464391684987.png)
![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1464391698790.png)

成功模拟了微信附近的人


### 发布App
这可不向发布到AppStore那样，首先你需要一个托管源，如果不想自己搭建则可以采用
[thebigboss.org/hosting-repository-cydia/submit-your-app](thebigboss.org/hosting-repository-cydia/submit-your-app)

![Alt text](https://raw.githubusercontent.com/jackrex/FakeWeChatLoc/master/pic/1463233458338.png)

填写相关信息，这些就不再叙述了。

### 总结
本文抛砖引玉，希望你对iOS越狱有一个初步的理解，能够完成自己的任意App，开发出更好玩的Tweak，比如微信抢红包的插件是不是就看似也不难实现了呢，本示例工程都托管在Github上，其中fakeloc 是 dylib 即tweak   TestFakeTweak是app 工程，HackAppTool 我们上述文章描述需要用的第三方工具

项目地址：https://github.com/jackrex/FakeWeChatLoc


### 常见问题
1. 安装软件后桌面没有出现软件
解决方案：
``` python
重新安装下AppSync 并重启SpringBoard
```
2. iOS6 系统Crash
解决方案：
```
由于iOS7之后引入一些新的类库等，在iOS6设备上的兼容性一般，所以在工程的framework 中把 require 改为 option
```
3. iOS 越狱后忘记了root 密码
解决方案 ：
``` python
root密码文件存放地方：/etc/master.passwd
用iFile的文本编辑功能打开master.passwd，更改之前记得权限
你会找到类似这样的一行字符——root:UlD3amElwHEpc:0:0::0:0:System
UlD3amElwHEpc就是加密过的密码
把它更替为ab3z4hnHA5WdU，这是对应的密码就是abc123。
保存，重启。
有了密码abc123你就可以进一步修改成其它的密码了
```

### 参考
1. 《iOS应用逆向工程》
2. http://iosopendev.com/
3. http://iphonedevwiki.net/
4. http://security.ios-wiki.com/
