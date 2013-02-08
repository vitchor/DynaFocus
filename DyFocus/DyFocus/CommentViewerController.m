//
//  CommentViewerController.m
//  DyFocus
//
//  Created by Victor on 1/24/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "CommentViewerController.h"
#import "JSON.h"
#import "LoadView.h"
#import "CommentTableCell.h"

#define kOFFSET_FOR_KEYBOARD 400.0

@implementation CommentViewerController

@synthesize inputMessageTextField, tableView, likesLabel, scrollView;

-(void)keyboardWillShow:(NSNotification*)aNotification
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = inputMessageTextField.frame;
    
    NSLog(@"SEARCH BAR ORIGIN: %f",rect.origin.y);
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        rect.origin.y = 268;
    } else {
        rect.origin.y = 180;
    }
    inputMessageTextField.frame = rect;
    
    inputMessageTextField.delegate = self;
    
    [UIView commitAnimations];
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, inputMessageTextField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, inputMessageTextField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
 
    /*
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    } */
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self hideKeyboard];
        
	}
}

-(void)hideKeyboard {
    [inputMessageTextField resignFirstResponder];
}

// Called when the UIKeyboardWillHideNotification is sent
-(void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = inputMessageTextField.frame;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        rect.origin.y = 480;
    } else {
        rect.origin.y = 392;
    }
    
    
    inputMessageTextField.frame = rect;
    
    [UIView commitAnimations];
    
    /*
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }*/
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{

}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andFOF:(FOF *)FOF {
    
    fof = FOF;
    
    return [self initWithNibName:nibNameOrNil bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self hideKeyboard];
}

-(void)shareOnFacebook{
    
    SharingController *fshareController = [[SharingController alloc] init];
    
    NSLog(@"FOF  NAMEEEEEE %@", fof.m_name);
    NSLog(@"FOF  IIDDDDDDD %@", fof.m_userId);
    
    [self.navigationController pushViewController:fshareController animated:true];
    
    fshareController.navigationItem.title = @"Comment";
//    fshareController.fofName = @"462837.106732";
//    fshareController.fofUserFbId = @"100000754383534";

    fshareController.fofName = fof.m_name;
    fshareController.fofUserFbId = fof.m_userId;

    [fshareController.commentField becomeFirstResponder];
    [fshareController.commentField setHidden:NO];
    fshareController.navigationItem.leftBarButtonItem = fshareController.backButton;
    
    NSString *share = @"Share";
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:share style:UIBarButtonItemStyleDone target:fshareController action:@selector(shareWithFbFromComments)];
    fshareController.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    
    
}
- (void)viewWillAppear:(BOOL)animated {
   

    
    
    // Hides magnifier icon
    UITextField* searchField = nil;
    for (UIView* subview in inputMessageTextField.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchField = (UITextField*)subview;
            break;
        }
    }
    if (searchField) {
        searchField.leftViewMode = UITextFieldViewModeNever;
    }
    
    inputMessageTextField.placeholder = @"Write a comment...";    
    
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    if (!comments || [comments count] == 0) {
        
        UIImage *faceImage = [UIImage imageNamed:@"fb_share_button.png"];
        UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
        face.bounds = CGRectMake( 0, 0, faceImage.size.width * 0.65, faceImage.size.height * 0.65);
        [face setImage:faceImage forState:UIControlStateNormal];
        
        UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:face];
        
        [face addTarget:self action:@selector(shareOnFacebook) forControlEvents:UIControlEventTouchUpInside];
        
        [faceBtn setCustomView:face];
        
        [self.navigationItem setRightBarButtonItem:faceBtn];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        
        [LoadView loadViewOnView:self.view withText:@"Loading..."];
        
        NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/likes_and_comments/",dyfocus_url] autorelease];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        
        [jsonRequestObject setObject:fof.m_id forKey:@"fof_id"];
        
        NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   [LoadView fadeAndRemoveFromView:self.view];
                                   
                                   if(!error && data) {
                                       
                                       comments = [[NSMutableArray alloc] init];
                                       likes = [[NSMutableArray alloc] init];                                   
                                       
                         
                                       
                                       NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                       
                                                     NSLog(@"stringReply: %@",stringReply);
                                       
                                       NSDictionary *jsonValues = [stringReply JSONValue];
                                       
                                       if (jsonValues) {
                                           NSDictionary * jsonComments = [jsonValues valueForKey:@"comment_list"];
                                           
                                           for (int i = 0; i < [jsonComments count]; i++) {
                                               
                                               NSDictionary *jsonComment = [jsonComments objectAtIndex:i];
                                               
                                               NSString *fofFriendId = [jsonComment valueForKey:@"user_facebook_id"];
                                               NSString *fofId = [jsonComment valueForKey:@"fof_id"];
                                               NSString *fofComment = [jsonComment valueForKey:@"comment"];
                                               NSString *fofUserName = [jsonComment valueForKey:@"user_name"];
                                               
                                               NSString *commentPubDate = [jsonComment valueForKey:@"pub_date"];
                                               
                                               Comment *comment = [[Comment alloc] init];
                                               comment.m_userId = fofFriendId;
                                               comment.m_message = fofComment;
                                               comment.m_userName = fofUserName;
                                               comment.m_fofId = fofId;
                                               comment.m_date = commentPubDate;
                                            
                                               [comments addObject:comment];
                                                  NSLog(@"Commentario: %@", comment.m_message);
                                               
                                            }
                                           
                                        
                                           
                                           NSDictionary * jsonLikes = [jsonValues valueForKey:@"like_list"];
                                           
                                           for (int i = 0; i < [jsonLikes count]; i++) {
                                               
                                               NSDictionary *jsonComment = [jsonLikes objectAtIndex:i];
                                               
                                               NSString *fofFriendId = [jsonComment valueForKey:@"user_facebook_id"];
                                               NSString *fofId = [jsonComment valueForKey:@"fof_id"];
                                               NSString *fofUserName = [jsonComment valueForKey:@"user_name"];
                                               
                                               Like *like = [[Like alloc] init];
                                               like.m_userId = fofFriendId;
                                               like.m_userName = fofUserName;
                                               
                                               NSArray *array = [like.m_userName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                               array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
                                               
                                               like.m_fofId = fofId;
                                               
                                               
                                               if (i == 0) {
                                                   likeListUsers = [[NSMutableString alloc] initWithString:@""];
                                                   [likeListUsers appendString:[NSString stringWithFormat:@"%@", [array objectAtIndex:0]]];
                                                   
                                               } else if ([jsonLikes count] > 1 && i == [jsonLikes count] -1) { // Last Time
                                                   [likeListUsers appendString:[NSString stringWithFormat:@" and %@", [array objectAtIndex:0]]];
                                                   
                                               } else {
                                                   [likeListUsers appendString:[NSString stringWithFormat:@", %@", [array objectAtIndex:0]]];
                                               }
                                               
                                               [likes addObject:like];   
                                           }
                                           
                                           if ([likes count] == 0) {
                                               likeListUsers = [[NSMutableString alloc] initWithString:@"No one liked this yet."];
                                               
                                           } else if ([likes count] == 1) {
                                               [likeListUsers appendString:@" likes this."];
                                               
                                           } else {
                                               [likeListUsers appendString:@" like this."];
                                               
                                           }
                                           
                                           [likesLabel setText:likeListUsers];
                                           
                                            self.navigationItem.rightBarButtonItem.enabled = YES;
                                           
                                           [tableView reloadData];
                                           
                                       } else {
                                           [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Connection Error"];
                                       }
                                       
                                   } else {
                                       [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Connection Error"];
                                   }
                               }];
    
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    
    tableView.exclusiveTouch = NO;
    tableView.multipleTouchEnabled = YES;
    
    for (UIView *searchBarSubview in [inputMessageTextField subviews]) {
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeySend];
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException * e) {
                
                // ignore exception
            }
        }
    }
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
     
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}



