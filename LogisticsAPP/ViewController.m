//
//  ViewController.m
//  LogisticsAPP
//
//  Created by Ios_Developer on 2018/1/15.
//  Copyright © 2018年 hai. All rights reserved.
//

#import "ViewController.h"
#import "MapVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *gotoMapBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 140, 30)];
    [gotoMapBtn setTitle:@"进入地图页面" forState:UIControlStateNormal];
    [gotoMapBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [gotoMapBtn addTarget:self action:@selector(gotoMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gotoMapBtn];
}

#pragma mark ===== action =====
-(void)gotoMap:(UIButton *)sender
{
    MapVC *mapVC = [MapVC new];
    [self.navigationController pushViewController:mapVC animated:YES];
}



@end
