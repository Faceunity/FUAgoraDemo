//
//  RoomViewController.m
//  AgoraWithFaceunity
//
//  Created by ZhangJi on 11/03/2018.
//  Copyright © 2018 ZhangJi. All rights reserved.
//

#import "RoomViewController.h"
#import "FUManager.h"
#import "KeyCenter.h"
#import "FUAPIDemoBar.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

#import <AGMBase/AGMBase.h>
#import <AGMCapturer/AGMCapturer.h>
#import "AGMFaceUnityFilter.h"
#import "FUCamera.h"

@interface RoomViewController ()<FUAPIDemoBarDelegate, AgoraRtcEngineDelegate, AgoraVideoSourceProtocol,FUCameraDelegate> {
    BOOL faceBeautyMode;
}

@property (weak, nonatomic) IBOutlet UIView *containView;

@property (strong, nonatomic) FUCamera *mCamera ;

@property (strong, nonatomic)  FUAPIDemoBar *demoBar;    //Tool Bar

@property (weak, nonatomic) IBOutlet UILabel *noTrackLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UILabel *buglyLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;

@property (weak, nonatomic) IBOutlet UIButton *barBtn;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitchBtn;

@property (weak, nonatomic) IBOutlet UITableView *modelTableView;

@property (nonatomic, strong) FULiveModel *model;


#pragma Agora
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;    //Agora Engine

@property (nonatomic, strong) AgoraRtcVideoCanvas *remoteCanvas;

@property (nonatomic, weak)   UIView *remoteRenderView;

@property (nonatomic, strong) AgoraRtcVideoCanvas *localCanvas;

@property (nonatomic, weak)   UIView *localRenderView;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isMuted;

@property (nonatomic, assign) BOOL useFUCamera;

#pragma Capturer
@property (nonatomic, strong) AGMCameraCapturer *cameraCapturer;
@property (nonatomic, strong) AGMFaceUnityFilter *faceUnityFilter;
@property (nonatomic, strong) AGMCapturerVideoConfig *videoConfig;

@property (nonatomic, strong) UIView *preview;

@end

@implementation RoomViewController

@synthesize consumer;


#pragma mark -  Loading
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[FUManager shareManager] loadFilter];

    [self.view addSubview:self.demoBar];
    
    [self addObserver];
        
    [self initCapturer];
    [self loadAgoraKit];
    
    [FURenderer setMaxFaces:4];
}

