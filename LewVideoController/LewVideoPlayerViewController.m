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

@property (nonatomic, assign)BOOL isPlaying;
@end

@implementation LewVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.videoView layoutIfNeeded];
    _videoController.playerLayer.frame = CGRectMake(100, -60, 320, 568);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    
}

- (instancetype)initWithLocalURLArray:(NSArray *)urlArray{
    self = [super init];
    if (self) {
        _urlArray = urlArray;
        _videoController = [LewVideoController videoControllerWithLocalURLArray:urlArray];
        _videoController.delegate = self;
        [self.view.layer addSublayer:_videoController.playerLayer];
    }
    return self;
}

- (instancetype)initWithNetURL:(NSURL *)url{
    self = [super init];
    if (self) {
        _videoController = [LewVideoController videoControllerWithNetURL:url];
        _videoController.delegate = self;
        [self.view.layer addSublayer:_videoController.playerLayer];
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


#pragma mark - action
- (IBAction)controlButtonAction:(id)sender{
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
        [_videoController play];
    }else{
        [_videoController pause];
    }
}


- (IBAction)sliderMoveAction:(id)sender{
    CGFloat value = _slider.value;
    CMTime duration = _videoController.videoDuration;
    duration.value = duration.value*value;
    NSLog(@"拖拽  %lld, %d",duration.value,duration.timescale);
//    CMTime time = CMTimeMake(duration.value*value, 10);
//    time.flags = duration.flags;
    [_videoController seekToTime:duration completionHandler:nil];
}
#pragma mark - delegate
- (void)LewVideoPlayingWithCurrentTime:(CMTime)currentTime{
    CGFloat progress = CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(_videoController.videoDuration);

    _slider.value = progress;
}


- (void)lewVideoReadyToPlay{
    NSLog(@"缓冲完毕");
}

- (void)lewVideoLoadedProgress:(CGFloat)progress{
//    _progress.progress = progress;
}

- (void)lewVideoDidPlayToEnd{
    NSLog(@"播放结束");
}

@end
