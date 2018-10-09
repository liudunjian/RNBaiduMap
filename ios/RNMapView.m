//
//  RNMapView.m
//  RNAmbaidumap
//
//  Created by liudunjian on 2018/9/14.
//  Copyright © 2018年 Facebook. All rights reserved.
//longitude: 113.981718,
//latitude: 22.542449

#import "RNMapView.h"

@interface RNMapView() <BMKLocationManagerDelegate,BMKPoiSearchDelegate>
@property (nonatomic, strong) BMKUserLocation *userLocation;
@property (nonatomic,strong) BMKUserLocation *lastPoiUserLocation;
@property (retain,nonatomic,strong) NSArray<NSString *> *poiKeywords;
//@property (assign,nonatomic) NSInteger poiPageIndex;
@end

@implementation RNMapView {
    BMKPointAnnotation* _annotation;
    NSMutableArray* _annotations;
    RNLocManager* _rnLocManager;
}

-(void) startUpdatingLocation {
    if(!_rnLocManager) {
      _rnLocManager = [[RNLocManager alloc]init];
    }
    [_rnLocManager startUpdatingLocation:self]; //开始定位
}

-(void)setZoom:(float)zoom {
    NSLog(@"zoom change");
    self.zoomLevel = zoom;
}

-(void)setCenterLatLng:(NSDictionary *)LatLngObj {
    double lat = [RCTConvert double:LatLngObj[@"lat"]];
    double lng = [RCTConvert double:LatLngObj[@"lng"]];
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(lat, lng);
    self.centerCoordinate = point;
}

-(void)setMarker:(NSDictionary *)option {
    NSLog(@"setMarker");
    if(option != nil) {
        if(_annotation == nil) {
            _annotation = [[BMKPointAnnotation alloc]init];
            [self addMarker:_annotation option:option];
        }else {
            [self updateMarker:_annotation option:option];
        }
    }
}

-(void)setMarkers:(NSArray *)markers {
    int markersCount = [markers count];
    if(_annotations == nil) {
        _annotations = [[NSMutableArray alloc] init];
    }
    if(markers != nil) {
        for (int i = 0; i < markersCount; i++)  {
            NSDictionary *option = [markers objectAtIndex:i];
            BMKPointAnnotation *annotation = nil;
            if(i < [_annotations count]) {
                annotation = [_annotations objectAtIndex:i];
            }
            if(annotation == nil) {
                annotation = [[BMKPointAnnotation alloc]init];
                [self addMarker:annotation option:option];
                [_annotations addObject:annotation];
            } else {
                [self updateMarker:annotation option:option];
            }
        }
        
        int _annotationsCount = [_annotations count];
        
        NSString *smarkersCount = [NSString stringWithFormat:@"%d", markersCount];
        NSString *sannotationsCount = [NSString stringWithFormat:@"%d", _annotationsCount];
        NSLog(smarkersCount);
        NSLog(sannotationsCount);
        
        if(markersCount < _annotationsCount) {
            int start = _annotationsCount - 1;
            for(int i = start; i >= markersCount; i--) {
                BMKPointAnnotation *annotation = [_annotations objectAtIndex:i];
                [self removeAnnotation:annotation];
                [_annotations removeObject:annotation];
            }
        }
    }
}

-(void) setPoiKeywords:(NSArray<NSString*>*) poiKeyword {
    _poiKeywords = poiKeyword;
    if(self.userLocation.location!=nil)
        [self searchNearbyPoi];
}

//将Json格式的数据转化为百度坐标
-(CLLocationCoordinate2D)getCoorFromMarkerOption:(NSDictionary *)option {
    double lat = [RCTConvert double:option[@"latitude"]];
    double lng = [RCTConvert double:option[@"longitude"]];
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;
    return coor;
}

-(void)addMarker:(BMKPointAnnotation *)annotation option:(NSDictionary *)option {
    [self updateMarker:annotation option:option];
    [self addAnnotation:annotation];
}

-(void)updateMarker:(BMKPointAnnotation *)annotation option:(NSDictionary *)option {
    CLLocationCoordinate2D coor = [self getCoorFromMarkerOption:option];
    NSString *title = [RCTConvert NSString:option[@"title"]];
    if(title.length == 0) {
        title = nil;
    }
    annotation.coordinate = coor;
    annotation.title = title;
}

#pragma mark - BMKLocationManagerDelegate

//定位错误时回调
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"ERROR IN MAP");
}

// 定位SDK中，方向变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    NSLog(@"HEADING IN MAP");
    if (!heading) {
        return;
    }
}

