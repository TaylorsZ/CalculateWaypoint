//
//  CameraParameters.m
//  CalculateWaypoint
//
//  Created by Taylor on 2019/6/29.
//  Copyright © 2019 Taylor. All rights reserved.
//

#import "CameraParameters.h"



@implementation CameraParameters

-(void)setCameraID:(NSInteger)cameraID{
    #warning 根据相机赋值
    switch (cameraID) {
        case 1:{
             _cmosWidth = 16;
             _cmosHeight = 3.6;
             _focalLength = 8.8;
            
            break;
        }
        default:{
            _cmosWidth = 16;
            _cmosHeight = 3.6;
            _focalLength = 8.8;
            break;
        }
    }
    
}
-(CGSize)getActualRangeWithAltitude:(double)altitude{

 
    double actualWidth = altitude * _cmosWidth / _focalLength;
    double actualHeight = altitude*_cmosHeight/_focalLength;
    return  CGSizeMake(actualWidth, actualHeight);
}
-(double)getOffsetValueWithActualValue:(double)actualValue percent:(double)percent{
    if (percent == 0){
        return actualValue;
    }
    return actualValue * ((100-percent) / 100);
}
@end
