
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "PathView.h"
#import "TutorialView.h"
#import "iToast.h"

@interface CameraView : UIViewController{
    
	AVCaptureStillImageOutput *mStillImageOutput;
    AVCaptureConnection *mVideoConnection;
    AVCaptureDevice *mCaptureDevice;

    IBOutlet UIView *cameraView;

    IBOutlet PathView *pathView;
    
    IBOutlet UIButton *torchOneButton;
    IBOutlet UIButton *torchTwoButton;
    
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIView *loadingView;
    
    AVCaptureSession *captureSession;
    
    NSMutableArray *mFrames;

    iToast *mToastMessage;
    
    int mFOFIndex;
    int torchOnFocusPoints;
    
    bool isObserving;
    bool isTorchOn;
    
    TutorialView *tutorialView;
    
}

- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)shootAction:(UIButton *)sender;
- (IBAction)helpAction:(UIButton *)sender;

- (void)showToast:(NSString *)text;
- (void)updateFocusPoint;
- (void)setProximityEnabled:(BOOL)isOn;
- (void)clearPoints;

@property(nonatomic,retain) IBOutlet UIButton *shootButton;
@property(nonatomic,retain) IBOutlet UIButton *cancelButton;
@property(nonatomic,retain) IBOutlet UIButton *infoButton;
@property(nonatomic,retain) IBOutlet NSMutableArray *mFocalPoints;


@end
