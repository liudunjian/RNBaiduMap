//
//  RNLocManager.m
//  RNAmbaidumap
//
//  Created by liudunjian on 2018/9/17.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "RNLocManager.h"


@interface RNLocManager() <BMKLocationManagerDelegate>
    @property (nonatomic, strong) BMKLocationManager* locationManager;
@end

@implementation RNLocManager

//暴露Module
RCT_EXPORT_MODULE();

//连续定位
RCT_EXPORT_METHOD(startUpdatingLocation:(id<BMKLocationManagerDelegate>) delegate)
{
    //初始化实例
    if(_locationManager == nil) {
        _locationManager  = [[BMKLocationManager alloc] init];
    }
    //设置delegate
    if(delegate==nil) {
        _locationManager.delegate = self;
    }else{
        _locationManager.delegate = delegate;
    }
    //设置返回位置的坐标系类型
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    //设置距离过滤参数
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    //设置预期精度参数
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置应用位置类型
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    //设置是否自动停止位置更新
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    //设置是否允许后台定位
    _locationManager.allowsBackgroundLocationUpdates = YES;
    //设置位置获取超时时间
    _locationManager.locationTimeout = 10;
    //设置获取地址信息超时时间
    _locationManager.reGeocodeTimeout = 10;
    [_locationManager setLocatingWithReGeocode:YES];
    [_locationManager startUpdatingLocation];
}
//线程相关
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

//授权定位
+ (void) initSDK:(NSString*) key {
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:key authDelegate:self];
}

//定位错误时回调
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"ERROR");
}

// 定位SDK中，方向变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    NSLog(@"HEADING");
    if (!heading) {
        return;
    }
}

// 定位SDK中，位置变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    NSLog(@"LOCATION");

    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
}


@end
