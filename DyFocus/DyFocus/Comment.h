//
//  Comment.h
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment: NSObject {
    NSString *m_uid;
	NSString *m_fofId;
	NSString *m_message;
	NSString *m_userName;
	NSString *m_userFacebookId;
	NSString *m_date;
    long m_userId;
}

@property (nonatomic, retain) NSString *m_fofId;
@property (nonatomic, retain) NSString *m_message;
@property (nonatomic, retain) NSString *m_userName;
@property (nonatomic, retain) NSString *m_userFacebookId;
@property (nonatomic, retain) NSString *m_date;
@property (nonatomic, retain) NSString *m_uid;
@property (nonatomic, readwrite) long m_userId;
@end