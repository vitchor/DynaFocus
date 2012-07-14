
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>


@interface CameraView : UIViewController {
    
	AVCaptureStillImageOutput *mStillImageOutput;
    AVCaptureConnection *mVideoConnection;
    AVCaptureDevice *mCaptureDevice;

    IBOutlet UIButton *shootButton;
    IBOutlet UIView *cameraView;
    
    NSMutableArray *mFocalPoints;
    NSMutableArray *mFrames;
    
    int mFOFIndex;
    
}

@property(nonatomic,retain) IBOutlet UIButton *shootButton;
@property(nonatomic,retain) IBOutlet UIView *cameraView;

@end