#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if (comments && [comments count] != 0) {
        isTableEmpty = NO;
        return [comments count];
    } else {
        isTableEmpty = YES;
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (isTableEmpty) {
        UITableViewCell *cell;
        
        NSString *cellId = @"empty";
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
        }
        
        cell.textLabel.text = @"No comments were found";
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:20];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;
        cell.imageView.image = nil;
        
        return cell;
        
    } else {
        
        CommentTableCell *cell;
        
        
        NSString *cellId = [NSString stringWithFormat:@"0_%d", indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommentTableCell" owner:self options:nil];
            
            for(id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[CommentTableCell class]]) {
                    cell = (CommentTableCell *)currentObject;
                    break;
                }
            }
            
        }
        
        Comment *comment = (Comment *) [comments objectAtIndex:indexPath.row];
        
        [cell refreshWithComment:comment];
        return cell;
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    NSNumber *height = (NSNumber *)[Dictionary objectForKey:[NSNumber numberWithInt:indexPath.row]];
    
    NSLog(@"HEIGHT: %d", [height intValue]);
    
    if ([height intValue] != 0) {
        return [height intValue];
    } else {
        return 334;
    }
    
    return [height intValue];
     */
    return 107;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [LoadView loadViewOnView:self.view withText:@"Loading..."];
    [self hideKeyboard];
    
    /*
     
     {
     "facebook_id": "100000370417687",
     "fof_id": "96964.057167",
     "comment_message": "QUE LEGAAAL! "
     }
     
     */
    
    NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/comment/",dyfocus_url] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    
    [jsonRequestObject setObject:fof.m_id forKey:@"fof_id"];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [jsonRequestObject setObject:[delegate.myself objectForKey:@"id"] forKey:@"facebook_id"];
    
    [jsonRequestObject setObject:searchBar.text forKey:@"comment_message"];
    
    
    NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                           json] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if(!error && data) {
                                   [LoadView fadeAndRemoveFromView:self.view];
                                   
                                   AppDelegate *delegate = [UIApplication sharedApplication].delegate;
                                   
                                   NSDictionary *myself = delegate.myself;
                                   
                                   Comment *comment = [[Comment alloc] init];
                                   comment.m_userId = [myself objectForKey:@"id"];
                                   comment.m_message = searchBar.text;
                                   comment.m_userName = [myself objectForKey:@"name"];
                                   comment.m_fofId = fof.m_id;
                                   comment.m_date = @"Today";
                                   
                                   [comments addObject:comment];
                                   [tableView reloadData];
                                   
                                   fof.m_comments = [[NSString alloc] initWithFormat: @"%d",[fof.m_comments intValue] + 1];
                                   
                               } else {
                                   [LoadView fadeAndRemoveFromView:self.view];                                   
                                   [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Connection Error"];
                               }
                           }];
    
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
}

@end