- (void)initCapturer {
#pragma mark Capturer
{
    self.videoConfig = [AGMCapturerVideoConfig defaultConfig];
    self.videoConfig.videoSize = CGSizeMake(480, 640);
    self.videoConfig.sessionPreset = AGMCaptureSessionPreset480x640;
    self.videoConfig.outputPixelFormat = AGMVideoPixelFormatBGRA;
    self.videoConfig.fps = 15;
    self.cameraCapturer = [[AGMCameraCapturer alloc] initWithConfig:self.videoConfig];
    
    AGMVideoFrameAdapter *videoFrameAdapter = [[AGMVideoFrameAdapter alloc] init];
    videoFrameAdapter.orientationMode = AGMVideoOutputOrientationModeFixedPortrait;
    videoFrameAdapter.isMirror = NO;
//    videoFrameAdapter.sinkDelegate = self;
    [self.cameraCapturer addVideoSink:videoFrameAdapter];
    
    
#pragma mark Filter
    self.faceUnityFilter = [[AGMFaceUnityFilter alloc] init];

#pragma mark Connect
//    [self.cameraCapturer addVideoSink:videoFrameAdapter];
    [videoFrameAdapter addVideoSink:self.faceUnityFilter];
#pragma mark push pixelBuffer
    __weak typeof(self) weakSelf = self;
    self.faceUnityFilter.didCompletion = ^(CVPixelBufferRef  _Nonnull pixelBuffer, CMTime timeStamp, AGMVideoRotation rotation) {
        
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

        CFAbsoluteTime startRenderTime = CFAbsoluteTimeGetCurrent();

        [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
        
        CFAbsoluteTime renderTime = (CFAbsoluteTimeGetCurrent() - startRenderTime);


        CFAbsoluteTime frameTime = (CFAbsoluteTimeGetCurrent() - startTime);

        int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);

        CGSize frameSize;
        if (CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA) {
            frameSize = CGSizeMake(CVPixelBufferGetBytesPerRow(pixelBuffer) / 4, CVPixelBufferGetHeight(pixelBuffer));
        }else{
            frameSize = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
        }

        NSString *ratioStr = [NSString stringWithFormat:@"%dX%d", frameWidth, frameHeight];
        dispatch_async(dispatch_get_main_queue(), ^{

            //加载了人脸检测道具才会，检测人脸
//            if ([[FUManager shareManager] isHaveTrackFaceItemsRendering]) {
//                weakSelf.noTrackLabel.hidden = [[FUManager shareManager] isTracking];
//            }else{
//                weakSelf.noTrackLabel.hidden = YES;
//            }


            CGFloat fps = 1.0 / frameTime ;
            if (fps > 30) {
                fps = 30 ;
            }
            weakSelf.buglyLabel.text = [NSString stringWithFormat:@"resolution:\n %@\nfps: %.0f \nrender time:\n %.0fms", ratioStr, fps, renderTime * 1000.0];

        });

        // push pixelBuffer to agora server
        [weakSelf.consumer consumePixelBuffer:pixelBuffer withTimestamp:timeStamp rotation:rotation];
        
    };
}
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationLandscapeLeft:
            break;
        case UIInterfaceOrientationLandscapeRight:
            break;

        default:
            break;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (faceBeautyMode) {
        CGRect tipFrame = self.tipLabel.frame ;
        tipFrame.origin = CGPointMake(tipFrame.origin.x, [UIScreen mainScreen].bounds.size.height - 164 - tipFrame.size.height - 10) ;
        self.tipLabel.frame = tipFrame ;
        self.tipLabel.textColor = [UIColor whiteColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}



#pragma mark - Agora Engine
/**
* load Agora Engine && Join Channel
*/
- (void)loadAgoraKit {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    [self.agoraKit setVideoEncoderConfiguration:[[AgoraVideoEncoderConfiguration alloc]initWithSize:AgoraVideoDimension640x480
                                                                                          frameRate:AgoraVideoFrameRateFps15
                                                                                            bitrate:AgoraVideoBitrateStandard
                                                                                    orientationMode:AgoraVideoOutputOrientationModeFixedPortrait]];

    [self.agoraKit setClientRole:AgoraClientRoleBroadcaster];
    [self.agoraKit enableVideo];
    [self.agoraKit setVideoSource:self];
    [self.agoraKit enableWebSdkInteroperability:YES];
    
    [self setupLocalView];
    [self.agoraKit startPreview];
    
    self.count = 0;
    self.isMuted = false;
    
    [self.agoraKit joinChannelByToken:nil channelId:self.channelName info:nil uid:0 joinSuccess:nil];
}

- (void)setupLocalView {
    [self.containView layoutIfNeeded];
    self.preview = [[UIView alloc] initWithFrame:self.containView.bounds];
//    self.videoRnderer.preView = self.preview;

    [self.containView insertSubview:self.preview atIndex:0];
    if (self.localCanvas == nil) {
        self.localCanvas = [[AgoraRtcVideoCanvas alloc] init];
    }
    self.localCanvas.view = self.preview;
    self.localCanvas.renderMode = AgoraVideoRenderModeHidden;
    // set render view
    [self.agoraKit setupLocalVideo:self.localCanvas];
    self.localRenderView = self.preview;
    [self.agoraKit setLocalVideoMirrorMode:AgoraVideoMirrorModeEnabled];
    
}

#pragma mark - Agora Video Source Protocol
- (BOOL)shouldInitialize {
    return YES;
}

- (void)shouldStart {
    [self.cameraCapturer start];
}

- (void)shouldStop {
    [self.cameraCapturer stop];
}

- (void)shouldDispose {

}

- (AgoraVideoBufferType)bufferType {
    return AgoraVideoBufferTypePixelBuffer;
}

#pragma mark - Agora Engine Delegate
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    NSLog(@"Join Channel Success");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if (self.count == 0) {
        self.count ++;
        UIView *renderView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.containView insertSubview:renderView atIndex:0];
        if (self.remoteCanvas == nil) {
            self.remoteCanvas = [[AgoraRtcVideoCanvas alloc] init];
        }
        self.remoteCanvas.uid = uid;
        self.remoteCanvas.view = renderView;
        self.remoteCanvas.renderMode = AgoraVideoRenderModeHidden;
        [self.agoraKit setupRemoteVideo:self.remoteCanvas];
        
        self.remoteRenderView = renderView;
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = CGRectMake(self.view.frame.size.width * 0.7 - 10, 20, self.view.frame.size.width * 0.3, self.view.frame.size.width * 0.3 * 16.0 / 9.0);
            self.localRenderView.frame = newFrame;
        }];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (self.count > 0) {
        self.count --;
        self.remoteCanvas.view = nil;
        [self.remoteRenderView removeFromSuperview];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = self.view.frame;
            self.localRenderView.frame = newFrame;
        }];
    }
}

#pragma mark - Action
- (void)dismissTipLabel {
    self.tipLabel.hidden = YES;
}

