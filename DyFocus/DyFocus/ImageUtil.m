//
//  ImageUtil.m
//  DyFocus
//
//  Created by Victor Oliveira on 11/9/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "ImageUtil.h"

@implementation ImageUtil

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
