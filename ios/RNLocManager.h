//
//  RNLocManager.h
//  RNAmbaidumap
//
//  Created by liudunjian on 2018/9/17.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <React/RCTEventEmitter.h>

@interface RNLocManager : RCTEventEmitter<RCTBridgeModule>

+ (void) initSDK:(NSString*) key;

- (void) startUpdatingLocation:(id<BMKLocationManagerDelegate>) delegate;

@end
