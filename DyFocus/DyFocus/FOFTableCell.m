//
//  FOFTableCell.m
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FOFTableCell.h"
#import "CommentViewerController.h"

@implementation FOFTableCell

@synthesize row, descriptionFullText, descriptionPreviewText, tableView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"FOFTableCell" owner:nil options:nil];
    for ( id item in objs )
        if ( [item isKindOfClass:[FOFTableCell class]] ) {
            [self release];
            self = item;
            break;
        }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"FOFTableCell" owner:nil options:nil];
    for ( id item in objs )
        if ( [item isKindOfClass:[FOFTableCell class]] ) {
            [self release];
            self = item;
            break;
        }
    return self;
}

-(void)sendFrameRequest:(NSDyfocusURLRequest *)request {
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if(!error && data && request.id == fof.m_id) {
                                   
                                   UIDyfocusImage *image = [[[UIDyfocusImage alloc] initWithData:data] autorelease];
                                   
                                   
                                   if (image) {
                                       
                                       image.index = request.tag;
                                       
                                       [frames addObject:image];
                                       
                                       float scale = image.size.height / image.size.width;
                                       
                                       newImageHeight = imagebackFrame.frame.size.width * scale;
                                       
                                       newDescriptionHeight = [self calculateNewDescriptionHeight];
                                       
                                       float newCellHeight = HEADER_AND_FOOTER_HEIGHT + newImageHeight + newDescriptionHeight;
                                       
                                       [self.tableView addNewCellHeight:newCellHeight atRow:self.row];
                                       
                                       imagebackFrame.frame = CGRectMake(imagebackFrame.frame.origin.x,
                                                                         imagebackFrame.frame.origin.y , imagebackFrame.frame.size.width, newImageHeight);
                                       
                                       //imagebackFrame.clipsToBounds = YES;
                                       newImageHeight = imagefrontFrame.frame.size.width * scale;
                                       imagefrontFrame.frame = CGRectMake(imagefrontFrame.frame.origin.x,
                                                                          imagefrontFrame.frame.origin.y, imagefrontFrame.frame.size.width, newImageHeight);
                                       
                                       supportView.frame = CGRectMake(supportView.frame.origin.x,
                                                                      supportView.frame.origin.y, supportView.frame.size.width, newImageHeight);
                                       
                                       playPauseButton.center = CGPointMake(playPauseButton.center.x, newImageHeight + PLAY_PAUSE_BUTTON_OFFSET);
                                       
                                       descriptionLabel.frame = CGRectMake(descriptionLabel.frame.origin.x,
                                                                           newImageHeight + DESCRIPTION_LABEL_OFFSET,
                                                                           descriptionLabel.frame.size.width,
                                                                           newDescriptionHeight);
                                       
                                       
                                       readMoreLabel.frame = CGRectMake(readMoreLabel.frame.origin.x,
                                                                        newImageHeight + DESCRIPTION_LABEL_OFFSET + READMORE_LABEL_OFFSET,
                                                                        readMoreLabel.frame.size.width,
                                                                        readMoreLabel.frame.size.height);
                                       
                                       if ([frames count] == [fofUrls count]) {
                                           
                                           [frames sortUsingFunction:sortByIndex context:nil];
                                           
                                           [self startTimer];
                                       }
                                       
                                   } else {
                                       [self sendFrameRequest:request];
                                   }
                               } else {
                                   [self sendFrameRequest:request];
                               }
                           }];
}

- (void)loadUserProfile:(UIGestureRecognizer *)gestureRecognizer
{
    
    if(self.tableView.userId){
        NSLog(@"==== U ARE already inside this person's profile");
    }else{
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        ProfileController *profileController = nil;
        
        Person *person;
        if(fof.m_userId == delegate.myself.uid){
            person = delegate.myself;
        }else{
            person = [delegate getUserWithId:fof.m_userId];
        }
        
        if (person) {
            // Person exists, so it's being followed.
            NSMutableArray *userFOFArray = [delegate FOFsFromUser:person.uid];
            profileController = [[ProfileController alloc] initWithPerson:person personFOFArray:userFOFArray];
            
        } else {
            // Person is not being followed, there's no information we can get.
            profileController = [[ProfileController alloc] initWithUserId:fof.m_userId];
        }
        profileController.hidesBottomBarWhenPushed = YES;
        
        [self.tableView.navigationController pushViewController:profileController animated:YES];
        [self.tableView.navigationController setNavigationBarHidden:NO animated:TRUE];
        [profileController release];
    }
}

