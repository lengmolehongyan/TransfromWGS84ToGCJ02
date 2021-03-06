//
//  WGS84TOGCJ02.m
//
//  Created by lengmolehongyan on 15/12/4.
//  Copyright © 2015年 lengmolehongyan. All rights reserved.
//

#import "WGS84TOGCJ02.h"

const CGFloat a = 6378245.0;
const CGFloat ee = 0.00669342162296594323;

@implementation WGS84TOGCJ02

/** 判断是否已经超出中国范围 */
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location {
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

/** 将经纬度转成 GCJ02 */
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc {
    CLLocationCoordinate2D adjustLoc;
    if ([self isLocationOutOfChina:wgsLoc]) {
        // 超过中国区范围不转换
        adjustLoc = wgsLoc;
    } else {
        CGFloat adjustLat = [self transformLatWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        CGFloat adjustLon = [self transformLonWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        CGFloat radLat = wgsLoc.latitude / 180.0 * M_PI;
        CGFloat magic = sin(radLat);
        magic = 1 - ee * magic * magic;
        CGFloat sqrtMagic = sqrt(magic);
        adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
        adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
        adjustLoc.latitude = wgsLoc.latitude + adjustLat;
        adjustLoc.longitude = wgsLoc.longitude + adjustLon;
    }
    return adjustLoc;
}

+ (CGFloat)transformLatWithX:(CGFloat)x withY:(CGFloat)y {
    CGFloat lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    lat += (20.0 * sin(6.0 * x * M_PI) + 20.0 *sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    lat += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    lat += (160.0 * sin(y / 12.0 * M_PI) + 3320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return lat;
}

+ (CGFloat)transformLonWithX:(CGFloat)x withY:(CGFloat)y {
    CGFloat lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    lon += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    lon += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    lon += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return lon;
}

@end
