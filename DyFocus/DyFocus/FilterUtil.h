//
//  FIlterUtil.h
//  DyFocus
//
//  Created by Victor on 3/30/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterUtil : NSObject

+ (int) getFiltersSize;

+ (NSString *) getFilterName: (int)filter;

+ (UIImage *)filterImage: (UIImage *)image withFilterId: (int)filterId;

@end
