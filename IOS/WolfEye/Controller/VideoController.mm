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
@synthesize imageArr;

- (void) viewDidLoad{
    [super viewDidLoad];
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
    videoCamera.rotateVideo = YES;
    videoCamera.defaultFPS = 30;
    videoCamera.grayscaleMode = NO;
    [videoCamera start];
    NSTimer* timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)timerAction{
    NSMutableArray* cloneArrImage = (NSMutableArray*)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                                                                                    (CFPropertyListRef)self->imageArr, kCFPropertyListMutableContainers));
    [self->imageArr removeAllObjects];
    [self imageArraryToVideo:cloneArrImage];
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
    [imageArr addObject:[self uIImageFromCVMat:image]];
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

- (void) imageArraryToVideo:(NSMutableArray*)imageArr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd-HH-mm"];
    NSString* moviePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/WolfEye/"] stringByAppendingPathComponent:[NSString stringWithFormat:@"WolfEye-Video-%@",[formatter stringFromDate:[NSDate date]]]];
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:moviePath]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error = %@", [error localizedDescription]);
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:videoCamera.imageWidth], AVVideoWidthKey,
                                   [NSNumber numberWithInt:videoCamera.imageHeight], AVVideoHeightKey, nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    if ([videoWriter canAddInput:writerInput])
        NSLog(@"start");
    [videoWriter addInput:writerInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    dispatch_queue_t dispatchQueue = dispatch_queue_create("record", NULL);
    int __block frame = 0;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        CVPixelBufferRef buffer = NULL;
        while ([writerInput isReadyForMoreMediaData])
        {
            if([imageArr count] == 0)
            {
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    UISaveVideoAtPathToSavedPhotosAlbum (moviePath,nil,nil, nil);
                }];
                if (buffer)
                {
                    CFRelease(buffer);
                    buffer = NULL;
                }
                break;
            }
            else
            {
                if (buffer==NULL)
                {
                    buffer = [self imageToCVPixelBufferRef:[[imageArr objectAtIndex:0] CGImage]];
                }
                if (buffer)
                {
                    CFAbsoluteTime interval = (30 - [imageArr count]) * 50.0;
                    CMTime currentSampleTime = CMTimeMake((int)interval, 1000);
                    if([adaptor appendPixelBuffer:buffer withPresentationTime:currentSampleTime])
                    {
                        ++frame;
                        [imageArr removeObjectAtIndex:0];
                        CFRelease(buffer);
                        buffer = NULL;
                    }
                }
            }
        }
    }];
}

- (CVPixelBufferRef) imageToCVPixelBufferRef:(CGImageRef)image{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

@end