-(void) deleteFOFClicked:(UIGestureRecognizer *)gestureRecognizer
{
    NSString *alertTitle = @"Delete?";
    NSString *alertMsg =@"You're about to delete this picture. Are you sure?";
    NSString *alertButton1 = @"Yes";
    NSString *alertButton2 =@"No";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton1 otherButtonTitles:nil] autorelease];
    [alert setTag:1];
    [alert addButtonWithTitle:alertButton2];
    [alert show];
    
    [alertTitle release];
    [alertMsg release];
    [alertButton1 release];
    [alertButton2 release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 0) {
            [self eraseFOF];
        }
    }
}

-(void) eraseFOF {
    [LoadView loadViewOnView:self.tableView.view withText:@"Deleting..."];
    
    NSString *newCount = [[[NSString alloc] initWithFormat:@"%d", [likesCountLabel.text intValue] + 1] autorelease];
    [likesCountLabel setText:newCount];
    
    NSString *imageUrl = [[[NSString alloc] initWithFormat:@"%@/uploader/delete_fof/",dyfocus_url] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    
    NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
    
    [jsonRequestObject setObject:fof.m_id forKey:@"fof_id"];
    
    NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                           json] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(!error && data) {
                                   AppDelegate *delegate = [UIApplication sharedApplication].delegate;
                                   [delegate refreshAllFOFTables];
                                   
                                   [LoadView fadeAndRemoveFromView:self.tableView.view];
                               }
                           }];
}

- (void)singleTapOnFOF:(UIGestureRecognizer *)gestureRecognizer
{
    if(frames.count >=1){
        
        [supportView setUserInteractionEnabled:NO];
        
        FullscreenFOFViewController *fullScreenController = [[FullscreenFOFViewController alloc] initWithNibName:@"FullscreenFOFViewController" bundle:nil];
        
        fullScreenController.hidesBottomBarWhenPushed = YES;
        
        fullScreenController.frames = frames;
        
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration:0.80];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIView setAnimationTransition:
         UIViewAnimationTransitionFlipFromRight
                               forView:self.tableView.navigationController.view cache:NO];
        
        
        [self.tableView.navigationController pushViewController:fullScreenController animated:YES];
        [UIView commitAnimations];
        
        [fullScreenController release];
        
    }
}

