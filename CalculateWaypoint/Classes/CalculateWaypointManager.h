//
//  CalculateWaypointClass.h
//  CalculateWaypoint
//
//  Created by Taylor on 2019/6/29.
//  Copyright © 2019 Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(NSUInteger, StartPosition) {
    StartPositionHome                = 0,
    StartPositionBottomLeft          = 1,
    StartPositionBottomRight         = 2,
    StartPositionTopLeft             = 3,
    StartPositionTopRight             = 4
};

@class AGSPoint,CameraParameters;
NS_ASSUME_NONNULL_BEGIN
typedef void(^CalculateLineCompeleteBlock)(NSArray<AGSPoint *>*resultArray);
@interface CalculateWaypointManager : NSObject
@property(nonatomic,assign)double alt;
@property(nonatomic,assign)int dist;
@property(nonatomic,assign)int spac;

@property(nonatomic,assign)double cal_distance;
@property(nonatomic,assign)double cal_lineSpace;

@property(nonatomic,assign)double ang;
@property(nonatomic,strong)CameraParameters *camera;
/**
 航线条数
 */
@property(nonatomic,assign)int routeNumber;
@property(nonatomic,assign)NSInteger startDirection;
@property(nonatomic,strong)NSArray <AGSPoint *>*ploygonPoints;

-(void)configDataWithPloygon:(NSArray<AGSPoint *> *)polygon altitude:(double)altitude distance:(int)distance spacing:(int)spacing angle:(double)angle cameraID:(NSInteger)cameraID start:(NSInteger)startPoint complete:(nonnull CalculateLineCompeleteBlock)complete;
/**
 开始计算
 */
-(void)startCalculate;
/**
 停止计算
 */
-(void)stopCalculate;

//-(NSArray <AGSPoint *>*)calculateWayPointWithPolygon:(NSArray <AGSPoint *>*)polygon cameraParameters:(CameraParameters *)cameraParameters pang:(int)pang hang:(int)hang alt: (double)alt angle:(double)angle startpos:(StartPosition)startpos;
@end

NS_ASSUME_NONNULL_END
