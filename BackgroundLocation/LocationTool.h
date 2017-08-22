//
//  LocationTool.h
//  BackgroundLocation
//
//  Created by long on 2017/6/16.
//  Copyright © 2017年 long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationTool : NSObject

+ (instancetype)shareInstance;

- (void)setUploadInterval:(NSTimeInterval)interval;

- (void)startLocation;

- (void)stopLocation;

@end
