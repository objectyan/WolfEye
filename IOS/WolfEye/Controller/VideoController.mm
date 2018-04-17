//
//  VideoController.m
//  WolfEye
//
//  Created by Object Yan on 2018/4/17.
//  Copyright © 2018年 Object Yan. All rights reserved.
//

#import "VideoController.h"
#include <iostream>
using namespace cv;

@interface VideoController ()

@end

@implementation VideoController

@synthesize imageView;
@synthesize videoCamera;

- (void) viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    
    AVCaptureSession* session = videoCamera.captureSession;
    if([session canSetSessionPreset:AVCaptureSessionPreset3840x2160])
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset3840x2160;
    else if([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1920x1080;
    else if([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    else
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    
    videoCamera.defaultFPS = 60;
    videoCamera.grayscaleMode = NO;
    [videoCamera start];
    
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (void) timerAction{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd-HH-mm"];
    NSString *currentTimeString = [formatter stringFromDate:[NSDate date]];
    NSString *filename = [NSString stringWithFormat:@"%@.mp4",currentTimeString];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videoPath = [NSString stringWithFormat:@"%@/Video", pathDocuments];
    
    NSString *filePath = [videoPath stringByAppendingPathComponent:filename];
    NSLog(@"%@", filePath);
    //    [videoCamera videoFileString:[videoPath stringByAppendingPathComponent:filename]];
    
    //    NSLog(videoCamera.videoFileString);
    //    [videoCamera saveVideo];
    //    NSLog(@"Save Video");
}

- (void)processImage:(cv::Mat &)image {
    Mat imageGrey;
    cvtColor(image, imageGrey, CV_RGBA2GRAY);
    Mat imageSobel;
    Laplacian(imageGrey, imageSobel, CV_64F);
    //Sobel(imageGrey, imageSobel, CV_64F, 1, 1);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *currentTimeString = [formatter stringFromDate:[NSDate date]];
    putText(image, [currentTimeString UTF8String], CvPoint(0, int(image.rows-image.cols/image.rows * 3)),
            CV_FONT_HERSHEY_SCRIPT_COMPLEX,image.cols/image.rows, cvScalar(200, 200, 200, 0));
}

@end
