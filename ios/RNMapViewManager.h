//
//  RNMapViewManager.h
//  RNAmbaidumap
//
//  Created by liudunjian on 2018/9/14.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNMapView.h"



@interface RNMapViewManager : RCTViewManager<BMKMapViewDelegate>

+(void)initSDK:(NSString *)key;

-(void)sendEvent:(RNMapView *) mapView params:(NSDictionary *) params;

@end
