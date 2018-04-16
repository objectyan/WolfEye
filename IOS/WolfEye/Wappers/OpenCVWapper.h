//
//  OpenCVWapper.h
//  WolfEye
//
//  Created by Object Yan on 2018/4/16.
//  Copyright © 2018年 Object Yan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OpenCVImage.h"
#import "OpenCVVideo.h"

@interface OpenCVWapper : NSObject
+(NSString *) openCVVersion;
+(void) imageByCVMat:(UIImageView *) img;
@end
