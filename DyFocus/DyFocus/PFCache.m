//
//  PFCache.m
//  Photofriend
//
//  Created by Jordan Bonnet on 12/10/12.
//  Copyright (c) 2012 Jordan Bonnet. All rights reserved.
//

#import "PFCache.h"

@interface PFCache ()
+ (NSString *)_cachePath;
@end

@implementation PFCache

+ (PFCache *)sharedCache
{
    static PFCache *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[PFCache alloc] init];
    }
    return sharedInstance;
}

+ (NSString *)localPhotoPath:(NSString *)filename
{
    return [[PFCache _cachePath] stringByAppendingPathComponent:filename];
}

+ (NSString *)localThumbnailPath:(NSString *)filename
{
    return [[PFCache _cachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb-%@", filename]];
}

- (UIImage *)imageForLocalPath:(NSString *)localPath
{
    return [UIImage imageWithContentsOfFile:localPath];
}

- (void)cacheImage:(UIImage *)image forFilename:(NSString *)filename
{
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:[PFCache localPhotoPath:filename] atomically:YES];
    [data writeToFile:[PFCache localThumbnailPath:filename] atomically:YES];
}

#pragma mark Internals

+ (NSString *)_cachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return cachePath;
}

@end
