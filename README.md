
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
  