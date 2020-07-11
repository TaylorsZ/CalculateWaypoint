//
//  CalculateWaypointClass.m
//  CalculateWaypoint
//
//  Created by Taylor on 2019/6/29.
//  Copyright © 2019 Taylor. All rights reserved.
//

#import "CalculateWaypointManager.h"
#import <CoreLocation/CLLocation.h>
#import "CameraParameters.h"
#import "CalculateRouteUtils.h"
#import <ArcGIS/ArcGIS.h>


@interface CalculateWaypointManager ()

@property(nonatomic,strong)NSOperationQueue *calQueue;//计算航线队列

@property(nonatomic,copy)CalculateLineCompeleteBlock resultB;
@property(nonatomic,strong)NSArray *calculatePoints;
@end
@implementation CalculateWaypointManager


#pragma mark - event
-(void)stopCalculate{
    [self.calQueue cancelAllOperations];
}
-(void)startCalculate{
    //    [self.calQueue cancelAllOperations];
    NSInvocationOperation *calOp1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(doCal:) object:nil];
    __weak typeof(self) weakSelf = self;
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 回到主线程执行，更新UI
            NSLog(@"计算完成，等待处理");
            if (strongSelf.resultB) {
                strongSelf.resultB(strongSelf.calculatePoints);
            }
        }];
    }];
    [completionOperation addDependency:calOp1];
    [self.calQueue addOperation:calOp1];
    [self.calQueue addOperation:completionOperation];
}
-(void)doCal:(NSInvocationOperation *)sender{
    
    
    
    [self calculateWayPointWithPolygon:self.ploygonPoints cameraParameters:self.camera pang:self.spac hang:self.dist alt:self.alt angle:self.ang];
    
    
}
#pragma mark - 配置参数
-(void)configDataWithPloygon:(NSArray<AGSPoint *> *)polygon altitude:(double)altitude distance:(int)distance spacing:(int)spacing angle:(double)angle cameraID:(NSInteger)cameraID start:(NSInteger)startPoint complete:(nonnull CalculateLineCompeleteBlock)complete{
    self.ploygonPoints = polygon;
    self.alt = altitude;
    self.ang =angle;
    self.dist = distance;
    self.spac = spacing;
    self.camera.cameraID = cameraID;
    self.startDirection = startPoint;
    _resultB = [complete copy];
}

