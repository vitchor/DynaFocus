//
//  DyOpenCv.m
//  DyOpenCv
//
//  Created by Marcelo Salloum on 4/26/13.
//  Copyright (c) 2013 Marcelo Salloum. All rights reserved.
//

#import "DyOpenCv.h"
#import "AntiShake.h"
#import "UIImageCVMatConverter.h"


@implementation DyOpenCv

- (NSMutableArray*) antiShake:(NSMutableArray *)images{
    UIImage *image1 = [images objectAtIndex:0];
    UIImage *image2 = [images objectAtIndex:1];
    
    cv::Mat img_1 = [UIImageCVMatConverter cvMatFromUIImage:image1];
    cv::Mat img_2 = [UIImageCVMatConverter cvMatFromUIImage:image2];

    AntiShake *antiShake = AntiShake::getInstance();
    antiShake->antiShake(img_1, img_2);
    
    NSLog(@"==== FINISHED ANTISHAKE");
    UIImage *image3= [UIImageCVMatConverter UIImageFromCVMat:img_1 withOrientation:image1.imageOrientation];
    UIImage *image4= [UIImageCVMatConverter UIImageFromCVMat:img_2 withOrientation:image2.imageOrientation];
    NSLog(@"==== FINISHED CONVERSION");
//    
//    img_1.release();
//    img_2.release();

     
    NSMutableArray *warpedImages = [[NSMutableArray alloc] init];
    [warpedImages addObject:image3];
    [warpedImages addObject:image4];
    return warpedImages;
}
@end