-(void) expandDescriptionLabel:(UIGestureRecognizer *)gestureRecognizer
{
    if(!readMoreLabel.isHidden){
        
        [descriptionLabel setText:self.descriptionFullText];
        
        CGSize maxDescriptionFrameSize = CGSizeMake(descriptionLabel.frame.size.width, MAX_FRAME_HEIGHT);
        
        CGSize descriptionTextSize = [descriptionLabel.text sizeWithFont:descriptionLabel.font
                                                       constrainedToSize:maxDescriptionFrameSize
                                                           lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat descriptionTextHeight = descriptionTextSize.height;
        
        newDescriptionHeight = descriptionTextHeight;
        
        float newCellHeight = HEADER_AND_FOOTER_HEIGHT + newImageHeight + newDescriptionHeight;
        
        [self.tableView addNewCellHeight: newCellHeight atRow:self.row];
        
        [descriptionLabel setUserInteractionEnabled:YES];
        
        [self refreshImageSize];
        
        [UIView animateWithDuration:0.5 animations:^{
            readMoreLabel.alpha = 0.0;
            
            readMoreLabel.frame = CGRectMake(readMoreLabel.frame.origin.x + 200,
                                             readMoreLabel.frame.origin.y + 200,
                                             readMoreLabel.frame.size.width,
                                             readMoreLabel.frame.size.height);
        }completion:^(BOOL finished) {
            [readMoreLabel setHidden:YES];
            readMoreLabel.alpha = 1.0;
            readMoreLabel.frame = CGRectMake(readMoreLabel.frame.origin.x - 200,
                                             readMoreLabel.frame.origin.y - 200,
                                             readMoreLabel.frame.size.width,
                                             readMoreLabel.frame.size.height);
        }];
    }
}

-(void)shrinkDescriptionLabel:(UIGestureRecognizer *)gestureRecognizer
{
    if(readMoreLabel.isHidden){
        
        [descriptionLabel setUserInteractionEnabled:NO];
        
        [descriptionLabel setText:self.descriptionPreviewText];
        
        newDescriptionHeight = PREVIEW_N_LINES * LINE_HEIGHT;
        
        float newCellHeight = HEADER_AND_FOOTER_HEIGHT + newImageHeight + newDescriptionHeight;
        
        [self.tableView addNewCellHeight: newCellHeight atRow:self.row];
        
        [self refreshImageSize];
        
        readMoreLabel.alpha = 0;
        [readMoreLabel setHidden:NO];
        [UIView animateWithDuration:0.5 animations:^{
            readMoreLabel.alpha = 1.0;
        }];
        
    }
}

- (void) likeButtonPressed {
    if (!fof.m_liked) {
        
        NSString *newCount = [[[NSString alloc] initWithFormat:@"%d", [likesCountLabel.text intValue] + 1] autorelease];
        [likesCountLabel setText:newCount];
        
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"%@/uploader/user_like/",dyfocus_url] autorelease];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        [jsonRequestObject setObject:fof.m_id forKey:@"fof_id"];
        
        [jsonRequestObject setObject:[NSString stringWithFormat:@"%ld", delegate.myself.uid] forKey:@"user_id"];
        
        NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                   }
                               }];
        
        [buttonLike setTitle:@"Liked" forState:UIControlStateNormal];
        fof.m_liked = YES;
        fof.m_likes = [NSString stringWithFormat:@"%d",[fof.m_likes intValue] + 1];
        
        for (FOF *m_fof in self.tableView.FOFArray) {
            if(m_fof.m_id == fof.m_id){
                m_fof.m_likes = [NSString stringWithFormat:@"%d", [m_fof.m_likes intValue] + 1];
                m_fof.m_liked = YES;
            }
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        bool isReviewActive = [userDefaults boolForKey:@"reviewActive"];
        
        if(isReviewActive){
            
            int likeCount = [userDefaults integerForKey:@"likeCount"] + 1;
            [userDefaults setInteger:likeCount forKey:@"likeCount"];
            [userDefaults synchronize];
            
            if(likeCount>=3)
            {
                AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                [appDelegate askReview];
            }
        }
        
    } else {
        NSString *newLikeCount = [[[NSString alloc] initWithFormat:@"%d", [likesCountLabel.text intValue] - 1] autorelease];
        [likesCountLabel setText:newLikeCount];
        
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"%@/uploader/delete_like/",dyfocus_url] autorelease];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        //        curl -d json='{"user_id": 74, "fof_id": 352}' http://localhost:8000/uploader/delete_like/
        [jsonRequestObject setObject:fof.m_id forKey:@"fof_id"];
        
        [jsonRequestObject setObject:[NSString stringWithFormat:@"%ld", delegate.myself.uid] forKey:@"user_id"];
        
        NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                   }
                               }];
        
        [buttonLike setTitle:@"Like" forState:UIControlStateNormal];
        fof.m_liked = NO;
        fof.m_likes = [NSString stringWithFormat:@"%d",[fof.m_likes intValue] - 1];
        
        for (FOF *m_fof in self.tableView.FOFArray) {
            if(m_fof.m_id == fof.m_id){
                m_fof.m_likes = [NSString stringWithFormat:@"%d", [m_fof.m_likes intValue] - 1];
                m_fof.m_liked = NO;
            }
        }
    }
}

- (void) commentButtonPressed {
    [self showCommentView:TRUE];
}

- (void)openCommentView:(UIGestureRecognizer *)gestureRecognizer
{
    [self showCommentView:FALSE];
    
}

