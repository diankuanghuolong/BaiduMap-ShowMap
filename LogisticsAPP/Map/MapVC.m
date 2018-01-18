//
//  MapVC.m
//  LogisticsAPP
//
//  Created by Ios_Developer on 2018/1/15.
//  Copyright © 2018年 hai. All rights reserved.
//

#import "MapVC.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

//
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

#import "LocationInfo.h"

//------------------------------ 自定义BMKAnnotationView，用于显示title  ----------------------------------
// 自定义BMKAnnotationView，用于显示title
@interface MyAnnotationView : BMKPinAnnotationView

@property (nonatomic ,strong)UILabel *titlL;
@property (nonatomic ,strong)UILabel *subTitleL;

@end

@implementation MyAnnotationView

@synthesize titlL = _titlL;
@synthesize subTitleL   = _subTitleL;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBounds:CGRectMake(0.f, 0.f, 100.f, 50.f)];
        
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(-50.f, -50.f, 100.f, 50.f)];
        tipView.backgroundColor = [UIColor colorWithRed:209/255.f green:236/255.f blue:205/255.f alpha:1];
        tipView.layer.cornerRadius = 7;
        tipView.layer.masksToBounds = YES;
        [self addSubview:tipView];
        
        _titlL = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 20.f)];
        _titlL.text = annotation.title;
        _titlL.textAlignment = NSTextAlignmentCenter;
        _titlL.font = [UIFont systemFontOfSize:13];
        _titlL.backgroundColor = [UIColor clearColor];
        [tipView addSubview:_titlL];
        
        _subTitleL = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 25.f, 100.f, 20.f)];
        _subTitleL.text = annotation.subtitle;
        _subTitleL.textAlignment = NSTextAlignmentCenter;
        _subTitleL.font = [UIFont systemFontOfSize:13];
        _subTitleL.backgroundColor = [UIColor clearColor];
        [tipView addSubview:_subTitleL];
        
        
        self.canShowCallout = NO;//禁止原生气泡显示
    }
    return self;
}

@end

// 自定义BMKAnnotationView，用于显示title
@interface SportAnnotationView : BMKAnnotationView

@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic ,strong)UILabel *subTitleL;

@end
//------------------------------------------------------------------------------------------------------


@interface MapVC ()<BMKMapViewDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate>
{
    BMKMapView * _mapView;
    UIImageView *_mapCenterPoint;//地图中心标注大头针
    BMKPointAnnotation *_nowPointAnnotation;//当前位置大头针
    
    UIButton *_fullScreenBtn;//全屏按钮
    UIButton *_backUserPoint;//返回用户位置
    NSString *_addressStr;//记录位置
    
//    NSMutableArray *_pointAnnotationsArr;//标注点数组（当前为假数据，实际中，使用后台返回坐标点数组）
    
    NSArray *_dataSource;//请求数据
}
@property(nonatomic,strong)BMKGeoCodeSearch * searcher;
@property(nonatomic,strong)BMKLocationService * locationService;

@property(nonatomic,strong)UILabel *addressL;
@property(nonatomic,strong)UIView *addressView;

@end

@implementation MapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"地图";
    self.view.backgroundColor = [UIColor whiteColor];
    
