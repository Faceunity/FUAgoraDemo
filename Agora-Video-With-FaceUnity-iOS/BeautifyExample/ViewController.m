//
//  ViewController.m
//  BeautifyExample
//
//  Created by LSQ on 2020/8/3.
//  Copyright © 2020 Agora. All rights reserved.
//


#import "ViewController.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "VideoProcessingManager.h"
#import "KeyCenter.h"

#import "FUDemoManager.h"

#import <Masonry/Masonry.h>

@interface ViewController () <AgoraRtcEngineDelegate, AgoraVideoFrameDelegate>

@property (nonatomic, strong) VideoProcessingManager *processingManager;
@property (nonatomic, strong) AgoraRtcEngineKit *rtcEngineKit;
@property (nonatomic, strong) IBOutlet UIView *localView;

@property (weak, nonatomic) IBOutlet UIView *remoteView;

@property (nonatomic, strong) IBOutlet UIButton *switchBtn;
@property (nonatomic, strong) IBOutlet UIButton *remoteMirrorBtn;
@property (nonatomic, strong) IBOutlet UIView *missingAuthpackLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteAudioBtn;
@property (nonatomic, strong) AgoraRtcVideoCanvas *videoCanvas;
@property (nonatomic, assign) AgoraVideoMirrorMode localVideoMirrored;
@property (nonatomic, assign) AgoraVideoMirrorMode remoteVideoMirrored;

@property (nonatomic, assign) BOOL isFrontCamera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.remoteView.hidden = YES;
    
    // FaceUnity
    [[FUDemoManager shared] setupFUSDK];
    [[FUDemoManager shared] addDemoViewToView:self.view originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - FUSafaAreaBottomInsets()];

    // 初始化 rte engine
    self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:self];
    NSString *sdkVersion = [AgoraRtcEngineKit getSdkVersion];
    NSLog(@"[AgoraRtcEngineKit]:%@", sdkVersion);
    [self.rtcEngineKit setVideoFrameDelegate:self];
    [self.rtcEngineKit setClientRole:AgoraClientRoleBroadcaster];
    
    AgoraCameraCapturerConfiguration *captuer = [[AgoraCameraCapturerConfiguration alloc] init];
    captuer.cameraDirection = AgoraCameraDirectionFront;
    captuer.frameRate = 30;
    [self.rtcEngineKit setCameraCapturerConfiguration:captuer];
    _isFrontCamera = YES;
    
    AgoraVideoEncoderConfiguration *configuration = [[AgoraVideoEncoderConfiguration alloc] init];
    configuration.dimensions = CGSizeMake(1280, 720);
    configuration.frameRate = 30;
    [self.rtcEngineKit setVideoEncoderConfiguration: configuration];
    
    // set up local video to render your local camera preview
    self.videoCanvas = [AgoraRtcVideoCanvas new];
    self.videoCanvas.uid = 0;
    // the view to be binded
    self.videoCanvas.view = self.localView;
    self.videoCanvas.renderMode = AgoraVideoRenderModeHidden;
//    self.videoCanvas.mirrorMode = AgoraVideoMirrorModeDisabled;
    [self.rtcEngineKit setupLocalVideo:self.videoCanvas];
    
    AgoraRtcChannelMediaOptions *option = [[AgoraRtcChannelMediaOptions alloc] init];
    option.clientRoleType = AgoraClientRoleBroadcaster;
    option.publishMicrophoneTrack = YES;
    option.publishCameraTrack = YES;
    
    
//    [self.rtcEngineKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
//    [self.rtcEngineKit enableVideo];
//    [self.rtcEngineKit setParameters:@"{\"che.video.zerocopy\":true}"];

    
    // init process manager
//    self.processingManager = [[VideoProcessingManager alloc] init];
    
    
    // add filter to process manager
//    [self.processingManager addVideoFilter:self];
    
    // self.processingManager.enableFilter = NO;
    
    // set up local video to render your local camera preview
//    self.videoCanvas = [AgoraRtcVideoCanvas new];
//    self.videoCanvas.uid = 0;
//    // the view to be binded
//    self.videoCanvas.view = self.localView;
//    self.videoCanvas.renderMode = AgoraVideoRenderModeHidden;
//    self.videoCanvas.mirrorMode = AgoraVideoMirrorModeDisabled;
//    [self.rtcEngineKit setupLocalVideo:self.videoCanvas];
    
//    [self.localView layoutIfNeeded];
//    self.glVideoView = [[AGMEAGLVideoView alloc] initWithFrame:self.localView.frame];
////    [self.glVideoView setRenderMode:(AGMRenderMode_Fit)];
//    [self.localView addSubview:self.glVideoView];
//    [self.capturerManager setVideoView:self.glVideoView];
//    // set custom capturer as video source
//    [self.rtcEngineKit setVideoSource:self.capturerManager];
    
    [self.rtcEngineKit joinChannelByToken:nil channelId:self.channelName info:nil uid:0 joinSuccess:nil];
    [self.rtcEngineKit joinChannelByToken:nil channelId:self.channelName uid:0 mediaOptions:option joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
    }];
    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit enableAudio];
    [self.rtcEngineKit startPreview];
}


