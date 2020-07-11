//
//  CalculateRouteUtils.h
//  CalculateWaypoint
//
//  Created by Taylor on 2019/6/29.
//  Copyright © 2019 Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AGSPoint;
@interface CalculateRouteUtils : NSObject
/**
 西北
 */
@property(nonatomic,strong)AGSPoint *wnPoint;
/**
 东北
 */
@property(nonatomic,strong)AGSPoint *enPoint;
/**
 东南
 */
@property(nonatomic,strong)AGSPoint *esPoint;
/**
 西南
 */
@property(nonatomic,strong)AGSPoint *wsPoint;
/**
 中心点
 */
@property(nonatomic,strong)AGSPoint *centerPoint;
/**
 得到矩形各点坐标

 @param points 坐标点
 */
-(void)createPolygonBoundsWithPoints:(NSArray <AGSPoint *>*)points;
/**创建一个旋转后的多边形*/
-(NSArray<AGSPoint *>*)createRotatePolygonWithmLatlists:(NSArray <AGSPoint *>*)mLatlists  rotate:(int)rotate;

/**计算有多少条纬度线穿过 纬度线相差lat*/
-(CGPoint)createLatsWithSpace:(int)space;
/**防止索引溢出*/
-(int)sintWithNum:(int)i len:(int)len;
/**计算纬度线 与边缘线的交点*/
-(AGSPoint *)createInlinePointWithPoint1:(AGSPoint *)point1 point2:(AGSPoint *)point2 y:(double)y;
@end

NS_ASSUME_NONNULL_END
