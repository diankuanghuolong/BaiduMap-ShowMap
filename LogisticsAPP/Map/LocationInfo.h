//
//  LocationInfo.h
//  LogisticsAPP
//
//  Created by Ios_Developer on 2018/1/15.
//  Copyright © 2018年 hai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Search/BMKPoiSearch.h>
@interface LocationInfo : NSObject

@property(nonatomic,strong)BMKReverseGeoCodeResult * locResult;//最后一次定位位置
@property(nonatomic,strong)BMKPoiInfo * currentBMKPoiInfo;//用户最终选择的位置
-(void)setLocResult:(BMKReverseGeoCodeResult *)locResult;
+(LocationInfo *)shareLocationInfo;
-(NSString *)getlatString;
-(NSString *)getlngString;

-(void)initPropertys;
@end