- (void)viewDidLayoutSubviews {
//    self.glVideoView.frame = self.view.bounds;
}

- (void)dealloc {
//    [FUDemoManager destory];
//    [self.rtcEngineKit leaveChannel:nil];
//    [self.rtcEngineKit stopPreview];
//    [AgoraRtcEngineKit destroy];
    
}

- (IBAction)switchCamera:(UIButton *)button
{
//    [self.rtcEngineKit stopPreview];
    _isFrontCamera = !_isFrontCamera;
    [self.rtcEngineKit switchCamera];
    [FUDemoManager resetTrackedResult];
//    [self.rtcEngineKit startPreview];
}

- (IBAction)toggleRemoteMirror:(UIButton *)button
{
    self.remoteVideoMirrored = self.remoteVideoMirrored == AgoraVideoMirrorModeEnabled ? AgoraVideoMirrorModeDisabled : AgoraVideoMirrorModeEnabled;
    [self.rtcEngineKit setLocalRenderMode:(AgoraVideoRenderModeHidden) mirror:self.remoteVideoMirrored];
    
    
}

- (IBAction)muteAudioBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        
        [sender setTitleColor:[UIColor blueColor] forState:(UIControlStateSelected)];
    }
    [self.rtcEngineKit muteLocalAudioStream:sender.selected];
}

- (IBAction)backBtnClick:(UIButton *)sender {
    [self.rtcEngineKit leaveChannel:nil];
    [self.rtcEngineKit stopPreview];
    [AgoraRtcEngineKit destroy];
    [FUDemoManager destory];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)onCaptureVideoFrame:(AgoraOutputVideoFrame *)videoFrame sourceType:(AgoraVideoSourceType)sourceType {
    CVPixelBufferRef pixelBuffer = [self processFrame:videoFrame.pixelBuffer];
    videoFrame.pixelBuffer = pixelBuffer;
    return YES;
}


/// firstRemoteVideoDecoded
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
//    if (self.remoteView.hidden) {
//        self.remoteView.hidden = NO;
//    }
//
//    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
//    videoCanvas.uid = uid;
//    // Since we are making a simple 1:1 video chat app, for simplicity sake, we are not storing the UIDs. You could use a mechanism such as an array to store the UIDs in a channel.
//
//    videoCanvas.view = self.remoteView;
//    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
//    [self.rtcEngineKit setupRemoteVideo:videoCanvas];
    // Bind remote video stream to view
    
}

#pragma mark - AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    NSLog(@"加入房间");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state reason:(AgoraVideoRemoteReason)reason elapsed:(NSInteger)elapsed {
    switch (state) {
        case AgoraVideoRemoteStateStarting: {
            if (self.remoteView.hidden) {
                self.remoteView.hidden = NO;
            }
        }
            break;
        case AgoraVideoRemoteStateStopped: {
            if (!self.remoteView.hidden) {
                self.remoteView.hidden = YES;
            }
        }
            
        default:
            break;
    }
    
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    // Since we are making a simple 1:1 video chat app, for simplicity sake, we are not storing the UIDs. You could use a mechanism such as an array to store the UIDs in a channel.
    
    videoCanvas.view = self.remoteView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    [self.rtcEngineKit setupRemoteVideo:videoCanvas];
}

- (AgoraVideoFormat)getVideoPixelFormatPreference{
    return AgoraVideoFormatBGRA;
}
- (AgoraVideoFrameProcessMode)getVideoFrameProcessMode{
    return AgoraVideoFrameProcessModeReadWrite;
}

- (CVPixelBufferRef)processFrame:(CVPixelBufferRef)frame {
    [[FUTestRecorder shareRecorder] processFrameWithLog];
    if (![FUDemoManager shared].shouldRender) {
        return frame;
    }
    [[FUDemoManager shared] checkAITrackedResult];
    [[FUDemoManager shared] updateBeautyBlurEffect];
    FURenderInput *input = [[FURenderInput alloc] init];
    input.pixelBuffer = frame;
    //默认图片内部的人脸始终是朝上，旋转屏幕也无需修改该属性。
    input.renderConfig.imageOrientation = FUImageOrientationUP;
    //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
    input.renderConfig.gravityEnable = YES;
    input.renderConfig.stickerFlipH = _isFrontCamera;
    input.renderConfig.isFromFrontCamera = _isFrontCamera;
//    input.renderConfig.isFromMirroredCamera = YES;
    FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
    return output.pixelBuffer;
}

@end
