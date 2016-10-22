# 小猴偷米iOS客户端开发文档
Project Development Manual for Herald_iOS

## 目录
- 项目简介
- 环境配置、基本要求
- Xcode部署目标（Deploy Target）说明
- iOS App调试说明
- iOS App发布说明
- 项目目录结构
- 项目底层框架介绍
- 开发规范

---

## 项目简介
- 本项目是小猴偷米App的iOS客户端。在满足东南大学在校用户基本需求、保持应用不臃肿的前提下，本项目应当尽可能发掘用户的兴趣，开发一系列适应时代潮流、受用户欢迎的新功能；
- 本项目的另一个目的是培养出优秀的iOS开发者，在这个拥有上万用户的大项目中，锻炼大家自身的职业素养；
- 本项目目前主要使用Swift 2.2编写，后期将根据各个依赖包的更新进度，逐步迁移至Swift 3。项目使用git版本控制系统，cocoapods包管理器；
- 本项目与Herald_Android项目保持高度同步，要求文件结构保持相同，非UI部分的代码逻辑尽量一致，多使用可以与Java语言互通的特性，少使用不能转译成Java的特性；
- 本项目应当同时支持iPhone和iPad。

---

## 环境配置、基本要求
### 软硬件、知识要求
- 需要拥有至少一台iOS设备以便调试；
- 系统要求macOS Yosemite或更高，需要安装Xcode 7.3版本。
- 需要掌握Swift 2和iOS开发的知识，有一定的项目开发经验；
- 需要熟悉git的基本操作。

### 环境配置
- 在 https://cocoapods.org/app 下载cocoapods图形化工具；
- 打开Xcode，选择Checkout an existing project，输入项目的git仓库地址，选择dev-main分支进行拉取。

---

## Xcode部署目标（Deploy Target）说明
- iOS设备有多种CPU架构，对于每一种架构，Xcode都需要编译一种二进制文件；
- 部署目标指定了编译后的后续操作，它分为真机、发布目标、模拟器三种。可在Xcode标题栏左侧项目名右边的按钮中选择；
- 真机是连接在电脑上的实体iOS设备，可以用来调试。选择真机时，Xcode将只为该设备的CPU架构编译二进制文件，并发送到设备上进行调试；
- 发布目标即Generic iOS Device，专用于应用打包发布。选择发布目标时，Xcode将为所有可能的CPU架构编译二进制文件，并引导开发者进行发布操作；
- 模拟器是Xcode自带的虚拟设备，可以用来调试。选择模拟器时，Xcode将只为该种模拟器的CPU架构编译二进制文件，然后自动启动模拟器，并将二进制发送到模拟器上进行调试。

---

## iOS App调试说明
- Bundle id（Bundle Identifier）是应用的唯一标识符，可以随时在项目属性中修改。在开发和调试中，Bundle id需要遵循如下规则：
0. 无论模拟器还是真机，两个应用的Bundle id若相同则覆盖，不同则可以共存；
1. 模拟器调试可以直接使用，不受下列限制；
2. 真机调试时，需要在项目属性-General中取一个自己的Bundle id，不能使用发布时的id，也不能跟别人真机调试用的id重复；
3. 刚修改完Bundle id时，会弹出窗口提示证书错误，点Fix issue选择自己的Apple ID即可自动修复证书；
4. iOS 9以上设备在安装调试包时，需要保证网络连接畅通。
5. iOS 9以上设备在首次安装调试包时，需要在设置-通用-设备管理中信任该应用。

---

## iOS App发布说明
- 十分复杂，有发布权限的人请自己探索或询问前人。

---

## 项目目录结构（Xcode中显示的目录结构）
`Main.storyboard`：应用的所有界面设计
`LaunchScreen.storyboard`：静态的启动界面
`AppDelegate.swift`：应用总代理
`Info.plist`：项目属性
`Herald_iOS-Bridging-Header.h`：OC库用的Bridging Header
`Assets.xcassets`：项目图片资源

`app_main`：应用主体框架和主界面的内容
`app_secondary`：不属于任何模块也不属于主界面的内容
`app_module`：各模块的内容
`const`：保存一些常量，例如模块列表、缓存列表等
`custom`：一些不属于框架范畴的自定义控件和自定义类
`factory`：工厂模式，目前是各种首页卡片的工厂类
`framework`：属于框架范畴的一些基础类
`helper`：属于框架范畴的一些工具类

---

## 项目底层框架介绍
- 代码是自解释的，不应当在文档中写这些。请到代码中看注释。

---

## 开发规范
- 待更新。