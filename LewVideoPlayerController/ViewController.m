//
//  ViewController.m
//  LewVideoPlayerController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import "ViewController.h"
#import "LewVideoController.h"

@interface ViewController ()
@property (nonatomic, strong)IBOutlet UIView *videoView;
@property (nonatomic, strong)LewVideoController *videoController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _videoController = [[LewVideoController alloc]initWithVideoURL:@"http://pl.youku.com/playlist/m3u8?ts=1418976465&keyframe=1&vid=XODQ3Mzc4Mjg0&type=mp4&sid=5418976406975309c021d&token=8166&oip=976715752&did=3151cdbf1449478fad97c27cd5fa755b2fff49fa&ctype=30&ev=1&ep=1VISwfIJX4vt%2BiavWdaT%2FGvJ0ztxLn%2BQnO1BMB7BDWgCGhqCgNwxphPOt8njUfBX"];
    [_videoView.layer addSublayer:_videoController.playerLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.videoView layoutIfNeeded];
    _videoController.playerLayer.frame = _videoView.bounds;

    [_videoController play];
}
@end
