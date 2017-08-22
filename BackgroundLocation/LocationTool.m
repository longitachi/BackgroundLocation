//
//  LocationTool.m
//  BackgroundLocation
//
//  Created by long on 2017/6/16.
//  Copyright © 2017年 long. All rights reserved.
//

#import "LocationTool.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

@interface LocationTool () <CLLocationManagerDelegate>
{
    NSTimeInterval _interval;
}

@property (nonatomic, strong) CLLocationManager *locManager;

@property (nonatomic, assign) NSTimeInterval lastUpdateTime;

@end

@implementation LocationTool

+ (instancetype)shareInstance
{
    static LocationTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationTool alloc] init];
        instance->_interval = 60;
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static LocationTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{   //onceToken是GCD用来记录是否执行过 ，如果已经执行过就不再执行(保证执行一次）
        instance = [super allocWithZone:zone];
        instance->_interval = 60;
    });
    return instance;
}

- (CLLocationManager *)locManager
{
    if (!_locManager) {
        _locManager = [[CLLocationManager alloc] init];
        if ([_locManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
            _locManager.allowsBackgroundLocationUpdates = YES;
        }
        _locManager.pausesLocationUpdatesAutomatically = NO;
        _locManager.distanceFilter = kCLDistanceFilterNone;
        _locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    return _locManager;
}

- (void)setUploadInterval:(NSTimeInterval)interval
{
    _interval = interval;
}

- (void)startLocation
{
    NSLog(@"startLocationTracking");
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted) {
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            self.locManager.delegate = self;
            
            [self.locManager requestAlwaysAuthorization];
//            [self.locManager requestWhenInUseAuthorization];
            [self.locManager startUpdatingLocation];
        }
    }
}

- (void)stopLocation
{
    self.locManager.delegate = nil;
    [self.locManager stopUpdatingLocation];
}

static int i = 0;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (![self canUpload]) return;
    
    CLLocation *loc = locations.firstObject;
    
    NSLog(@"----- i = %d, 维度: %f, 经度: %f", i++, loc.coordinate.latitude, loc.coordinate.longitude);
    
    [self sendNotifycation:loc.coordinate];
    
    [self uploadLocation:loc.coordinate];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败: %@", error);
}

#pragma mark - privite
- (BOOL)canUpload
{
    CFTimeInterval t = CACurrentMediaTime();
    if (t - self.lastUpdateTime > _interval) {
        self.lastUpdateTime = t;
        return YES;
    }
    return NO;
}

- (void)uploadLocation:(CLLocationCoordinate2D)coor
{
    //上传定位
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"请求百度成功 %d", i);
        } else {
            NSLog(@"请求百度失败 %d", i);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadSuc" object:nil userInfo:@{@"message": !error?[NSString stringWithFormat:@"请求百度成功 %d", i]:[NSString stringWithFormat:@"请求百度失败 %d", i]}];
    }];
    [task resume];
}

- (void)sendNotifycation:(CLLocationCoordinate2D)coor
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.badge = @(1);
    content.body = [NSString stringWithFormat:@"定位成功 %d ", i];
    content.title = [NSString stringWithFormat:@"WGS84 维度:%.6f, 经度:%.6f", coor.latitude, coor.longitude];
    //推送类型
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Test" content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"iOS 10 发送推送， error：%@", error);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationSuc" object:nil userInfo:@{@"message": [content.body stringByAppendingString:content.title]}];
}

@end
