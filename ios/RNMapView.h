//
//  RNMapView.h
//  RNAmbaidumap
//
//  Created by liudunjian on 2018/9/14.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <React/RCTConvert+CoreLocation.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <UIKit/UIKit.h>
#import "RNLocManager.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface RNMapView : BMKMapView

@property (nonatomic, copy) RCTBubblingEventBlock onChange; //调用native端对应的属性。

-(void)setZoom:(float)zoom;
-(void)setCenterLatLng:(NSDictionary *)LatLngObj;
-(void)setMarker:(NSDictionary *)Options;
-(void) startUpdatingLocation;

@end
