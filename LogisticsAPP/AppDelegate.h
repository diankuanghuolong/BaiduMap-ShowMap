//
//  AppDelegate.h
//  LogisticsAPP
//
//  Created by Ios_Developer on 2018/1/15.
//  Copyright © 2018年 hai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKMapManager.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
        BMKMapManager* _mapManager;
}
@property (strong, nonatomic) UIWindow *window;


@end

