//
//  RNMapViewManager.m
//  RNAmbaidumap
//
//  Created by liudunjian on 2018/9/14.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "RNMapViewManager.h"

@interface RNMapViewManager ()<BMKMapViewDelegate>

@end

@implementation RNMapViewManager

RCT_EXPORT_MODULE(RNMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, int)
RCT_EXPORT_VIEW_PROPERTY(zoom, float)
RCT_EXPORT_VIEW_PROPERTY(showsUserLocation, BOOL)

RCT_EXPORT_VIEW_PROPERTY(trafficEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(baiduHeatMapEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(marker, NSDictionary*)
RCT_EXPORT_VIEW_PROPERTY(markers, NSArray*)
RCT_EXPORT_VIEW_PROPERTY(poiKeywords, NSArray<NSString*>*)

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(center, CLLocationCoordinate2D, RNMapView) {
    [view setCenterCoordinate:json ? [RCTConvert CLLocationCoordinate2D:json] : defaultView.centerCoordinate];
}

+(void)initSDK:(NSString*)key {
    
    BMKMapManager* _mapManager = [[BMKMapManager alloc]init];
    /**
     百度地图SDK所有API均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
     默认是BD09（BMK_COORDTYPE_BD09LL）坐标.
     如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
     */
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }
    
    BOOL ret = [_mapManager start:key  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }else {
        NSLog(@"manager start success!");
    }
}

- (UIView *)view {
    RNMapView* _mapView = [[RNMapView alloc] init];
    _mapView.delegate = self;
    return _mapView;
}

#pragma mark - BMKMapViewDelegate

-(void)mapview:(BMKMapView *)mapView
 onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onDoubleClick");
    NSDictionary* event = @{
                            @"type": @"onMapDoubleClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapView:(BMKMapView *)mapView
onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onClickedMapBlank");
    NSDictionary* event = @{
                            @"type": @"onMapClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    NSDictionary* event = @{
                            @"type": @"onMapLoaded",
                            @"params": @{}
                            };
    RNMapView *rnMap = mapView;
    [self sendEvent:rnMap params:event];
    
    if(rnMap.showsUserLocation)
        [rnMap startUpdatingLocation];
}

-(void)mapView:(BMKMapView *)mapView
didSelectAnnotationView:(BMKAnnotationView *)view {
    NSLog(@"subtitle:%@",[view annotation].subtitle);
    NSLog(@"title:%@",[view annotation].title);
    
    NSData *data = [[view annotation].subtitle dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary* event = @{
                            @"type": @"onMarkerClick",
                            @"params": params
                            };
    [self sendEvent:mapView params:event];
}

- (void) mapView:(BMKMapView *)mapView
 onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSLog(@"onClickedMapPoi");
    NSDictionary* event = @{
                            @"type": @"onMapPoiClick",
                            @"params": @{
                                    @"name": mapPoi.text,
                                    @"uid": mapPoi.uid,
                                    @"latitude": @(mapPoi.pt.latitude),
                                    @"longitude": @(mapPoi.pt.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;
        
        UIView *popView = [[UIView alloc]init];
        popView.backgroundColor = [UIColor whiteColor];
        [popView setAutoresizesSubviews:true];

        UILabel *title = [[UILabel alloc]init];//initWithFrame:CGRectMake(0, 3, 100, 30)];
        title.backgroundColor = [UIColor whiteColor];
        title.center = popView.center;
        title.numberOfLines = 2;
        title.text = annotation.title;
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = [UIColor blueColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.layoutMargins = UIEdgeInsetsMake(50, 50, 50, 50);
        CGSize lblSize = [title.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
        
        title.frame = CGRectMake(0,3, lblSize.width, lblSize.height);

    
        [popView addSubview:title];
        
        
        BMKActionPaopaoView *paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:popView];
        
        paopaoView.frame = CGRectMake(0, 0, 100, 60);
        newAnnotationView.paopaoView = nil;
        newAnnotationView.paopaoView = paopaoView;
        return newAnnotationView;
    }
    return nil;
}

-(void)mapStatusDidChanged: (BMKMapView *)mapView     {
    NSLog(@"mapStatusDidChanged");
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChange",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @"",
                                    @"overlook": @""
                                    }
                            };
  // [self sendEvent:mapView params:event];
}

-(void)sendEvent:(RNMapView *) mapView params:(NSDictionary *) params {
    NSLog(@"sendEvent:%@",params);
    if (!mapView.onChange) {
        return;
    }
    mapView.onChange(params);
}

@end
