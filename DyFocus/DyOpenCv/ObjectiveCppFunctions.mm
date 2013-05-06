//
//  ObjectiveCppFunctions.m
//  dyOpencv
//
//  Created by Marcelo Salloum on 4/25/13.
//  Copyright (c) 2013 Marcelo Salloum. All rights reserved.
//

#import "ObjectiveCppFunctions.h"
#import "PointInfo.h"
#import "UIImageCVMatConverter.h"

@implementation ObjectiveCppFunctions

- (NSMutableArray*) warp2PicturesWithNSMutableArray:(NSMutableArray *)images{
    UIImage *image1 = [images objectAtIndex:0];
    UIImage *image2 = [images objectAtIndex:1];
    
    cv::Mat img_1 = [UIImageCVMatConverter cvMatFromUIImage:image1];
    cv::Mat img_2 = [UIImageCVMatConverter cvMatFromUIImage:image2];

    PointInfo *pointInfo = PointInfo::getInstance();
    pointInfo->warpPictures(img_1, img_2);

    image1 = [UIImageCVMatConverter UIImageFromCVMat:img_1];
    image2 = [UIImageCVMatConverter UIImageFromCVMat:img_2];
    
    img_1.release();
    img_2.release();
    
    NSMutableArray *warpedImages = [[NSMutableArray alloc] init];
    [warpedImages addObject:image1];
    [warpedImages addObject:image2];
    return warpedImages;
}
@end
