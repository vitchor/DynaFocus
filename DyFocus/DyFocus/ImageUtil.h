//
//  ImageUtil.h
//  DyFocus
//
//  Created by Victor Oliveira on 11/9/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtil : NSObject

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
