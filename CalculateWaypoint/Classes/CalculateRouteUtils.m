//
//  CalculateRouteUtils.m
//  CalculateWaypoint
//
//  Created by Taylor on 2019/6/29.
//  Copyright © 2019 Taylor. All rights reserved.
//

#import "CalculateRouteUtils.h"
#import <ArcGIS/ArcGIS.h>
@implementation CalculateRouteUtils

-(void)createPolygonBoundsWithPoints:(NSArray<AGSPoint *> *)points{
  
    if (points.count>0) {
        //纬度
        NSMutableArray *latsLists = [NSMutableArray array];
        //经度
        NSMutableArray *lngsLists = [NSMutableArray array];
    
        //lng是经度，对应x；lat是纬度，对应y
        for (AGSPoint *point in points) {
            [latsLists addObject:[NSNumber numberWithDouble:point.y]];
            [lngsLists addObject:[NSNumber numberWithDouble:point.x]];
        }
        //最东经
        double lngsMax = [[lngsLists valueForKeyPath:@"@max.doubleValue"] doubleValue];
        //最西经
        double lngsMin = [[lngsLists valueForKeyPath:@"@min.doubleValue"] doubleValue];
        //最北纬
        double latsMax = [[latsLists valueForKeyPath:@"@max.doubleValue"] doubleValue];
        //最南纬
        double latsMin = [[latsLists valueForKeyPath:@"@min.doubleValue"] doubleValue];
        
        //中间点
        double lngsCenter = (lngsMax + lngsMin) / 2;
        double latsCenter = (latsMax + latsMin) / 2;
        
        //0中点
        _centerPoint = AGSPointMakeWGS84(latsCenter, lngsCenter);
        //1西北
        _wnPoint = AGSPointMakeWGS84(latsMax, lngsMin);
        //2东北
        _enPoint = AGSPointMakeWGS84(latsMax, lngsMax);
        //3东南
        _esPoint = AGSPointMakeWGS84(latsMin, lngsMax);
        //4西南
        _wsPoint = AGSPointMakeWGS84(latsMin, lngsMin);
    }
}
-(NSArray<AGSPoint *> *)createRotatePolygonWithmLatlists:(NSArray<AGSPoint *> *)mLatlists rotate:(int)rotate{
    NSMutableArray *latLngList = [NSMutableArray array];
    for (AGSPoint *point in mLatlists) {
        [latLngList addObject:transform(point.x, point.y, self.centerPoint.x, self.centerPoint.y, rotate, 0, 0)];
    }
    return latLngList;
}
AGSPoint * transform(double x, double y, double tx, double ty, int deg, int sx, int sy) {
   
    double sdeg = deg * M_PI / 180;
    if (sy == 0) sy = 1;
    if (sx == 0) sx = 1;
    double first = sx * ((x - tx) * cos(sdeg) - (y - ty) * sin(sdeg)) + tx;
    double second = sy * ((x - tx) * sin(sdeg) + (y - ty) * cos(sdeg)) + ty;
    return AGSPointMakeWGS84(second, first);
}
//计算有多少条纬度线穿过 纬度线相差lat
-(CGPoint)createLatsWithSpace:(int)space{
    //线条数量
    double steps = ([self getDistanceWithPoint:_wnPoint point2:_wsPoint] / space);
    //纬度差
    double lat = (_wnPoint.y - _wsPoint.y) / (int)steps;
    
    return CGPointMake(steps, lat);
}

//计算两个点的距离
float distance(AGSPoint*latLng1, AGSPoint *latLng2) {
    
    return [AGSGeometryEngine distanceBetweenGeometry1:latLng1 geometry2:latLng2];
}
-(CLLocationDistance)getDistanceWithPoint:(AGSPoint *)point1 point2:(AGSPoint *)point2{
  
    CLLocation *location1 = [[CLLocation alloc]initWithLatitude:point1.y longitude:point1.x];
    CLLocation *location2 = [[CLLocation alloc]initWithLatitude:point2.y longitude:point2.x];
    return [location1 distanceFromLocation:location2];
}
-(int)sintWithNum:(int)i len:(int)len{
    if (i > len - 1) {
        return i - len;
    }
    if (i < 0) {
        return len + i;
    }
    return i;
}
-(AGSPoint *)createInlinePointWithPoint1:(AGSPoint *)point1 point2:(AGSPoint *)point2 y:(double)y{
 
    double s = point1.y - point2.y;
    double x;
    if (s > 0 ||s < 0) {
        x = (y - point1.y) * (point1.x - point2.x) / s + point1.x;
    }else {
        return nil;
    }
    
    /**判断x是否在p1,p2在x轴的投影里，不是的话返回null*/
    if (x > point1.x && x > point2.x) {
        return nil;
    }
    if (x < point1.x && x < point2.x) {
        return nil;
    }
    return AGSPointMakeWGS84(y, x);
}
@end
