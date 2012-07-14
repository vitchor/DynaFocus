
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>



@interface CameraView : UIViewController {
    
	AVCaptureStillImageOutput *mStillImageOutput;
    AVCaptureConnection *mVideoConnection;
    AVCaptureDevice *mCaptureDevice;

    
    NSMutableArray *mFocalPoints;
    int mFOFIndex;
    
}
@end
