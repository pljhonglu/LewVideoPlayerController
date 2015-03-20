//
//  ViewController.m
//  LewVideoPlayerController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import "ViewController.h"
#import "LewVideoPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    _videoController = [LewVideoController videoControllerWithNetURL:[NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?ts=1418976465&keyframe=1&vid=XODQ3Mzc4Mjg0&type=mp4&sid=5418976406975309c021d&token=8166&oip=976715752&did=3151cdbf1449478fad97c27cd5fa755b2fff49fa&ctype=30&ev=1&ep=1VISwfIJX4vt%2BiavWdaT%2FGvJ0ztxLn%2BQnO1BMB7BDWgCGhqCgNwxphPOt8njUfBX"]];
    
//    _seekTime = CMTimeMake(600, 1);
//    _seekTime.flags = kCMTimeFlags_Valid;
    
//    NSURL *url_0 = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp4"];
//    NSURL *url_1 = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp4"];
//    NSURL *url_2 = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"mp4"];
//    
//    NSURL *url_0 = [NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?ts=1418976465&keyframe=1&vid=XODQ3Mzc4Mjg0&type=mp4&sid=5418976406975309c021d&token=8166&oip=976715752&did=3151cdbf1449478fad97c27cd5fa755b2fff49fa&ctype=30&ev=1&ep=1VISwfIJX4vt%2BiavWdaT%2FGvJ0ztxLn%2BQnO1BMB7BDWgCGhqCgNwxphPOt8njUfBX"];
//    NSURL *url_1 = [NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?ts=1418976465&keyframe=1&vid=XODQ3Mzc4Mjg0&type=mp4&sid=5418976406975309c021d&token=8166&oip=976715752&did=3151cdbf1449478fad97c27cd5fa755b2fff49fa&ctype=30&ev=1&ep=1VISwfIJX4vt%2BiavWdaT%2FGvJ0ztxLn%2BQnO1BMB7BDWgCGhqCgNwxphPOt8njUfBX"];
    
//    _videoController = [LewVideoController videoControllerWithLocalURLArray:@[url_0,url_1,url_2]];
//    _videoController.delegate = self;
//    [_videoView.layer addSublayer:_videoController.playerLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)playLocalVideoAction:(id)sender{
    NSURL *url_0 = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp4"];
    NSURL *url_1 = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp4"];
    NSURL *url_2 = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"mp4"];
    
    LewVideoPlayerViewController *vc = [[LewVideoPlayerViewController alloc]initWithLocalURLArray:@[url_0,url_1,url_2]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)playNetVideoAction:(id)sender{
    
    LewVideoPlayerViewController *vc = [[LewVideoPlayerViewController alloc]initWithNetURL:[NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?ts=1418976465&keyframe=1&vid=XODQ3Mzc4Mjg0&type=mp4&sid=5418976406975309c021d&token=8166&oip=976715752&did=3151cdbf1449478fad97c27cd5fa755b2fff49fa&ctype=30&ev=1&ep=1VISwfIJX4vt%2BiavWdaT%2FGvJ0ztxLn%2BQnO1BMB7BDWgCGhqCgNwxphPOt8njUfBX"]];
    [self presentViewController:vc animated:YES completion:nil];

}
@end
