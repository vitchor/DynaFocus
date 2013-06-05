//
//  FOFTableCell.m
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FOFTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "JSON.h"
#import "CommentViewerController.h"
#import "AppDelegate.h"
#import "NSDyfocusURLRequest.h"
#import "UIDyfocusImage.h"
#import "UIImageLoaderDyfocus.h"
#import "FullscreenFOFViewController.h"

@implementation FOFTableCell
@synthesize labelUserName ,labelDate, buttonLike, buttonComment, imagefrontFrame, imagebackFrame, imageUserPicture, timer, spinner, whiteView, tableView, row, commentsCountLabel, likesCountLabel, lightGrayBrackgroundView;

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;


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

- (void) commentButtonPressed {
    [self showCommentView:TRUE];
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
    
    [tableView.navigationController setNavigationBarHidden:NO];
    [tableView.navigationController pushViewController:commentController animated:YES];
}

-(void) refreshImageSize {
    
    [imagefrontFrame setUserInteractionEnabled:YES];
    [imagebackFrame setUserInteractionEnabled:YES];
    
    if(imagebackFrame && imagefrontFrame && newHeight != 0.0){
        
        
        imagebackFrame.frame = CGRectMake(imagebackFrame.frame.origin.x,
                                      imagebackFrame.frame.origin.y , imagebackFrame.frame.size.width, newHeight);
    

        imagefrontFrame.frame = CGRectMake(imagefrontFrame.frame.origin.x,
                                       imagefrontFrame.frame.origin.y, imagefrontFrame.frame.size.width, newHeight);
        
    }
    
}

- (void) increaseCommentsCounter{
    NSString *newCount = [[[NSString alloc] initWithFormat:@"%d", [commentsCountLabel.text intValue] + 1] autorelease];
    [commentsCountLabel setText:newCount];
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
        fof.m_likes = [[NSString alloc] initWithFormat:@"%d",[fof.m_likes intValue] + 1];
        
        for (FOF *m_fof in tableView.FOFArray) {
            if(m_fof.m_id == fof.m_id){
                m_fof.m_likes = [[NSString alloc] initWithFormat:@"%d", [m_fof.m_likes intValue] + 1];
                m_fof.m_liked = YES;
            }
        }      
    } else {
        //implement liked   
    }
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
        fof.m_likes = [[fofObject.m_likes copy] autorelease];
        fof.m_name = [[fofObject.m_name copy] autorelease];
        fof.m_userFacebookId = [[fofObject.m_userFacebookId copy] autorelease];
        fof.m_userName = [[fofObject.m_userName copy] autorelease];
        fof.m_userNickname = [[fofObject.m_userNickname copy] autorelease];
        
        UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)] autorelease];
        [lightGrayBrackgroundView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *singleTapOnFrontImage = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnFOF:)] autorelease];
        [imagefrontFrame addGestureRecognizer:singleTapOnFrontImage];
        
        UITapGestureRecognizer *singleTapOnBackImage = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnFOF:)] autorelease];
        [imagebackFrame addGestureRecognizer:singleTapOnBackImage];

        
        [buttonComment addTarget:self action:@selector(commentButtonPressed) forControlEvents:UIControlEventTouchUpInside];

        [buttonLike addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        whiteView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        whiteView.layer.cornerRadius = 3.0f;
        whiteView.layer.borderWidth = 1.0f;

        [labelUserName setText:fof.m_userName];
        
        UITapGestureRecognizer *singleTapUserName = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadUserProfile:)] autorelease];
        labelUserName.userInteractionEnabled = YES;
        [labelUserName addGestureRecognizer:singleTapUserName];
        
//        labelUserName
        
        [labelDate setText:fof.m_date];
        
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

- (IBAction)playPauseAction:(UIButton *)sender {
    
    if (timer)
    {
        [timer invalidate];
        timer = nil;
        
        [playPauseButton setImage:[UIImage imageNamed:@"Play-Button-NoStroke.png"] forState:UIControlStateNormal];
    }
    else
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
        [timer fire];
        
        [playPauseButton setImage:[UIImage imageNamed:@"Pause-Button-NoStroke.png"] forState:UIControlStateNormal];
    }
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self showCommentView:FALSE];
    
}

