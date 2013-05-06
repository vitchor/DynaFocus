//
//  UIImageCVMatConverter.h
//

#import <Foundation/Foundation.h>

@interface UIImageCVMatConverter : NSObject {
    
}

+ (UIImage *)UIImageFromCVMat:(const cv::Mat&)cvMat;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat withUIImage:(UIImage*)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image;

@end