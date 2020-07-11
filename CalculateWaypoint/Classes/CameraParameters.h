//
//  CameraParameters.h
//  CalculateWaypoint
//
//  Created by Taylor on 2020/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraParameters : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSInteger cameraID;
@property(nonatomic,assign)float cmosWidth;
@property(nonatomic,assign)float cmosHeight;
@property(nonatomic,assign)float focalLength;
@property(nonatomic,assign)float actualWidth;
@property(nonatomic,assign)float actualHeight;
/**
 根据相机获取实际宽高

 @param altitude 高度
 @return 实际宽高
 */
-(CGSize)getActualRangeWithAltitude:(double)altitude;
-(double)getOffsetValueWithActualValue:(double) actualValue percent:(double)percent;
@end

NS_ASSUME_NONNULL_END
