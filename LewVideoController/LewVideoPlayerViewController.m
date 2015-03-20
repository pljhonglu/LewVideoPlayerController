//
//  LewVideoPlayerViewController.m
//  LewVideoPlayerController
//
//  Created by deng on 15/3/10.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import "LewVideoPlayerViewController.h"
#import "LewVideoController.h"

@interface LewVideoPlayerViewController ()<LewVideoControllerDelegate>
@property (nonatomic, strong)NSArray *urlArray;
@property (nonatomic, weak)IBOutlet UIView *videoView;

@property (nonatomic, weak)IBOutlet UISlider *slider;
@property (nonatomic, weak)IBOutlet UILabel *timeLabel;
@property (nonatomic, weak)IBOutlet UIButton *controlButton;

@property (nonatomic, weak)IBOutlet UIView *bottomView;
@property (nonatomic, weak)IBOutlet UIView *topView;

@property (nonatomic, strong)LewVideoController *videoController;

@property (nonatomic, strong)AVPlayerLayer *playerLayer;

@property (nonatomic, assign)BOOL isPlaying;
@end

@implementation LewVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_videoController.player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.videoView.layer addSublayer:_playerLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews{
    _playerLayer.frame = _videoView.bounds;
}

- (instancetype)initWithLocalURLArray:(NSArray *)urlArray{
    self = [super init];
    if (self) {
        _urlArray = urlArray;
        _videoController = [LewVideoController videoControllerWithLocalURLArray:urlArray];
        _videoController.delegate = self;
    }
    return self;
}

- (instancetype)initWithNetURL:(NSURL *)url{
    self = [super init];
    if (self) {
        _videoController = [LewVideoController videoControllerWithNetURL:url];
        _videoController.delegate = self;
    }
    return self;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)timeStringWithCMTime:(CMTime)time{
    NSInteger seconds = time.value/time.timescale;

    NSInteger min = seconds/60;
    
    seconds -= min*60;
    
    return [NSString stringWithFormat:@"-%@:%02ld",@(min),seconds];
}

#pragma mark - action

- (IBAction)goBackAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)controlButtonAction:(id)sender{
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
        [_videoController play];
        [_controlButton setTitle:@"暂停" forState:UIControlStateNormal];
    }else{
        [_videoController pause];
        [_controlButton setTitle:@"播放" forState:UIControlStateNormal];
    }
}

- (IBAction)sliderMoveAction:(id)sender{
    CGFloat value = _slider.value;
    CMTime duration = _videoController.videoDuration;
    duration.value = duration.value*value;
    [_videoController seekToTime:duration completionHandler:^(BOOL finished) {
        [_videoController play];
    }];
}

static bool isMove = YES;
- (IBAction)sliderStartToMoveAction:(id)sender{
//    isMove = NO;
    [_videoController pause];
//    NSLog(@"start to move");
}
#pragma mark - delegate
- (void)LewVideoPlayingWithCurrentTime:(CMTime)currentTime{
//    if (isMove) {
        CGFloat progress = CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(_videoController.videoDuration);
        _slider.value = progress;
        CMTime time = CMTimeSubtract(_videoController.videoDuration, currentTime);
        _timeLabel.text = [self timeStringWithCMTime:time];
//    }
}

- (void)lewVideoReadyToPlay{
    NSLog(@"缓冲完毕");
}

- (void)lewVideoLoadedProgress:(CGFloat)progress{

}

- (void)lewVideoDidPlayToEnd{
    NSLog(@"播放结束");
}

@end
