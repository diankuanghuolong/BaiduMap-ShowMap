//
//  LocationInfo.m
//  LogisticsAPP
//
//  Created by Ios_Developer on 2018/1/15.
//  Copyright © 2018年 hai. All rights reserved.
//

#import "LocationInfo.h"

@implementation LocationInfo

+(id)shareLocationInfo
{
    static LocationInfo * locInfo = nil;
    @synchronized(self)
    {
        if (!locInfo)
        {
            locInfo = [LocationInfo new];
        }
    }
    return locInfo;
}
-(void)setLocResult:(BMKReverseGeoCodeResult *)locResult
{
    if (locResult != _locResult) {
        _locResult = locResult;
        if (locResult.poiList.count > 0) {
            self.currentBMKPoiInfo = locResult.poiList[0];
        }
        else
        {
            BMKPoiInfo * poiInfo = [BMKPoiInfo new];
            poiInfo.name = locResult.address;
            poiInfo.address = locResult.address;
            poiInfo.city = locResult.addressDetail.city;
            poiInfo.pt = locResult.location;
            self.currentBMKPoiInfo = poiInfo;
        }//如果附近没有建筑物则显示地址
    }
}
-(NSString *)getlatString
{
    if (!self.currentBMKPoiInfo) return @"0.0";
    return [[NSString alloc] initWithFormat:@"%lf",self.currentBMKPoiInfo.pt.latitude];
}
-(NSString *)getlngString
{
    if (!self.currentBMKPoiInfo) return @"0.0";
    return [[NSString alloc] initWithFormat:@"%lf",self.currentBMKPoiInfo.pt.longitude];
}
-(void)initPropertys
{
    self.locResult = nil;
    self.currentBMKPoiInfo = nil;
}
@end
