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
    cv::Mat H = antiShake->fixPictures(img_1, img_2, 1);
    
    // Transforming data from mat to std::string. Later it will become the NSMutableString
    cv::Mat eigenvalues;
    eigen(H, eigenvalues);
	std::stringstream bufferMatrix, bufferEigenvalues;
	bufferMatrix << H;
    bufferEigenvalues << eigenvalues;

    NSString *matrixValues = [NSString stringWithFormat:@"\n MATRIX: \n %@ \n DET(H) = %f \n Eigenvalues = %@", [NSString stringWithCString:bufferMatrix.str().c_str() encoding:NSASCIIStringEncoding], cv::determinant(H), [NSString stringWithCString:bufferEigenvalues.str().c_str() encoding:NSASCIIStringEncoding]];
    
    NSLog(@"==== FINISHED ANTISHAKE");
    UIImage *image3= [UIImageCVMatConverter UIImageFromCVMat:img_1 withOrientation:image1.imageOrientation];
    UIImage *image4= [UIImageCVMatConverter UIImageFromCVMat:img_2 withOrientation:image2.imageOrientation];
    NSLog(@"==== FINISHED CONVERSION");

    //    [image1 release], image1 = image3;
    //    [image2 release], image2 = image4;
    
    img_1.release();
    img_2.release();
    
    NSMutableArray *warpedImages = [[[NSMutableArray alloc] init] autorelease];
    [warpedImages addObject:image3];
    [warpedImages addObject:image4];
    [warpedImages addObject:matrixValues];
    
    return warpedImages;
}
@end
