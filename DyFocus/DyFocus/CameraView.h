
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "PathView.h"
#import "TutorialView.h"
#import "iToast.h"

@interface CameraView : UIViewController {
    
	AVCaptureStillImageOutput *mStillImageOutput;
    AVCaptureConnection *mVideoConnection;
    AVCaptureDevice *mCaptureDevice;

    IBOutlet UIView *cameraView;
    
    IBOutlet TutorialView *tutorialView;
    IBOutlet PathView *pathView;
    
    IBOutlet UIButton *torchOneButton;
    IBOutlet UIButton *torchTwoButton;
    
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *shootButton;
    IBOutlet UIButton *infoButton;
    
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIView *loadingView;
    
    AVCaptureSession *captureSession;
    
    NSMutableArray *mFocalPoints;
    NSMutableArray *mFrames;

    iToast *mToastMessage;
    
    int mFOFIndex;
    int torchOnFocusPoints;
    
    bool isObserving;
    bool isTorchOn;
    
    }

- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)shootAction:(UIButton *)sender;
- (IBAction)helpAction:(UIButton *)sender;

- (void)showToast:(NSString *)text;
- (void)updateFocusPoint;
- (void)setInitialFocusPoint:(CGPoint)point;
- (void)setProximityEnabled:(BOOL)isOn;
- (void)clearPoints;

@property(nonatomic,retain) IBOutlet UIButton *shootButton;
@property(nonatomic,retain) IBOutlet UIButton *cancelButton;
@property(nonatomic,retain) IBOutlet UIButton *infoButton;
@property(nonatomic,retain) IBOutlet UIView *cameraView;
@property(nonatomic,retain) IBOutlet PathView *pathView;
@property(nonatomic,retain) IBOutlet NSMutableArray *mFocalPoints;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic,retain) IBOutlet UIView *loadingView;
@property(nonatomic,retain) IBOutlet UIButton *torchOneButton;
@property(nonatomic,retain) IBOutlet UIButton *torchTwoButton;
@property(nonatomic,retain) IBOutlet TutorialView *tutorialView;

@end