#pragma mark - 算法
-(void)calculateWayPointWithPolygon:(NSArray <AGSPoint *>*)polygon cameraParameters:(CameraParameters *)cameraParameters pang:(int)pang hang:(int)hang alt: (double)alt angle:(double)angle{
    
    //根据高度计算真实距离
    CGSize actualRange =  [cameraParameters getActualRangeWithAltitude:alt];
    double distance = [cameraParameters getOffsetValueWithActualValue:actualRange.height percent:pang];
    double spacing = [cameraParameters getOffsetValueWithActualValue:actualRange.width percent:hang];
    
    self.cal_distance =  distance;
    self.cal_lineSpace = spacing;
    //旁向 d
    NSLog(@"pang: %d----hang: %d----distance: %f---spacing: %f",pang,hang,distance,spacing);
    
    //实例化航线计算单元
    CalculateRouteUtils * mBoundsEWSNLatLng = [[CalculateRouteUtils alloc]init];
    //根据给出的坐标点计算中心点及四个边框的点坐标
    [mBoundsEWSNLatLng createPolygonBoundsWithPoints:polygon];
    //绘制航线
    NSArray<AGSPoint *>*polylines = [self drawOricFlyLinesWithRouteUtils:mBoundsEWSNLatLng polygon:polygon];
    
    NSArray <AGSPoint *>*mListPolylines = [mBoundsEWSNLatLng createRotatePolygonWithmLatlists:polylines rotate:angle];
    
    self.calculatePoints = mListPolylines;
}
-(NSArray <AGSPoint *>*)drawOricFlyLinesWithRouteUtils:(CalculateRouteUtils*)routeUtils polygon:(NSArray <AGSPoint *>*)polygon{
    
    //创建变换后的多边形
    NSArray <AGSPoint *>*rPolygons = [routeUtils createRotatePolygonWithmLatlists:polygon rotate:-self.ang];
    
    CalculateRouteUtils *mRBoundsEWSNLatLng = [[CalculateRouteUtils alloc]init];
    [mRBoundsEWSNLatLng createPolygonBoundsWithPoints:rPolygons];
    
    //    CGPoint latlines = [mRBoundsEWSNLatLng createLatsWithSpace:self.cal_distance];
    
    
    int steps = 0;
    double linelat = 0.f;
    
    //线条数量
    steps = ((int)[self getDistanceWithPoint:mRBoundsEWSNLatLng.wnPoint point2:mRBoundsEWSNLatLng.wsPoint] / (int)self.cal_distance);
    self.routeNumber = steps;
    //纬度差
    linelat = (mRBoundsEWSNLatLng.wnPoint.y - mRBoundsEWSNLatLng.wsPoint.y) / (int)steps;
    
    
    
    NSMutableArray <AGSPoint *>*polylines = [NSMutableArray array];
    //遍历每一条纬度线
    for (int i = 1; i < steps + 1; i++) {
        NSMutableArray<AGSPoint *>* lines = [NSMutableArray array];
        double fen = linelat / 3 * 2;
        //遍历每一个多边形顶点
        for (int j = 0; j < rPolygons.count; j++) {
            int si = [mRBoundsEWSNLatLng sintWithNum:j+1 len:(int)rPolygons.count];
            
            double y =0.f;
            y = mRBoundsEWSNLatLng.wnPoint.y+ fen - i * linelat;
            AGSPoint *checklatlng =[mRBoundsEWSNLatLng createInlinePointWithPoint1:rPolygons[j] point2:rPolygons[si] y:y];
            
            if (checklatlng) {
                [lines addObject:checklatlng];
            }
        }
        //去掉只有一个交点的纬度线
        if (lines.count < 2) {
            continue;
        }
        //去掉两个交点重合的纬度线
        if (lines.firstObject == lines[1]) {
            continue;
        }
        
        double min2 = MIN(lines[0].x, lines[1].x);
        double max1 = MAX(lines[0].x, lines[1].x);
        
        if (i % 2 == 0) {
            AGSPoint *latLng1 = AGSPointMakeWGS84(lines[0].y, min2);
            AGSPoint *latLng2 = AGSPointMakeWGS84(lines[0].y, max1);
            [polylines addObject:latLng1];
            [polylines addObject:latLng2];
            
        } else {
            AGSPoint *latLng1 = AGSPointMakeWGS84(lines[0].y, max1);
            AGSPoint *latLng2 =  AGSPointMakeWGS84(lines[0].y, min2);
            [polylines addObject:latLng1];
            [polylines addObject:latLng2];
        }
        
    }
    return polylines;
}
-(CLLocationDistance)getDistanceWithPoint:(AGSPoint *)point1 point2:(AGSPoint *)point2{
    AGSGeodeticDistanceResult* geometryDistance = [AGSGeometryEngine geodeticDistanceBetweenPoint1:point1 point2:point2 distanceUnit:[AGSLinearUnit meters] azimuthUnit:[AGSAngularUnit degrees] curveType:AGSGeodeticCurveTypeGeodesic];
    return geometryDistance.distance;
}
#pragma mark - lazy
-(NSArray *)calculatePoints{
    if (!_calculatePoints) {
        _calculatePoints = [NSArray array];
    }
    return _calculatePoints;
}
-(NSOperationQueue *)calQueue{
    if (!_calQueue) {
        _calQueue = [[NSOperationQueue alloc]init];
    }
    return _calQueue;
}
-(CameraParameters *)camera{
    if (!_camera) {
        _camera = [CameraParameters new];
    }
    return _camera;
}
@end
