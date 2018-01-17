# BaiduMap-ShowMap
百度地图定位，地图展示功能、大头针，多个大头针及气泡title展示。

![简书]（http://www.jianshu.com/writer#/notebooks/19387991/notes/22631443/preview）
#为了维护宇宙的和平，又鉴于网上资料的不详细，更为了防止世界被破坏，本文讲详细讲解一个百度的集成方案，保证实用。
>简介：百度地图的定位以及地图显示功能集成。手动集成的方法此处不作介绍了，我用的是pod方法集成的。


- 1.项目集成百度sdk。在你的Podfile文件中，导入百度sdk：（导入后会有很多ios9以后的第三方警告问题，如下解决,若还有未解决的警告可以进去到警告页面找到相应位置，）

platform :ios, '8.0'
inhibit_all_warnings!   ##忽略警告⚠️
target '你的项目名’ do
- 2.环境配置：因为要用到后台定位和地图定位功能，需要作如下配置
   （a.）plist文件配置如下图，4项，第一项为网络https配置：
   
![展示图片](https://github.com/diankuanghuolong/BaiduMap-ShowMap/blob/master/showImages/plist.png)

    (b.)后台定位设置，如图
    
![展示图片](https://github.com/diankuanghuolong/BaiduMap-ShowMap/blob/master/showImages/backgroud.png)

-3.注册：在百度地图开发平台注册并创建你的app，记得app名字要和你创建的项目名字一直，然后在百度平台获取key。
        再进入你项目中，AppDelegate中设置。将你的AppDelegate后缀改为.mm（用到C语法，可以自己去查查）。
```
下边代码可以在demo中查看

#import <BaiduMapAPI_Base/BMKMapManager.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"hHycKldnuGp2wwpjgYBvlbsYcmLUCjHb"  generalDelegate:nil];
    if (!ret) {
    NSLog(@"manager start failed!");
    }
}

```
demo中的MapVC控制器中，设置了定位、地图、正反编码、大头针添加、大头针移动、大头针title显示。（注释掉部分代码，可以demo中没用，有兴趣的可以打开试试效果）

## 大头针title都显示问题
>这里有个问题介绍下：
    大头针气泡上的title和subtitle显示问题：baidu自己的title显示是，如果你设置了现实，默认是选中哪个，哪个的title显示，其他的不是选中状态，所以不会显示。如果项目中，你需要做到所有大头针的title都显示，那么baidu默认BMKPointAnnotation无法满足，可以自定义BMKAnnotationView，添加titleL来实现，具体做法在demo中的MapVC中可以找到。为了方便了解，这里把处理部分的代码贴出来，如下：
```
大致思路如下：
1.先在vc中自定义带title的BMKAnnotationView；
2.再在代理方法
    //换大头针
    - (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation；
中修改BMKAnnotationView，和BMKAnnotation ;
3.显示title ：  -(void)showAllPoints; 将BMKPointAnnotation添加到map上，但是不显示BMKPointAnnotation的title，使自定义的BMKAnnotationView的title = pointAnnotation.title = @"上行：1";

1.----------------------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
2.----------------------------------------------------------------------------------------------------
        //换大头针
        - (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{

            ---------------------------这部分可以先不看，在demo中去研究吧 ----------------------------------
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
                ---------------------------只看这部分--------------------------------------
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
                ---------------------------只看这部分--------------------------------------
            }

        }
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
3.----------------------------------------------------------------------------------------------------
这里设置了6个测试点，具体项目中，可以根据后台返回给你的坐标和title赋值
此处虽然是在map上添加标注点 BMKPointAnnotation，但是他的作用是为了显示你自定义的BMKAnnotationView 的title。在自定义的BMKAnnotationView中已经设置BMKPointAnnotation的title为不显示（self.canShowCallout = NO;//禁止原生气泡显示）
       -(void)showAllPoints
        {
            BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(40.003765106201172 + 0.0004, 116.35929870605469 - 0.0004);
            pointAnnotation.title = @"上行：1";
            pointAnnotation.subtitle = @"下行：1";
            [_mapView addAnnotation:pointAnnotation];
            //    [_mapView selectAnnotation:pointAnnotation animated:YES];

            BMKPointAnnotation *pointAnnotation1 = [[BMKPointAnnotation alloc] init];
            pointAnnotation1.coordinate = CLLocationCoordinate2DMake(40.003765106201172, 116.35929870605469 + 0.0004);
            pointAnnotation1.title = @"上行：2";
            pointAnnotation1.subtitle = @"下行：2";
            [_mapView addAnnotation:pointAnnotation1];
            //    [_mapView selectAnnotation:pointAnnotation1 animated:YES];


            BMKPointAnnotation *pointAnnotation2 = [[BMKPointAnnotation alloc] init];
            pointAnnotation2.coordinate = CLLocationCoordinate2DMake(40.003765106201172 + 0.0004, 116.35929870605469 + 0.0004);
            pointAnnotation2.title = @"上行：3";
            pointAnnotation2.subtitle = @"下行：3";
            [_mapView addAnnotation:pointAnnotation2];

            BMKPointAnnotation *pointAnnotation3 = [[BMKPointAnnotation alloc] init];
            pointAnnotation3.coordinate = CLLocationCoordinate2DMake(40.003765106201172, 116.35929870605469 + 0.0008);
            pointAnnotation3.title = @"上行：4";
            pointAnnotation3.subtitle = @"下行：4";
            [_mapView addAnnotation:pointAnnotation3];

            BMKPointAnnotation *pointAnnotation4 = [[BMKPointAnnotation alloc] init];
            pointAnnotation4.coordinate = CLLocationCoordinate2DMake(40.003765106201172 + 0.0008, 116.35929870605469 + 0.0004);
            pointAnnotation4.title = @"上行：5";
            pointAnnotation4.subtitle = @"下行：5";
            [_mapView addAnnotation:pointAnnotation4];

        }

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
```

![展示图](https://github.com/diankuanghuolong/BaiduMap-ShowMap/blob/master/showImages/地图.gif)


