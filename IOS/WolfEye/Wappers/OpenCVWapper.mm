//
//  OpenCVWapper.m
//  WolfEye
//
//  Created by Object Yan on 2018/4/16.
//  Copyright © 2018年 Object Yan. All rights reserved.
//

#import "OpenCVWapper.h"

@implementation OpenCVWapper
+ (NSString *) openCVVersion{
    return [NSString stringWithFormat:@"%s",CV_VERSION];
}

+ (void) imageByCVMat:(UIImageView *) img {
    OpenCVImage *a = [[OpenCVImage alloc] init];
    [a imageByCVMat:img];
}
@end