// 定位SDK中，位置变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    NSLog(@"LOCATION IN MAP");
    
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    
    if (!location) {
        return;
    }
    self.userLocation.location = location.location;
    //实现该方法，否则定位图标不出现
    [self updateLocationData:self.userLocation];
    self.centerCoordinate = self.userLocation.location.coordinate;
    
    //判断上次定位与本次定位距离，小于1000米不会重新进行poi检索
    double distance = [self calculateDistance:self.userLocation from:self.lastPoiUserLocation];
    NSLog(@"distance between two location is:%f",distance);

    if(distance>=1000) {
        NSLog(@"distance between two location is larger than 1000");
        [self searchNearbyPoi];
        self.lastPoiUserLocation.location = location.location;
    }
}


#pragma mark - BMKPoiSearchDelegate
/**
 POI检索返回结果回调
 
 @param searcher 检索对象
 @param poiResult POI检索结果列表
 @param error 错误码
 */
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult *)poiResult errorCode:(BMKSearchErrorCode)error {
    
    /**
     移除已有标注
     @param annotations 要移除的标注数组
     */
    if(_annotations != nil) {
        [self removeAnnotations:self.annotations];
        [_annotations removeAllObjects];
    }
    
    //BMKSearchErrorCode错误码，BMK_SEARCH_NO_ERROR：检索结果正常返回
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray* dictionaries = [[NSMutableArray alloc]init];
        for (NSUInteger i = 0; i < poiResult.poiInfoList.count; i ++) {

            //POI信息类的实例
            BMKPoiInfo *POIInfo = poiResult.poiInfoList[i];
            
            //处理POI结果
            NSMutableDictionary* dictionnary = [[NSMutableDictionary alloc]init];
            [dictionnary setObject:POIInfo.name forKey:@"name"];
            NSMutableString* address = [[NSMutableString alloc]initWithString:POIInfo.province];
            [address appendString:POIInfo.city];
            [address appendString:POIInfo.area];
            [address appendString:POIInfo.address];
            [dictionnary setObject:address forKey:@"address"];
            if(POIInfo.hasDetailInfo&&POIInfo.detailInfo.detailURL!=nil&&POIInfo.detailInfo.tag!=nil) {
                [dictionnary setObject:POIInfo.detailInfo.detailURL forKey:@"detailURL"];
                [dictionnary setObject:POIInfo.detailInfo.tag forKey:@"tag"];
            }else {
                [dictionnary setObject:@"" forKey:@"detailURL"];
                [dictionnary setObject:@"" forKey:@"tag"];
            }
            //初始化标注类BMKPointAnnotation的实例
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
            //设置标注的经纬度坐标
            annotation.coordinate = POIInfo.pt;
            //设置标注的标题
            NSLog(@"TITLE:%@",POIInfo.name);
            //设置携带的信息
            NSData *info=[NSJSONSerialization dataWithJSONObject:dictionnary options:NSJSONWritingPrettyPrinted error:nil];
            NSString *infoStr=[[NSString alloc]initWithData:info encoding:NSUTF8StringEncoding];
            annotation.title = POIInfo.name;
            annotation.subtitle = infoStr;
            
            [_annotations addObject:annotation];
            
            [dictionaries addObject:dictionnary];
        }
        //将一组标注添加到当前地图View中
        [self addAnnotations:_annotations];
        
        //设置当前地图的中心点
        //BMKPointAnnotation *annotation = annotations[0];
        // self.centerCoordinate = annotation.coordinate;
        
        //需要将结果返回到JS端
    
        NSDictionary* event = @{
                                    @"type": @"onMapPoiUpdate",
                                    @"params": dictionaries,
                              };
        [self sendEvent:event];

    }
    
    //打印POI信息类的实例
//    BMKPoiInfo *info = poiResult.poiInfoList[0];
//    NSString *basicMessage = [NSString stringWithFormat:@"检索结果总数：%ld\n总页数：%ld\n当前页的结果数：%ld\n当前页的页数索引：%ld\n名称：%@\n纬度：%f\n经度：%f\n地址：%@\n电话：%@\nUID：%@\n省份：%@\n城市：%@\n行政区域：%@\n街景图ID：%@\n是否有详情信息：%d\n", poiResult.totalPOINum, poiResult.totalPageNum, poiResult.curPOINum, poiResult.curPageIndex, info.name, info.pt.latitude, info.pt.longitude, info.address, info.phone, info.UID, info.province, info.city, info.area, info.streetID, info.hasDetailInfo];
//
//    NSString *detailMessage = @"";
//    if (info.hasDetailInfo) {
//        BMKPOIDetailInfo *detailInfo = info.detailInfo;
//        detailMessage = [NSString stringWithFormat:@"距离中心点的距离：%ld\n类型：%@\n标签：%@\n导航引导点坐标纬度：%f\n导航引导点坐标经度：%f\n详情页URL：%@\n商户的价格：%f\n营业时间：%@\n总体评分：%f\n口味评分：%f\n服务评分：%f\n环境评分：%f\n星级评分：%f\n卫生评分：%f\n技术评分：%f\n图片数目：%ld\n团购数目：%ld\n优惠数目：%ld\n评论数目：%ld\n收藏数目：%ld\n签到数目：%ld", detailInfo.distance, detailInfo.type, detailInfo.tag, detailInfo.naviLocation.latitude, detailInfo.naviLocation.longitude, detailInfo.detailURL, detailInfo.price, detailInfo.openingHours, detailInfo.overallRating, detailInfo.tasteRating, detailInfo.serviceRating, detailInfo.environmentRating, detailInfo.facilityRating, detailInfo.hygieneRating, detailInfo.technologyRating, detailInfo.imageNumber, detailInfo.grouponNumber, detailInfo.discountNumber, detailInfo.commentNumber, detailInfo.favoriteNumber, detailInfo.checkInNumber];
//    }
//    NSLog(@"basicMessage:/n%@",basicMessage);
//    NSLog(@"detailMessage:/n%@",detailMessage);
   // [self alertMessage:[NSString stringWithFormat:@"%@%@", basicMessage, detailMessage]];
}

