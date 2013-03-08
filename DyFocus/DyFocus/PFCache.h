//
//  PFCache.h
//  Photofriend
//
//  Created by Jordan Bonnet on 12/10/12.
//  Copyright (c) 2012 Jordan Bonnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFCache : NSCache

+ (PFCache *)sharedCache;
+ (NSString *)localPhotoPath:(NSString *)filename;
+ (NSString *)localThumbnailPath:(NSString *)filename;

- (UIImage *)imageForLocalPath:(NSString *)localPath;
- (void)cacheImage:(UIImage *)image forFilename:(NSString *)filename;

@end
