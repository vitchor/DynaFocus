
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "PathView.h"
#import "iToast.h"

@interface CameraView : UIViewController {
    
	AVCaptureStillImageOutput *mStillImageOutput;
    AVCaptureConnection *mVideoConnection;
    AVCaptureDevice *mCaptureDevice;

    IBOutlet UIView *cameraView;
    IBOutlet UIView *infoView;
    
    IBOutlet PathView *pathView;
    
    IBOutlet UIButton *getStartedButton;
    IBOutlet UIButton *torchButton;
    
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
    
    bool isObserving;
    bool isTorchOn;
    
    IBOutlet UIButton *popupCloseButton;
    IBOutlet UIView *popupView;
    IBOutlet UIView *popupDarkView;
    IBOutlet UIImageView *instructionsImageView;
    
    
    
    }

- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)shootAction:(UIButton *)sender;
- (IBAction)helpAction:(UIButton *)sender;

- (void)showToast:(NSString *)text;
- (void)updateFocusPoint;
- (void)setInitialFocusPoint:(CGPoint)point;

@property(nonatomic,retain) IBOutlet UIButton *shootButton;
@property(nonatomic,retain) IBOutlet UIButton *cancelButton;
@property(nonatomic,retain) IBOutlet UIButton *infoButton;
@property(nonatomic,retain) IBOutlet UIView *cameraView;
@property(nonatomic,retain) IBOutlet PathView *pathView;
@property(nonatomic,retain) IBOutlet UIView *infoView;
@property(nonatomic,retain) IBOutlet UIButton *getStartedButton;
@property(nonatomic,retain) IBOutlet NSMutableArray *mFocalPoints;
@property(nonatomic,retain) IBOutlet UIButton *popupCloseButton;
@property(nonatomic,retain) IBOutlet UIView *popupView;
@property(nonatomic,retain) IBOutlet UIView *popupDarkView;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic,retain) IBOutlet UIView *loadingView;
@property(nonatomic,retain) IBOutlet UIButton *torchButton;
@property(nonatomic,retain) IBOutlet UIImageView *instructionsImageView;

@end
