
# react-native-ambaidumap

## Getting started

`$ npm install react-native-ambaidumap --save`

### Mostly automatic installation

`$ react-native link react-native-ambaidumap`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-ambaidumap` and add `RNAmbaidumap.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNAmbaidumap.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

5. 搭建React Native 百度地图：
A. 在一个文件夹project下，输入命令:       $ react-native-create-library --package-identifier com.qd.almo.baidumap --platforms android,ios baidumap

    重命名baiduMap     $ mv baidumap react-native-baidumap
B.  创建demo
    $ cd project
    $ react-native init demo

C.  安装本地module到自己的project    
    方法一
        $ cd react-native-baidumap 
        $ yarn link
        $ cd demo
        $ yarn link react-native-baidumap
        $ react-native link react-native-baidumap

    这种方法在react-native 工程中无法引用react-native-baidumap这个module。只能通过native暴露出来的module进行工作。
    方法二
    在工程的package.json里面直接添加dependencied，如
        ……
        “react-native-ambaidumap":"file:../react-native-ambaidumap"
        ……
    然后运行yarn install，这种方法可以直接在工程中使用目标module

D.  在React native中调用原生，首先引入NativeModules，然后定义全局变量
            var rnBaiduMap = NativeModules.RNBaidumap;
     调用原生export的方法：
            rnBaiduMap.sendEvent(“你好”,”almo”)；

E. 在生成的react-native-baidumap里的ios目录下新建文件夹lib，将百度SDK复制过来后（各种framework文件和thirdlibs整个文件），需要打开该module，
    配置Framework Search Path:
        1. $(PROJECT_DIR)/lib           
        2. $(inherited)
配置Header Search Path:   
        1. $(inherited)
        2. /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
        3. $(SRCROOT)/../../../React
        4. $(SRCROOT)/../../react-native/React
配置Library Search Path:
        $(SRCROOT)/../../react-native/React
        $(inherited)

F.  在新建的工程中引入该Module后，需要进行配置。
配置Framework Search Path:
    $(PROJECT_DIR)/../../react-native-ambaidumap/ios/lib 即为创建的Module中framework库。
配置Header Search Path:   
    1. $(inherited)
    2. $(SRCROOT)/../node_modules/react-native-ambaidumap/ios 即为创建的Module中编写的native代码路径。

配置Library Search Path:
    $(PROJECT_DIR)/../../react-native-ambaidumap/ios/lib/thirdlibs 即为创建的Module中引入的a类型的库。

G. 在新建工程中的Build Phases中Link你的所有framework库和a类型库。目前在创建的module中无法进行配置相应的framework库和a类型库，后续继续研究。

以上都是本地开发使用的步骤，当publish后也许稍有不同。


#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.qd.almo.baidumap.RNAmbaidumapPackage;` to the imports at the top of the file
  - Add `new RNAmbaidumapPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-ambaidumap'
  	project(':react-native-ambaidumap').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-ambaidumap/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-ambaidumap')
  	```


## Usage
```javascript
import RNAmbaidumap from 'react-native-ambaidumap';

// TODO: What to do with the module?
RNAmbaidumap;
```
  
