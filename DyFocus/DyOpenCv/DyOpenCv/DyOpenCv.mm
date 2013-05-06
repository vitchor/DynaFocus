//
//  DyOpenCv.m
//  DyOpenCv
//
//  Created by Marcelo Salloum on 4/26/13.
//  Copyright (c) 2013 Marcelo Salloum. All rights reserved.
//

#import "DyOpenCv.h"
#import "PointInfo.h"
#import "UIImageCVMatConverter.h"


@implementation DyOpenCv

- (NSMutableArray*) warp2PicturesWithNSMutableArray:(NSMutableArray *)images{
    UIImage *image1 = [images objectAtIndex:0];
    UIImage *image2 = [images objectAtIndex:1];
    
    cv::Mat img_1 = [UIImageCVMatConverter cvMatFromUIImage:image1];
    cv::Mat img_2 = [UIImageCVMatConverter cvMatFromUIImage:image2];

    PointInfo *pointInfo = PointInfo::getInstance();
    pointInfo->warpPictures(img_1, img_2);
    UIImage *image3= [[UIImage alloc] initWithCGImage:[[UIImageCVMatConverter UIImageFromCVMat:img_1] CGImage]];
    UIImage *image4= [[UIImage alloc] initWithCGImage:[[UIImageCVMatConverter UIImageFromCVMat:img_1] CGImage]];
//    UIImage *image3= [[UIImage alloc] initWithCGImage: [[UIImageCVMatConverter UIImageFromCVMat:img_1] CGImage] scale:1.0 orientation:[image1 imageOrientation]];
//    UIImage *image4= [[UIImage alloc] initWithCGImage: [[UIImageCVMatConverter UIImageFromCVMat:img_2] CGImage] scale:1.0 orientation:[image2 imageOrientation]];
    
    img_1.release();
    img_2.release();
    
    NSMutableArray *warpedImages = [[NSMutableArray alloc] init];
    [warpedImages addObject:image3];
    [warpedImages addObject:image4];
    return warpedImages;
}
@end