- (void)dismissAlertLabel {
    self.alertLabel.hidden = YES ;
}


/**
* UI amiate
*/
- (void)hiddenButtonsWith:(BOOL)hidden {
    self.barBtn.hidden = hidden;
    self.cameraSwitchBtn.hidden = hidden;
    self.muteBtn.hidden = hidden;
}

- (void)hiddenToolBarWith:(BOOL)hidden {
//    self.demoBar.alpha = hidden ? 1.0 : 0.0;
//    [UIView animateWithDuration:0.5 animations:^{
//        self.demoBar.transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -self.demoBar.frame.size.height);
//        self.demoBar.alpha = hidden ? 0.0 : 1.0;
//    }];
}

- (void)hiddenModelTableView:(BOOL)hidden {
    self.modelTableView.alpha = hidden ? 1.0 : 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.modelTableView.transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(-90, 0);
        self.modelTableView.alpha = hidden ? 0.0 : 1.0;
    }];
}


/**
* Show the tool bar
*/
- (IBAction)filterBtnClick:(UIButton *)sender {
    [self hiddenButtonsWith:YES];
    [self hiddenToolBarWith:YES];
    [self hiddenModelTableView:NO];
}

/**
 * Hide the tool bar
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches allObjects].firstObject;
    if (touch.view == self.demoBar || touch.view == self.modelTableView || !self.barBtn.hidden) {
        return;
    }
    [self hiddenButtonsWith:NO];
    [self hiddenToolBarWith:YES];
    [self hiddenModelTableView:YES];
}

- (IBAction)leaveBtnClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self.captureManager stopCapture];
    [self.cameraCapturer stop];
    [[FUManager shareManager] destoryItems];
    [self.agoraKit leaveChannel:nil];
    [self.agoraKit stopPreview];
    [self.agoraKit setVideoSource:nil];
    [self.localRenderView removeFromSuperview];
    if (self.count > 0) {
        [self.remoteRenderView removeFromSuperview];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeSizeBtnDidClicked:(UIButton *)sender {

}

- (IBAction)switchCameraBtnClick:(UIButton *)sender {
    [self.cameraCapturer switchCamera];
    //Change camera need to call below function
    [self.agoraKit switchCamera];
    
    /* 人脸检测 */
    [FUManager shareManager].trackFlipx = ![FUManager shareManager].trackFlipx;
    /* 道具镜像 */
    [FUManager shareManager].flipx = ![FUManager shareManager].flipx;
    
    [[FUManager shareManager] onCameraChange];
    [self setCaptureVideoOrientation];
    if (self.cameraCapturer.captureDevicePosition == AVCaptureDevicePositionBack) {
        [self.agoraKit setLocalVideoMirrorMode:AgoraVideoMirrorModeDisabled];
    } else {
        [self.agoraKit setLocalVideoMirrorMode:AgoraVideoMirrorModeEnabled];
    }
}

- (IBAction)muteBtnClick:(UIButton *)sender {
    self.isMuted = !self.isMuted;
    [self.agoraKit muteLocalAudioStream:self.isMuted];
    [self.muteBtn setImage:[UIImage imageNamed: self.isMuted ? @"microphone-mute" : @"microphone"] forState:UIControlStateNormal];
}

- (IBAction)buglyBtnClick:(UIButton *)sender {
    self.buglyLabel.hidden = !self.buglyLabel.hidden;
}

- (void)setCaptureVideoOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

//    switch (orientation) {
//        case UIInterfaceOrientationPortrait:
//            [self.mCamera setCaptureVideoOrientation:AVCaptureVideoOrientationPortrait];
//            break;
//        case UIInterfaceOrientationPortraitUpsideDown:
//            [self.mCamera setCaptureVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
//            break;
//        case UIInterfaceOrientationLandscapeLeft:
//            [self.mCamera setCaptureVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
//            break;
//        case UIInterfaceOrientationLandscapeRight:
//            [self.mCamera setCaptureVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
//            break;
//        default:
//            break;
//    }
}




#pragma mark - FaceUnity

-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 231 - 60, self.view.frame.size.width, 231)];
        
        _demoBar.mDelegate = self;
    }
    return _demoBar ;
}

-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}

-(void)switchRenderState:(BOOL)state{
    [FUManager shareManager].isRender = state;
}

-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}

#pragma mark --- Observer
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)willResignActive {
        if (self.navigationController.visibleViewController == self) {
             [self.mCamera stopCapture];
     //        self.mCamera = nil;
         }
}


- (void)didBecomeActive {
    
       if (self.navigationController.visibleViewController == self) {
         [self.mCamera startCapture];
     }
}



@end
