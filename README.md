# BaiduMap-ShowMap
百度地图定位，地图展示功能、大头针，多个大头针及气泡title展示。

#为了维护宇宙的和平，又鉴于网上资料的不详细，更为了防止世界被破坏，本文讲详细讲解一个百度的集成方案，保证实用。
>简介：百度地图的定位以及地图显示功能集成。手动集成的方法此处不作介绍了，我用的是pod方法集成的。
- 1. 项目集成百度sdk。在你的Podfile文件中，导入百度sdk：（导入后会有很多ios9以后的第三方警告问题，如下解决,若还有未解决的警告可以进去到警告页面找到相应位置，）
platform :ios, '8.0'
inhibit_all_warnings!   ##忽略警告⚠️
target '你的项目名’ do
- 2.环境配置：（a. ）plist文件配置如下图，4项，第一项未网络https配置：

                (b.)

![展示图](https://github.com/diankuanghuolong/BaiduMap-ShowMap/blob/master/showImages/地图.gif)


