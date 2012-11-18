//
//  NSString+ParsingExtensions.h
//  Ubercab Client
//
//  Created by Joris Kluivers on 5/29/09.
//  Copyright 2009 Tarento Software Solutions & Projects. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Taken from: http://www.macresearch.org/cocoa-scientists-part-xxvi-parsing-csv-data
*/

@interface NSString (ParsingExtensions)

-(NSArray *) csvRows;

@end
