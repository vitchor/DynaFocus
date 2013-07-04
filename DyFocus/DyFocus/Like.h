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
	NSString *m_userFacebookId;
    NSString *m_uid;
    long m_userId;
}

@property (nonatomic, retain) NSString *m_uid;
@property (nonatomic, retain) NSString *m_fofId;
@property (nonatomic, retain) NSString *m_userName;
@property (nonatomic, retain) NSString *m_userFacebookId;
@property (nonatomic, readwrite) long m_userId;

@end