- (void) showCommentView:(BOOL)isCommenting {
    CommentViewerController *commentController = nil;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        commentController = [[CommentViewerController alloc] initWithNibName:@"CommentViewerController_i5" andFOF:fof];
    } else {
        commentController = [[CommentViewerController alloc] initWithNibName:@"CommentViewerController" andFOF:fof];
    }
        
    commentController.navigationItem.title = @"Comments";
    commentController.hidesBottomBarWhenPushed = YES;
    commentController.isCommenting = isCommenting;
    if(!isCommenting){
        commentController.hidesBottomBarWhenPushed = !isCommenting;
    }
    
    commentController.tableCell = self;
    
    [self.tableView.navigationController setNavigationBarHidden:NO];
    [self.tableView.navigationController pushViewController:commentController animated:YES];
}

-(void) startTimer {
    
    [spinner stopAnimating];
    [spinner setHidden:YES];
    
    if ([frames count] > 0) {
        [imagebackFrame setImage: [frames objectAtIndex:0]];
        
        if ([frames count] > 1) {
            [imagefrontFrame setImage: [frames objectAtIndex:1]];
        }
    }
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
    
    //TODO start fade out timer
    timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL/10 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];
    
    [playPauseButton setImage:[UIImage imageNamed:@"Pause-Button-NoStroke.png"] forState:UIControlStateNormal];
    [playPauseButton setHidden:NO];
    
    if (newDescriptionHeight!=0)
        [descriptionLabel setHidden:NO];
    
    if(self.descriptionPreviewText)
        [readMoreLabel setHidden:NO];
}

- (void)fadeImages {
    if (timer) {
        
        if (imagefrontFrame.alpha >= 1.0) {
            
            if (timerPause > 0) {
                timerPause -= 1;
                
            } else {
                
                timerPause = TIMER_PAUSE;
                
                if (oldFrameIndex >= [frames count] - 1) {
                    oldFrameIndex = 0;
                } else {
                    oldFrameIndex += 1;
                }
                
                if ([frames count] > 0)
                    [imagebackFrame setImage:[frames objectAtIndex:oldFrameIndex]];
                
                [imagebackFrame setNeedsDisplay];
                
                [imagefrontFrame setAlpha:0.0];
                
                [imagefrontFrame setNeedsDisplay];
                
                int newIndex;
                if (oldFrameIndex == [frames count] - 1) {
                    newIndex = 0;
                } else {
                    newIndex = oldFrameIndex + 1;
                }
                
                if ([frames count] > 0)
                    [imagefrontFrame setImage: [frames objectAtIndex: newIndex]];
                
            }
            
        } else {
            [imagefrontFrame setAlpha:imagefrontFrame.alpha + 0.01];
        }
    }
    
}

-(void) clearImages {
    
    [playPauseButton setHidden:YES];
    [descriptionLabel setHidden:YES];
    [readMoreLabel setHidden:YES];
    
    [imageUserPicture setImage: [UIImage imageNamed:@"AvatarDefault.png"]];
    
    imagebackFrame.image = nil;
    imagefrontFrame.image = nil;
    
    //TODO use self.dataMember instead of allocating and releasing manually
    
    [fof release];
    fof = nil;
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    imageUserPicture.tag = 0;
    
    if (frames) {
        [frames removeAllObjects];
        
        [frames release];
        frames = nil;
    }
    
    [spinner setHidden:NO];
    
    [buttonLike setTitle:@"Like" forState:UIControlStateNormal];
    
}