//    _pointAnnotationsArr = [NSMutableArray new];
    
    [self loadMapView];
    [self position:nil];//定位
    
    self.addressView = [[UIView alloc] initWithFrame:CGRectMake(0, _mapView.bottom, SCREEN_WIDTH, 50)];
    [self.view addSubview:self.addressView];
    [self loadLocationView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    NSString *lng = [[NSString alloc] initWithFormat:@"%f",[LocationInfo shareLocationInfo].currentBMKPoiInfo.pt.longitude];
    NSString *lat = [[NSString alloc] initWithFormat:@"%f",[LocationInfo shareLocationInfo].currentBMKPoiInfo.pt.latitude];
    [self downLoadLng:lng andLat:lat];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    self.searcher.delegate = nil;
    _searcher = nil;
}
#pragma mark ===== downLoad =====
-(void)downLoadLng:(NSString *)lng andLat:(NSString *)lat
{
    //请求接口
    _dataSource = @[@{@"lat":@(40.003765106201172),@"long":@(116.35929870605469),@"title":@"唯有工作",@"subtitle":@"能使我快乐"},@{@"lat":@(40.003765106201172 + 0.0004),@"long":@(116.35929870605469 - 0.0004),@"title":@"朕的一生啊，",@"subtitle":@"就是要写bug"},@{@"lat":@(40.003765106201172 + 0.0004 * 2),@"long":@(116.35929870605469 - 0.0004*2),@"title":@"似奔腾之群马，",@"subtitle":@"似瀑下之江流"},@{@"lat":@(40.003765106201172 + 0.0004*3),@"long":@(116.35929870605469 - 0.0004 * 3),@"title":@"群马喜疾驰",@"subtitle":@"江流爱湍游"},@{@"lat":@(40.003765106201172 + 0.0004 * 4),@"long":@(116.35929870605469 - 0.0004 *4),@"title":@"日月虽有坠，",@"subtitle":@"我志岂肯休？"},@{@"lat":@(40.003765106201172 + 0.0004 * 5),@"long":@(116.35929870605469 - 0.0004 *5),@"title":@"我志岂肯休？",@"subtitle":@"日月虽有坠，"}];
}
#pragma mark ===== loadSubViews  =====
- (void)loadMapView
{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight - SafeAreaBottomHeight - 50)];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    _mapView.showMapScaleBar = YES;//比例尺
    _mapView.mapScaleBarPosition = CGPointMake(10,_mapView.bottom - 45 - 64);//比例尺的位置
    
    [_mapView setZoomEnabled:YES];
    _mapView.zoomLevel = /*14.1*/19; //地图等级，数字越大越清晰
    
    _fullScreenBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 10, 40, 40)];
    [_fullScreenBtn setImage:[UIImage imageNamed:@"map_fullscreen_out"] forState:UIControlStateNormal];
    [_fullScreenBtn setImage:[UIImage imageNamed:@"map_fullscreen_in"] forState:UIControlStateSelected];
    [_fullScreenBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:_fullScreenBtn];
    
    //返回用户定位点
    _backUserPoint = [[UIButton alloc] initWithFrame:CGRectMake(_fullScreenBtn.left + 5, _fullScreenBtn.bottom + 10, _fullScreenBtn.width - 10, _fullScreenBtn.height - 10)];
    [_backUserPoint setImage:[UIImage imageNamed:@"back_userPoint"] forState:UIControlStateNormal];
    [_backUserPoint addTarget:self action:@selector(backUserPoint:) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:_backUserPoint];
    
    [_mapView setCenterCoordinate:[LocationInfo shareLocationInfo].currentBMKPoiInfo.pt animated:YES];
    _mapView.showsUserLocation = NO;//是否显示定位小蓝点，no不显示，我们下面要自定义的(这里显示前提要遵循代理方法，不可缺少)
    
    //地图中心点
    _mapCenterPoint = [[UIImageView alloc] initWithFrame:CGRectMake((_mapView.width - 23)/2, (_mapView.height - 23)/2 + 64, 23, 23)];
    _mapCenterPoint.image = [UIImage imageNamed:@"mapCenter_point"];
    _mapCenterPoint.userInteractionEnabled = YES;
    [self.view addSubview:_mapCenterPoint];
}
-(void)loadLocationView
{
    UIControl * c = [[UIControl alloc] initWithFrame:CGRectMake(30, 5, SCREEN_WIDTH - 60, 40)];
    [c addTarget:self action:@selector(selectCity:) forControlEvents:UIControlEventTouchUpInside];
    c.layer.cornerRadius = 5;
    c.layer.masksToBounds = YES;
    
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(5, (c.height - 20)/2, 20, 20)];
    iv.image = [UIImage imageNamed:@"menu_location_black"];
    [c addSubview:iv];
    
    self.addressL = [[UILabel alloc] initWithFrame:CGRectMake(iv.right + 5, 0, c.width - 120, c.height)];
    _addressL.text = _addressStr;
    _addressL.font = [UIFont systemFontOfSize:15];
    _addressL.textColor = [UIColor blackColor];
    _addressL.textAlignment = NSTextAlignmentCenter;
    _addressL.lineBreakMode = NSLineBreakByTruncatingHead;//前省略
    self.addressL.userInteractionEnabled = NO;
    self.addressL.numberOfLines = 2;
    [c addSubview:self.addressL];
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(self.addressL.right, 0, 80, c.height)];
    l.text = @"(点击选择地址)";
    l.font = [UIFont systemFontOfSize:15];
    l.textColor = [UIColor blackColor];
    l.textAlignment = NSTextAlignmentCenter;
    l.userInteractionEnabled = NO;
    l.backgroundColor = [UIColor clearColor];
    [c addSubview:l];
    
    [self.addressView addSubview:c];
    
    UIImageView *arrIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.addressView.width - 25, c.top + 10, 20, 20)];
    arrIV.image = [UIImage imageNamed:@"right_arrow"];
    [self.addressView addSubview:arrIV];
}

