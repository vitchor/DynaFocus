
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "PathView.h"
#import "iToast.h"
#import <CoreMedia/CMBufferQueue.h>
#import "RosyWriterPreviewView.h"
#import "RosyWriterVideoProcessor.h"


@interface CameraView : UIViewController <RosyWriterVideoProcessorDelegate>
{
    RosyWriterVideoProcessor *videoProcessor;
    BOOL shouldShowStats;
    UIBackgroundTaskIdentifier backgroundRecordingID;
    
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
    
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIView *loadingView;
    
    AVCaptureSession *captureSession;
    
    NSMutableArray *mFocalPoints;
    NSMutableArray *mFrames;

    iToast *mToastMessage;
    
    int mFOFIndex;
    
    bool isObserving;
    
    IBOutlet UIButton *popupCloseButton;
    IBOutlet UIView *popupView;
    IBOutlet UIView *popupDarkView;
    IBOutlet UIImageView *instructionsImageView;
    
    
    //VIdeo vars
    dispatch_queue_t movieWritingQueue;
    CMBufferQueueRef previewBufferQueue;
    
    // Only accessed on movie writing queue
    BOOL readyToRecordAudio;
    BOOL readyToRecordVideo;
	BOOL recordingWillBeStarted;
	BOOL recordingWillBeStopped;
	AVAssetWriter *assetWriter;    
    
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
@property(nonatomic,retain) IBOutlet    AVCaptureSession *captureSession;


@end
