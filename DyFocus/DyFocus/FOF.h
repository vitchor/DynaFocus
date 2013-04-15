//
//  FOF.h
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FOF : NSObject {
	NSString *m_name;
	NSArray *m_frames;
	NSString *m_comments;
	NSString *m_likes;
	NSString *m_userName;
	NSString *m_userNickname;
	NSString *m_date;
	NSString *m_id;
    bool m_liked;
}

+(FOF *)fofFromJSON: (NSDictionary *)json;

@property (nonatomic, retain) NSArray *m_frames;
@property (nonatomic, retain) NSString *m_comments;
@property (nonatomic, retain) NSString *m_name;
@property (nonatomic, retain) NSString *m_likes;
@property (nonatomic, retain) NSString *m_userName;
@property (nonatomic, retain) NSString *m_userNickname;
@property (nonatomic, retain) NSString *m_userId;
@property (nonatomic, retain) NSString *m_date;
@property (nonatomic, retain) NSString *m_id;
@property (nonatomic, readwrite) bool m_liked;
@end