-(float) calculateNewDescriptionHeight
{
//    [descriptionLabel setText:@"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam eget ligula eu lectus lobortis condimentum. Aliquam nonummy auctor massa. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nulla at risus. Quisque purus magna, auctor et, sagittis ac, posuere eu, lectus. Nam mattis, felis ut adipiscing."];
    
    if (!((NSNull*)fof.m_description==[NSNull null]||fof.m_description==nil||[fof.m_description isEqual:@""])) {
    
        [descriptionLabel setText:fof.m_description];
        
        NSMutableString *fullText = [NSMutableString stringWithString:descriptionLabel.text];
        
        self.descriptionFullText = [[fullText copy] autorelease];
        
        CGSize maxDescriptionFrameSize = CGSizeMake(descriptionLabel.frame.size.width, MAX_FRAME_HEIGHT);
        
        CGSize descriptionTextSize = [descriptionLabel.text sizeWithFont:descriptionLabel.font
                                                       constrainedToSize:maxDescriptionFrameSize
                                                           lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat descriptionTextHeight = descriptionTextSize.height;
        
        
        if(descriptionTextHeight <= PREVIEW_N_LINES * LINE_HEIGHT){

            [readMoreLabel setHidden:YES];
            
            return descriptionTextHeight;
        }
        else
        {
            //Treats the last line so it looks cool with "read more" label
            
            NSArray *descriptionLinesArray = [self getLinesArrayOfStringInLabel:descriptionLabel];
            
            NSString *lastPreviewLine = [descriptionLinesArray objectAtIndex:PREVIEW_N_LINES-1];
            
            CGSize lastLineSize =  [lastPreviewLine sizeWithFont:descriptionLabel.font
                                        constrainedToSize:descriptionLabel.frame.size
                                            lineBreakMode:NSLineBreakByWordWrapping];
            
            CGFloat lastLineWidth = lastLineSize.width;
            
            int i = lastPreviewLine.length;
            
            while (lastLineWidth > descriptionLabel.frame.size.width - readMoreLabel.frame.size.width)
            {
            
                NSString* tempStr = [lastPreviewLine substringToIndex: i--];
                
                lastPreviewLine = tempStr;
                
                CGSize lineSize =  [tempStr sizeWithFont:descriptionLabel.font
                                            constrainedToSize:lastLineSize
                                                lineBreakMode:NSLineBreakByWordWrapping];
                
                lastLineWidth = lineSize.width;
            }
            
            NSMutableString *previewText = [NSMutableString stringWithString:@""];
            
            for (int j = 0; j < PREVIEW_N_LINES-1; j++) {
                
                previewText = [NSMutableString stringWithFormat:@"%@%@", previewText, [descriptionLinesArray objectAtIndex:j]];
                
            }
            
            previewText = [NSMutableString stringWithFormat:@"%@%@", previewText, lastPreviewLine];
            
            self.descriptionPreviewText = [[previewText copy]autorelease];
            
            [descriptionLabel setText:[[previewText copy] autorelease]];
            
            return PREVIEW_N_LINES * LINE_HEIGHT;
        }
    }
    else
    {
        return 0;
    }
}

-(NSArray *)getLinesArrayOfStringInLabel:(UILabel *)label
{
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:( id)myFont range:NSMakeRange(0, attStr.length)];
    
    CFRelease(myFont);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    
    NSMutableArray *linesArray = [[[NSMutableArray alloc]init]autorelease];
    
    for (id line in lines)
    {
        CTLineRef lineRef = ( CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        
        //NSLog(@"''''''''''''''''''%@",lineString);
        [linesArray addObject:lineString];
        
    }
    [attStr release];
    
    CGPathRelease(path);
    CFRelease( frame );
    CFRelease(frameSetter);
    
    
    return (NSArray *)linesArray;
}

-(void)loadImages {
    
    UITapGestureRecognizer *singleTapUserName = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadUserProfile:)] autorelease];
    imageUserPicture.userInteractionEnabled = YES;
    [imageUserPicture addGestureRecognizer:singleTapUserName];
    
    if (imageUserPicture.tag != 420) {
        UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
        //        [imageLoader loadPictureWithFaceId:fof.m_userId andImageView:imageUserPicture andIsSmall:YES];
        
        [imageLoader loadFofTableCellUserPicture:fof.m_userFacebookId andFOFId:fof.m_id andImageView:imageUserPicture];
    }
    
    
    if ((!frames || [frames count] == 0) && !spinner.isAnimating) {
        
        // Load frames
        if (!frames) {
            frames = [[NSMutableArray alloc] initWithCapacity:3];
        }
        
        [spinner startAnimating];
        
        [frames removeAllObjects];
        
        for (NSString *frameUrl in fofUrls) {
            
            NSDyfocusURLRequest *request = [NSDyfocusURLRequest requestWithURL:[NSURL URLWithString:frameUrl]];
            
            request.tag = [fofUrls indexOfObject:frameUrl];
            request.id = fof.m_id;
            
            [self sendFrameRequest:request];
            
        }
    } else {
        
        [self refreshImageSize];
    }
}