- (void)position:(id)sender
{
    
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    //定位
    self.locationService = [[BMKLocationService alloc]init];
    self.locationService.delegate = self;
    self.locationService.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationService.distanceFilter = 100;
    [self.locationService startUserLocationService];
    
    //当前定位大头针
    _nowPointAnnotation = [[BMKPointAnnotation alloc] init];
}
#pragma mark ======  发起反检索/正向检索  =====
//发起反向地理编码检索
- (void)getReverseGeoCodeWithLocation:(CLLocationCoordinate2D)pt
{
    //初始化检索对象
    _searcher =[[BMKGeoCodeSearch alloc]init];
    _searcher.delegate = self;
    
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[
                                                            BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}
//发起地理编码检索
- (void)getGeoCodeWithLocation:(NSString *)address
{
    //初始化检索对象
    _searcher =[[BMKGeoCodeSearch alloc]init];
    _searcher.delegate = self;
    
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geoCodeSearchOption.address = address;
    BOOL flag = [_searcher geoCode:geoCodeSearchOption];
    if(flag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        NSLog(@"geo检索发送失败");
    }
}
#pragma mark --Action
- (void)fullScreen:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        _mapView.frame = CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight - SafeAreaBottomHeight);
        //        _tableView.hidden = YES;
    }
    else
    {
        _mapView.frame = CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight - SafeAreaBottomHeight - 50);
        //        _tableView.hidden = NO;
    }
    _mapCenterPoint.frame = CGRectMake((_mapView.width - 23)/2, (_mapView.height - 23)/2 + 64, 23, 23);
}
-(void)backUserPoint:(UIButton *)sender//返回用户所在位置
{
    [_mapView setCenterCoordinate:_nowPointAnnotation.coordinate animated:YES];
}
-(void)selectCity:(id)sender
{
    //跳转地址选择页面
}
#pragma mark ===== BMKLocationServiceDelegate方法 =====
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];//地图中心点以选择地址为准，定位点不算
    
    //定位点大头针
    _nowPointAnnotation.coordinate = userLocation.location.coordinate;
    _nowPointAnnotation.title = @"您当前所在位置";
    [_mapView selectAnnotation:_nowPointAnnotation animated:YES];
    [_mapView addAnnotation:_nowPointAnnotation];
    
    [self.locationService stopUserLocationService];
    
    
    [self showAllPoints];
}
//接收反向地理编码结果
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"error = %d",error);
    if (error == BMK_SEARCH_NO_ERROR)
    {
        _addressStr = result.address;
        _addressL.text = _addressStr;
        
        //       //测试点大头针
        //        BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc] init];
        //        pointAnnotation.coordinate = CLLocationCoordinate2DMake(result.location.latitude + 0.0004, result.location.longitude - 0.0004);
        //        pointAnnotation.title = @"测试点1";
        //        pointAnnotation.subtitle = @"测试点";
        //        [_mapView addAnnotation:pointAnnotation];
        //        [_mapView selectAnnotation:pointAnnotation animated:YES];
        //
        //        BMKPointAnnotation *pointAnnotation1 = [[BMKPointAnnotation alloc] init];
        //        pointAnnotation1.coordinate = CLLocationCoordinate2DMake(result.location.latitude, result.location.longitude + 0.0004);
        //        pointAnnotation1.title = @"测试点2";
        //        pointAnnotation1.subtitle = @"测试点";
        //        [_mapView addAnnotation:pointAnnotation1];
        //        [_mapView selectAnnotation:pointAnnotation1 animated:YES];
        
        //        NSArray *pointArr = @[pointAnnotation,pointAnnotation1];
        //        [_pointAnnotationsArr addObjectsFromArray:pointArr];
        
    }
}
//接收地理编码结果 （暂时不用）
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error;
{
    if (error == BMK_SEARCH_NO_ERROR)
    {
        //        //在此处理正常结果
        //
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(result.location.latitude, result.location.longitude) animated:YES];
        
        //        //测试大头针
        //        _pointAnnotation.coordinate = result.location;
        //        _pointAnnotation.subtitle = result.address;
        //
        //        //
        //        BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc] init];
        //        pointAnnotation.coordinate = CLLocationCoordinate2DMake(result.location.latitude + 0.0004, result.location.longitude - 0.0004);
        //        pointAnnotation.title = @"测试点1";
        //        //        pointAnnotation.subtitle = @"测试点";
        //        [_mapView addAnnotation:pointAnnotation];
        //        [_mapView selectAnnotation:pointAnnotation animated:YES];
        //
        //        BMKPointAnnotation *pointAnnotation1 = [[BMKPointAnnotation alloc] init];
        //        pointAnnotation1.coordinate = CLLocationCoordinate2DMake(result.location.latitude, result.location.longitude + 0.0004);
        //        pointAnnotation1.title = @"测试点2";
        //        //        pointAnnotation1.subtitle = @"测试点";
        //        [_mapView addAnnotation:pointAnnotation1];
        //        [_mapView selectAnnotation:pointAnnotation1 animated:YES];
        //
        //        NSArray *pointArr = @[pointAnnotation,pointAnnotation1];
        //        [_pointAnnotationsArr addObjectsFromArray:pointArr];
    }
    else
    {
        NSLog(@"抱歉，未找到结果");
    }
}