- (void)searchNearbyPoi {
    
    //初始化BMKPoiSearch实例
    BMKPoiSearch *poiSearch = [[BMKPoiSearch alloc] init];
    //设置POI检索的代理
    poiSearch.delegate = self;
    
    //初始化请求参数类BMKNearbySearchOption的实例`
    BMKPOINearbySearchOption *nearbyOption = [[BMKPOINearbySearchOption alloc]init];
    /**
     检索关键字，必选。
     在周边检索中关键字为数组类型，可以支持多个关键字并集检索，如银行和酒店。每个关键字对应数组一个元素。
     最多支持10个关键字。
     */
    nearbyOption.keywords = self.poiKeywords; //componentsSeparatedByString:@","];
    //检索中心点的经纬度，必选
    nearbyOption.location = self.userLocation.location.coordinate;
    //单次召回POI数量，默认为10条记录，最大返回20条。
    nearbyOption.pageSize = 20;
    /**
     POI检索结果详细程度
     
     BMK_POI_SCOPE_BASIC_INFORMATION: 基本信息
     BMK_POI_SCOPE_DETAIL_INFORMATION: 详细信息
     */
    nearbyOption.scope = BMK_POI_SCOPE_DETAIL_INFORMATION;
    
    /**
     检索半径，单位是米。
     当半径过大，超过中心点所在城市边界时，会变为城市范围检索，检索范围为中心点所在城市
     */
     //nearbyOption.radius = 500;
    
    //分页页码，默认为0，0代表第一页，1代表第二页，以此类推
     //nearbyOption.pageIndex = 0;
    
    /**
     是否严格限定召回结果在设置检索半径范围内。默认值为false。
     值为true代表检索结果严格限定在半径范围内；值为false时不严格限定。
     注意：值为true时会影响返回结果中total准确性及每页召回poi数量，我们会逐步解决此类问题。
     */
     // nearbyOption.isRadiusLimit = true;
    
    /**
     检索分类，可选。
     该字段与keywords字段组合进行检索。
     支持多个分类，如美食和酒店。每个分类对应数组中一个元素
     */
    //nearbyOption.tags = option.tags;
  
    //检索过滤条件，scope字段为BMK_POI_SCOPE_DETAIL_INFORMATION时，filter字段才有效
    //nearbyOption.filter = option.filter;
    
    /**
     根据中心点、半径和检索词发起周边检索：异步方法，返回结果在BMKPoiSearchDelegate
     的onGetPoiResult里
     nearbyOption 周边搜索的搜索参数类
     成功返回YES，否则返回NO
     */
    BOOL flag = [poiSearch poiSearchNearBy:nearbyOption];
    if(flag) {
        NSLog(@"POI周边检索成功");
    } else {
        NSLog(@"POI周边检索失败");
    }
}

- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}

-(BMKUserLocation*) lastPoiUserLocation {
    if(!_lastPoiUserLocation) {
        _lastPoiUserLocation = [[BMKUserLocation alloc]init];
    }
    
    return _lastPoiUserLocation;
}

-(void)sendEvent:(NSDictionary *) params {
    NSLog(@"sendEvent:%@",params);
    if (!self.onChange) {
        return;
    }
    self.onChange(params);
}

-(CLLocationDistance)calculateDistance:(BMKUserLocation*) curLoc from:(BMKUserLocation*) lastLoc {
    if(curLoc.location==nil)
        return 0;
    if(lastLoc.location==nil)
        return 1000;
    CLLocationDistance distance = [curLoc.location distanceFromLocation:lastLoc.location];
    return distance;
}

@end





