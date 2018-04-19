//
//  VideoController.h
//  WolfEye
//
//  Created by Object Yan on 2018/4/17.
//  Copyright © 2018年 Object Yan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>

@interface VideoController : UIViewController<CvVideoCameraDelegate>
{
    CvVideoCamera* videoCamera;
    NSMutableArray* imageArr;
}
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSDictionary *options;


@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@end
