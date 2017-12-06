//
//  ViewController.m
//  CoreLocation
//
//  Created by leo on 16/7/14.
//  Copyright © 2016年 huashen. All rights reserved.
//

/* CoreLocation 中的类 
   CLLocation 用来记录地理位置信息 经纬度 海拔等
   CLLocationCoordinate2D  coordinate 结构体用于记录经纬度信息
        （ 结构体 有两个参数 longtitude ：经度 和 latitude：纬度 ）
   CLLocationDistance      altitude用于记录海拔信息
   CLLocationDirection     course 用来记录航向 0 - 360 度
   CLLocationSpeed         speed  用来记录行走速度
 */

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h> // 可以追踪用户的地理位置信息



@interface ViewController ()<CLLocationManagerDelegate>{
    CLLocationManager *_locationManager ;
}

@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation ViewController
- (IBAction)location:(UIButton *)sender {
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        // 开始定位更新地理位置信息
        [_locationManager startUpdatingLocation];
    }else{
        NSLog(@"当前用户定位服务未开启");
    }
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
     self.label.numberOfLines = 0 ;
    [self setupLocationManager];
}

-(void)setupLocationManager{
    
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self ;
    _locationManager.distanceFilter = 100 ; // 距离检测
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest ; // 目标精确度
    // ios 8 及以后版本需加入这句内容
    [_locationManager requestWhenInUseAuthorization];// 仅app在前台时进行定位
    //[_locationManager requestAlwaysAuthorization];// 程序进如后台后仍会定位
    //[_locationManager startUpdatingLocation]; // 开始定位
    
    // ios 8 及更高版本的系统
    // 在Info.plist文件中添加如下配置：
    //（1）NSLocationAlwaysUsageDescription
    // (2）NSLocationWhenInUseUsageDescription
}


#pragma mark 定位代理方法

// (定位目标原来所在位置和当前所在位置)适用于2.0-6.0系统新系统 已弃用
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

    CLLocationCoordinate2D location = [newLocation coordinate];
    float longitude = location.longitude ;
    float latitude = location.latitude ;
    self.label.text = [NSString stringWithFormat:@"经度%f 纬度%f",longitude ,latitude];

}

//13.999928 74

// 新方法  若定位没有停止 则会频繁调用该方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    //获取最新的定位信息并获取反地理编码
    CLLocation *location = [locations lastObject];
    [self regeoWithLocation:location];
}

// 反地理位置编码（将获得的经纬度信息反编码为一般的地址）
-(void)regeoWithLocation:(CLLocation *)location{
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *currentCity = placeMark.locality ; // 获取所在的区域（上海市）
            self.label.text = placeMark.name ;
            //  placeMark.name 详细的地址信息
            NSLog(@"%@%@",currentCity,placeMark.name);
        }
    }];
}

// 定位失败调用该方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSLog(@"%@",error.localizedDescription);
}


-(void)viewWillDisappear:(BOOL)animated{
    // 结束定位服务
    [_locationManager stopUpdatingLocation];
}






@end
