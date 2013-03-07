
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "PathView.h"
#import "iToast.h"

@interface CameraView : UIViewController {
    
	AVCaptureStillImageOutput *mStillImageOutput;
    AVCaptureConnection *mVideoConnection;
    AVCaptureDevice *mCaptureDevice;

    //IBOutlet UIButton *shootButton;
    //IBOutlet UIButton *clearButton;
    IBOutlet UIView *cameraView;
    IBOutlet UIView *infoView;
    IBOutlet PathView *pathView;
    IBOutlet UIBarButtonItem *infoButton;
    IBOutlet UIButton *getStartedButton;
    
    IBOutlet UIButton *torchButton;
    
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIBarButtonItem *clearButton;
    IBOutlet UIBarButtonItem *shootButton;
    
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
- (void)showToast:(NSString *)text;

- (void)updateFocusPoint;

- (void)setInitialFocusPoint:(CGPoint)point;

@property(nonatomic,retain) IBOutlet UIBarButtonItem *shootButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *clearButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *infoButton;
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


@end
