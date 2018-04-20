//
//  VideoController.m
//  WolfEye
//
//  Created by Object Yan on 2018/4/17.
//  Copyright © 2018年 Object Yan. All rights reserved.
//

#import "VideoController.h"
#include <iostream>
#import <Photos/Photos.h>
using namespace cv;

@interface VideoController ()
@end

@implementation VideoController

@synthesize imageView;
@synthesize videoCamera;

- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
            break;
    }
}

- (void) viewDidLoad{
    [super viewDidLoad];
    
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    
    imageNum = 0;
    // Do any additional setup after loading the view, typically from a nib.
    videoCamera = [[CvVideoCamera alloc] init];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    [videoCamera setParentView:imageView];
    AVCaptureSession* session = videoCamera.captureSession;
    if([session canSetSessionPreset:AVCaptureSessionPreset3840x2160])
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset3840x2160;
    else if([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1920x1080;
    else if([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    else
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    [videoCamera.videoCaptureConnection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeCinematic];
    AVCaptureDeviceInput* autoDevice =  [[AVCaptureDeviceInput alloc] initWithDevice:[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject] error:nil];
    if([session canAddInput:autoDevice]){
        [session addInput: autoDevice];
    }
    
    //self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    //videoCamera.rotateVideo = YES;
    videoCamera.defaultFPS = 30;
    videoCamera.grayscaleMode = NO;
    [videoCamera start];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
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
    //UIImageWriteToSavedPhotosAlbum([self uIImageFromCVMat:image],self,nil,nil);
}

- (UIImage *)uIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}

@end
