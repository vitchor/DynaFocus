//
//  FIlterUtil.m
//  DyFocus
//
//  Created by Victor on 3/30/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FilterUtil.h"
#import "GPUImage.h"

#define FILTER_NONE 0
#define FILTER_SEPIA 1
#define FILTER_BLUE_AND_RED_COLORS 2
#define FILTER_INVERT_COLORS 3
#define FILTER_TOON 4
#define FILTER_SKETCH 5
#define FILTER_EDGE_DETECTION 6

@implementation FilterUtil 


+(int) getFiltersSize {
    return 7;
}
    
+ (NSString *) getFilterName: (int)filter {
    
    NSString *filterName = @"";
    
    if (filter == FILTER_NONE) {
        filterName = @"None";
        
    } else if (filter == FILTER_SEPIA) {
        filterName = @"Sepia";
        
    } else if (filter == FILTER_SKETCH) {
        filterName = @"Sketch";
        
    } else if (filter == FILTER_INVERT_COLORS) {
        filterName = @"Invert";
        
    } else if (filter == FILTER_EDGE_DETECTION) {
        filterName = @"Edges";
        
    } else if (filter == FILTER_BLUE_AND_RED_COLORS) {
        filterName = @"Warm";
        
    } else if (filter == FILTER_TOON) {
        filterName = @"Toon";        
    }
    
    return filterName;
    
}

+ (UIImage *)filterImage: (UIImage *)image withFilterId: (int)filterId {
    
    UIImage *filteredImage;

    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageFilter *stillImageFilter = nil;
    

    if (filterId == FILTER_NONE) {
        return image;
        
    } else if (filterId == FILTER_SEPIA) {
        stillImageFilter = [[GPUImageSepiaFilter alloc] init];
        
    } else if (filterId == FILTER_SKETCH) {
        stillImageFilter = [[GPUImageSketchFilter alloc] init];
        
    } else if (filterId == FILTER_INVERT_COLORS) {
        stillImageFilter = [[GPUImageColorInvertFilter alloc] init];
        
    } else if (filterId == FILTER_EDGE_DETECTION) {
        stillImageFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
        
    } else if (filterId == FILTER_BLUE_AND_RED_COLORS) {
        stillImageFilter = [[GPUImageFalseColorFilter alloc] init];
        
    } else if (filterId == FILTER_TOON) {
        stillImageFilter = [[GPUImageToonFilter alloc] init];
    }
    
    [stillImageSource addTarget:stillImageFilter];
    [stillImageSource processImage];
        
    filteredImage = [stillImageFilter imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
        
    return filteredImage;    
}


@end