- (void) increaseCommentsCounter{
    NSString *newCount = [[[NSString alloc] initWithFormat:@"%d", [commentsCountLabel.text intValue] + 1] autorelease];
    [commentsCountLabel setText:newCount];
}

- (void) decreaseCommentsCounter{
    NSString *newCount = [[[NSString alloc] initWithFormat:@"%d", [commentsCountLabel.text intValue] - 1] autorelease];
    [commentsCountLabel setText:newCount];
}

- (void) refreshWithFof:(FOF *)fofObject {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ( !fof || fof.m_id != fofObject.m_id ) {
        
        [self clearImages];
        
        
        imagefrontFrame.frame = CGRectMake(imagefrontFrame.frame.origin.x,
                                           imagefrontFrame.frame.origin.y, imagefrontFrame.frame.size.width, 212);
        
        imagebackFrame.frame = CGRectMake(imagefrontFrame.frame.origin.x,
                                          imagefrontFrame.frame.origin.y, imagefrontFrame.frame.size.width, 212);
        
        
        if (fof) {
            [fof release];
            fof = nil;
        }
        
        
        fof = [[FOF alloc] init];
        fof.m_frames = [[fofObject.m_frames copy] autorelease];
        fof.m_comments = [[fofObject.m_comments copy] autorelease];
        fof.m_date = [[fofObject.m_date copy] autorelease];
        fof.m_id = [[fofObject.m_id copy] autorelease];
        fof.m_userId = fofObject.m_userId;
        fof.m_liked = fofObject.m_liked;
        fof.m_private = fofObject.m_private;
        fof.m_likes = [[fofObject.m_likes copy] autorelease];
        fof.m_name = [[fofObject.m_name copy] autorelease];
        fof.m_userFacebookId = [[fofObject.m_userFacebookId copy] autorelease];
        fof.m_userName = [[fofObject.m_userName copy] autorelease];
        fof.m_userNickname = [[fofObject.m_userNickname copy] autorelease];
        fof.m_description = [[fofObject.m_description copy] autorelease];
        
        UITapGestureRecognizer *singleTapOnLightGrayBackgroundView = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCommentView:)] autorelease];
        [lightGrayBackgroundView addGestureRecognizer:singleTapOnLightGrayBackgroundView];
        
        UITapGestureRecognizer *singleTapOnSupportView = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnFOF:)] autorelease];
        [supportView addGestureRecognizer:singleTapOnSupportView];
        
        UITapGestureRecognizer *singleTapOnReadMore = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandDescriptionLabel:)] autorelease];
        [readMoreLabel addGestureRecognizer:singleTapOnReadMore];
        
        UITapGestureRecognizer *singleTapOnDescription = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shrinkDescriptionLabel:)] autorelease];
        [descriptionLabel addGestureRecognizer:singleTapOnDescription];
        
        [buttonComment addTarget:self action:@selector(commentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonLike addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        whiteView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        whiteView.layer.cornerRadius = 3.0f;
        whiteView.layer.borderWidth = 1.0f;
        
        [labelUserName setText:fof.m_userName];
        
        UITapGestureRecognizer *singleTapUserName = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadUserProfile:)] autorelease];
        labelUserName.userInteractionEnabled = YES;
        [labelUserName addGestureRecognizer:singleTapUserName];
        
        [labelDate setText:fof.m_date];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        if((delegate.adminRule)  ||  (self.tableView.userId && (self.tableView.userId == delegate.myself.uid))){
            deleteFOFButton.hidden = NO;
            
            UITapGestureRecognizer *deleteFOFGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteFOFClicked:)] autorelease];
            
            [deleteFOFButton addGestureRecognizer:deleteFOFGesture];
        }
        
        //[buttonLike setTitle: [[[NSString alloc] initWithFormat:@"Like (%@)", fof.m_likes]autorelease] forState:UIControlStateNormal];
        
        [likesCountLabel setText:[[[NSString alloc] initWithFormat:@"%@", fof.m_likes] autorelease]];
        [commentsCountLabel setText:[[[NSString alloc] initWithFormat:@"%@", fof.m_comments] autorelease]];
        
        if(!fofUrls) {
            fofUrls = [[NSMutableArray alloc] init];
        } else {
            [fofUrls removeAllObjects];
        }
        
        for (NSDictionary *frame in fof.m_frames) {
            NSLog([frame debugDescription]);
            [fofUrls addObject:[frame objectForKey:@"frame_url"]];
        }
        
        if (fof.m_liked) {
            [buttonLike setTitle:@"Liked" forState:UIControlStateNormal];
            //buttonLike.titleLabel.font = [UIFont systemFontOfSize:11];
        }
    }
}