#pragma mark --notification method
-(void)locationInfoChange:(NSNotification *)sender
{
    if ([sender.userInfo[@"isSuccess"] boolValue]) {
        
        _addressStr = [LocationInfo shareLocationInfo].currentBMKPoiInfo.name;
        _addressL.text = _addressStr;
        
        [_mapView setCenterCoordinate:[LocationInfo shareLocationInfo].currentBMKPoiInfo.pt animated:YES];
    }
    else{
        _addressL.text = @"获取位置失败";
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark =====  tool  =====
-(void)showAllPoints
{
    NSArray *arr = _dataSource;
    for (int i = 0 ; i < arr.count; i ++)
    {
//        NSLog(@"lat == %f,long == %f",[arr[i][@"lat"] doubleValue],[arr[i][@"long"] doubleValue]);
        BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake([arr[i][@"lat"] doubleValue], [arr[i][@"long"] doubleValue]);
        pointAnnotation.title = arr[i][@"title"];
        pointAnnotation.subtitle = arr[i][@"subtitle"];
        [_mapView addAnnotation:pointAnnotation];
        //    [_mapView selectAnnotation:pointAnnotation animated:YES];
    }
}
//更新地图中心位置
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self getReverseGeoCodeWithLocation:mapView.centerCoordinate];
}
//- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status {
//    _pointAnnotation.coordinate = mapView.centerCoordinate;
//    [self getReverseGeoCodeWithLocation:mapView.centerCoordinate];
//}
//换大头针
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    
    //移除标注点
//    [_mapView removeAnnotations:_pointAnnotationsArr];
    
    if(annotation == _nowPointAnnotation)//当前位置点
    {
        NSString *AnnotationViewIDs = @"renameMarks";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewIDs];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewIDs];
            annotationView.annotation=annotation;
            annotationView.image = [UIImage imageNamed:@"nowAddress"];   //把大头针换成别的图片
            annotationView.size = CGSizeMake(23, 23);
        }
        return annotationView;
    }
    else
    {
        //        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        //        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        //        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        //        //        newAnnotationView.draggable = YES;//设置可拖拽
        //        newAnnotationView.annotation = annotation;
        //        newAnnotationView.image = [UIImage imageNamed:@"robotAddress"];   //把大头针换成别的图片
        //        newAnnotationView.size = CGSizeMake(23, 23);
        
        MyAnnotationView *newAnnotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        //        newAnnotationView.draggable = YES;//设置可拖拽
        newAnnotationView.annotation = annotation;
        newAnnotationView.image = [UIImage imageNamed:@"robotAddress"];   //把大头针换成别的图片
        newAnnotationView.size = CGSizeMake(23, 23);
        
        return newAnnotationView;
    }
    
}
//点击大头针代理
-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    BMKAnnotationView *annotationView = [[BMKAnnotationView alloc] init];
    annotationView = view;
    //        view.annotation.coordinate
}
/*
 //拖动大头针
 -(void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState fromOldState:(BMKAnnotationViewDragState)oldState
 {
 switch (newState)
 {
 case BMKAnnotationViewDragStateStarting:
 {
 NSLog(@"拿起");
 return;
 }
 break;
 case BMKAnnotationViewDragStateDragging:
 {
 NSLog(@"开始拖拽");
 return;
 }
 break;
 case BMKAnnotationViewDragStateEnding:
 {
 NSLog(@"放下,并将大头针");
 CLLocationCoordinate2D destCoordinate =view.annotation.coordinate;
 _pointAnnotation.coordinate = destCoordinate;
 //            [self shuaXinWeiZhi:destCoordinate.latitude andWeiDu:destCoordinate.longitude];
 
 return;
 }
 break;
 default:
 break;
 }
 }
 */
@end