- (void)singleTapOnFOF:(UITapGestureRecognizer *)gesture
{
    if(frames.count >=1){
    
        [imagebackFrame setUserInteractionEnabled:NO];
        [imagefrontFrame setUserInteractionEnabled:NO];
        
        FullscreenFOFViewController *fullScreenController = [[FullscreenFOFViewController alloc] initWithNibName:@"FullscreenFOFViewController" bundle:nil];
        
        fullScreenController.hidesBottomBarWhenPushed = YES;
        
        fullScreenController.frames = frames;
        
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration:0.80];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIView setAnimationTransition:
         UIViewAnimationTransitionFlipFromRight
                               forView:tableView.navigationController.view cache:NO];
        
        
        [tableView.navigationController pushViewController:fullScreenController animated:YES];
        [UIView commitAnimations];
        
        [fullScreenController release];
    
    }
}

//- (void) pushViewController:(UIViewController*)controller withAnimationType:(NSString*)animationType {
//    
//    CATransition* transition = [CATransition animation];
//    transition.duration = 0.5;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = animationType; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
//    transition.subtype = kCATransitionFromRight;
//    [tableView.navigationController.view.layer addAnimation:transition forKey:nil];
//    [tableView.navigationController pushViewController:controller animated:NO];
//}

//- (NSString*)getSubTypeTransition
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//    CGRect rectOfCellInTableView = [tableView.m_tableView rectForRowAtIndexPath:indexPath];
//    CGRect rectOfCellInSuperview = [tableView.m_tableView convertRect:rectOfCellInTableView toView:[tableView.m_tableView superview]];
//    
//    float screenCenter = 0.0;
//    float tabBarOffSet = 65.0;
//    float tappedFofPosition = rectOfCellInSuperview.origin.y+tabBarOffSet;
//    
//    if(tappedFofPosition > screenCenter) {
//        return ©;
//    }else{
//        return kCATransitionFromBottom;
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) startTimer {
    
    [spinner stopAnimating];
    [spinner setHidden:YES];
    
    if ([frames count] > 0) {
        [self.imagebackFrame setImage: [frames objectAtIndex:0]];
        
        if ([frames count] > 1) {
            [self.imagefrontFrame setImage: [frames objectAtIndex:1]];
        }
    }
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
    
    //TODO start fade out timer
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];
    
    [playPauseButton setImage:[UIImage imageNamed:@"Pause-Button-NoStroke.png"] forState:UIControlStateNormal];
    [playPauseButton setHidden:NO];

}

- (void)loadUserProfile:(UITapGestureRecognizer *)gesture {

    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    ProfileController *profileController = nil;
    
    Person *person;
    if(fof.m_userId ==delegate.myself.uid){
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
                                       
                                       newHeight = imagebackFrame.frame.size.width * scale;
                                       
                                       [self.tableView addNewCellHeight:newHeight atRow:self.row];
                                       
                                       imagebackFrame.frame = CGRectMake(imagebackFrame.frame.origin.x,
                                                                         imagebackFrame.frame.origin.y , imagebackFrame.frame.size.width, newHeight);
                                       
                                       //imagebackFrame.clipsToBounds = YES;
                                       newHeight = imagefrontFrame.frame.size.width * scale;
                                       imagefrontFrame.frame = CGRectMake(imagefrontFrame.frame.origin.x,
                                                                          imagefrontFrame.frame.origin.y, imagefrontFrame.frame.size.width, newHeight);
                                       
                                       
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


static int sortByIndex(UIDyfocusImage *image1, UIDyfocusImage *image2, void *ignore)
{
    
    NSNumber *number1 = [NSNumber numberWithInt:image1.index];
    NSNumber *number2 = [NSNumber numberWithInt:image2.index];
    return [number1 compare:number2];
}

-(void) clearImages {
    
    [playPauseButton setHidden:YES];
    
    [imageUserPicture setImage: [UIImage imageNamed:@"AvatarDefault.png"]];

    imagebackFrame.image = nil;
    imagefrontFrame.image = nil;
    
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

- (void)fadeImages {
    if (timer) {
        
        if (self.imagefrontFrame.alpha >= 1.0) {
            
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
                    [self.imagebackFrame setImage:[frames objectAtIndex:oldFrameIndex]];
                
                [self.imagebackFrame setNeedsDisplay];
                
                [self.imagefrontFrame setAlpha:0.0];
                
                [self.imagefrontFrame setNeedsDisplay];
                
                int newIndex;
                if (oldFrameIndex == [frames count] - 1) {
                    newIndex = 0;
                } else {
                    newIndex = oldFrameIndex + 1;
                }

                if ([frames count] > 0)
                    [self.imagefrontFrame setImage: [frames objectAtIndex: newIndex]];
                
            }
            
        } else {
            [self.imagefrontFrame setAlpha:self.imagefrontFrame.alpha + 0.01];
        }
    }
    
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
    [frames release];
    [playPauseButton release];
    [super dealloc];
}

@end