-(void) refreshImageSize {
    
    [supportView setUserInteractionEnabled:YES];
    
    if(imagebackFrame && imagefrontFrame && newImageHeight != 0.0){
        
        imagebackFrame.frame = CGRectMake(imagebackFrame.frame.origin.x,
                                          imagebackFrame.frame.origin.y , imagebackFrame.frame.size.width, newImageHeight);
        
        
        imagefrontFrame.frame = CGRectMake(imagefrontFrame.frame.origin.x,
                                           imagefrontFrame.frame.origin.y, imagefrontFrame.frame.size.width, newImageHeight);
        
        supportView.frame = CGRectMake(supportView.frame.origin.x,
                                       supportView.frame.origin.y, supportView.frame.size.width, newImageHeight);
        
        playPauseButton.center = CGPointMake(playPauseButton.center.x, newImageHeight + PLAY_PAUSE_BUTTON_OFFSET);
        
        descriptionLabel.frame = CGRectMake(descriptionLabel.frame.origin.x,
                                            newImageHeight + DESCRIPTION_LABEL_OFFSET,
                                            descriptionLabel.frame.size.width,
                                            newDescriptionHeight);
        
        readMoreLabel.frame = CGRectMake(readMoreLabel.frame.origin.x,
                                         newImageHeight + DESCRIPTION_LABEL_OFFSET + READMORE_LABEL_OFFSET,
                                         readMoreLabel.frame.size.width,
                                         readMoreLabel.frame.size.height);
    }
}

- (IBAction)playPauseAction:(UIButton *)sender {
    
    if (timer)
    {
        [timer invalidate];
        timer = nil;
        
        [playPauseButton setImage:[UIImage imageNamed:@"Play-Button-NoStroke.png"] forState:UIControlStateNormal];
    }
    else
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL/10 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
        [timer fire];
        
        [playPauseButton setImage:[UIImage imageNamed:@"Pause-Button-NoStroke.png"] forState:UIControlStateNormal];
    }
}

static int sortByIndex(UIDyfocusImage *image1, UIDyfocusImage *image2, void *ignore)
{
    
    NSNumber *number1 = [NSNumber numberWithInt:image1.index];
    NSNumber *number2 = [NSNumber numberWithInt:image2.index];
    return [number1 compare:number2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

/*- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    NSLog(@"%p willMoveToSuperview: %p", self, newSuperview);
    if(newSuperview == nil) {
        [self clearImages];
         NSLog(@"IMAGES CLEARED!!!!");
    }
}

- (oneway void) release {
    
    [super release];
}*/

- (void)dealloc
{
    [whiteView release];
    [supportView release];
    [lightGrayBackgroundView release];
    
    [imageUserPicture release];
    [imagefrontFrame release];
    [imagebackFrame release];
    
    [deleteFOFButton release];
    [playPauseButton release];
    [buttonLike release];
    [buttonComment release];
    
    [labelUserName release];
    [labelDate release];
    [descriptionLabel release];
    [readMoreLabel release];
    [commentsCountLabel release];
    [likesCountLabel release];
    
    [spinner release];
    
    [profilePictureUrl release];
    [frames release];
    [fofUrls release];
    [timer release];
    
    [fof release];
    
    [descriptionFullText release];
    [descriptionPreviewText release];
    [tableView release];
    
    [super dealloc];
}

@end
