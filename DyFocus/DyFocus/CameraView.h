
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
    
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIBarButtonItem *clearButton;
    IBOutlet UIBarButtonItem *shootButton;
    
    AVCaptureSession *captureSession;
    
    NSMutableArray *mFocalPoints;
    NSMutableArray *mFrames;

    iToast *mToastMessage;
    
    int mFOFIndex;
    
}

@property(nonatomic,retain) IBOutlet UIBarButtonItem *shootButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *clearButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *infoButton;
@property(nonatomic,retain) IBOutlet UIView *cameraView;
@property(nonatomic,retain) IBOutlet PathView *pathView;
@property(nonatomic,retain) IBOutlet UIView *infoView;
@property(nonatomic,retain) IBOutlet UIButton *getStartedButton;
@end
