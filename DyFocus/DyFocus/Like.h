//
//  Like.h
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Like: NSObject {
	NSString *m_fofId;
	NSString *m_userName;
	NSString *m_userId;
}

@property (nonatomic, retain) NSString *m_fofId;
@property (nonatomic, retain) NSString *m_userName;
@property (nonatomic, retain) NSString *m_userId;
@end
