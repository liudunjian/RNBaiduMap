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


/**
    - (BOOL)requestLocationWithReGeocode:(BOOL)withReGeocode withNetworkState:(BOOL)withNetWorkState completionBlock:(BMKLocatingCompletionBlock _Nonnull)completionBlock;
 *  @brief 单次定位。如果当前正在连续定位，调用此方法将会失败，返回NO。\n该方法将会根据设定的 desiredAccuracy 去获取定位信息。如果获取的定位信息精确度低于 desiredAccuracy ，将会持续的等待定位信息，直到超时后通过completionBlock返回精度最高的定位信息。\n可以通过 stopUpdatingLocation 方法去取消正在进行的单次定位请求。
 *  @param withReGeocode 是否带有逆地理信息(获取逆地理信息需要联网)
 *  @param withNetWorkState 是否带有移动热点识别状态(需要联网)
 *  @param completionBlock 单次定位完成后的Block
 *  @return 是否成功添加单次定位Request
 */
RCT_EXPORT_METHOD(requestLocationWithReGeocode) {
    BMKLocationManager* locationManager = [[BMKLocationManager alloc]init];
    //设置返回位置的坐标系类型
    locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    //设置距离过滤参数
    locationManager.distanceFilter = kCLDistanceFilterNone;
    //设置预期精度参数
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置应用位置类型
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    //设置是否自动停止位置更新
    locationManager.pausesLocationUpdatesAutomatically = NO;
    //设置是否允许后台定位
   // _locationManager.allowsBackgroundLocationUpdates = YES;
    //设置位置获取超时时间
    locationManager.locationTimeout = 10;
    //设置获取地址信息超时时间
    locationManager.reGeocodeTimeout = 10;
    locationManager.delegate  = self;
    
    bool ret =  [locationManager requestLocationWithReGeocode:YES withNetworkState:NO completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
        }
        if (location)
        {//得到定位信息
            [self locationEventReminderReceived:location];
        }
        NSLog(@"netstate = %d",state);
    }];
    NSLog(@"-----:%d",ret);
}

/**
 *  @brief 开始连续定位。调用此方法会cancel掉所有的单次定位请求。
 */
RCT_EXPORT_METHOD(startUpdatingLocation:(id<BMKLocationManagerDelegate>) delegate)
{
    //设置delegate
    if(delegate==nil) {
        self.locationManager.delegate = self;
    }else{
        self.locationManager.delegate = delegate;
    }
}

/**
 *  @brief 关闭连续定位或者其他单次定位。
 */
RCT_EXPORT_METHOD(stopAllLocation)
{
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}


//线程相关
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

//事件发送器
- (NSArray<NSString *> *)supportedEvents
{
    return @[@"LocEventReminder"];
}

//授权定位
+ (void) initSDK:(NSString*) key {
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:key authDelegate:self];
}

- (void)locationEventReminderReceived:(BMKLocation *)location
{
    NSLog(@"district:%@",location.rgcData.district);
    NSDictionary<NSString *, id> * locationEvent = @{
                           @"location": @{
                                   @"latitude": @(location.location.coordinate.latitude),
                                   @"longitude": @(location.location.coordinate.longitude),
                                   @"altitude": @(location.location.altitude),
                                   @"accuracy": @(location.location.horizontalAccuracy),
                                   @"altitudeAccuracy": @(location.location.verticalAccuracy),
                                   @"heading": @(location.location.course),
                                   @"speed": @(location.location.speed)
                                   },
                           @"address": @{
                                   @"country": location.rgcData.country,
                                   @"province": location.rgcData.province,
                                   @"city": location.rgcData.city,
                                   //@"district": location.rgcData.district,
                                   //@"street": location.rgcData.street,
                                   //@"streetNumber": location.rgcData.streetNumber,
                                   // @"locationDescribe": location.rgcData.locationDescribe
                                   }
                           };
    
    [self sendEventWithName:@"LocEventReminder" body:locationEvent];
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
    [self locationEventReminderReceived:location];
}

- (BMKLocationManager*)locationManager {
    //初始化实例
    if(_locationManager == nil) {
        _locationManager  = [[BMKLocationManager alloc] init];
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
    return _locationManager;
}


@end
