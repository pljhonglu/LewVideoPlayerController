//
//  LewVideoController.m
//  LewVideoPlayerController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import "LewVideoController.h"

@interface _LewVideoController_Net : LewVideoController

@end
@interface _LewVideoController_Local : LewVideoController

@end

@interface LewVideoController ()
@property (nonatomic,strong)id timeObserver;// 检测播放进度
@property (nonatomic,assign)CGFloat videoLength;// 视频总时长

@end

@implementation LewVideoController

#pragma mark - init
- (instancetype)initWithVideoURL:(NSString *)url{
    self = [super init];
    if (self) {
        _player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
        
    }
    return self;
}

#pragma mark - getter/setter
- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer && _player) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _playerLayer;
}
#pragma mark - public method

- (void)play{
    [_player play];
}

- (void)pause{
    [_player pause];
}

- (void)cancel{
    
}

#pragma mark - init
- (void)addProgressObserver{
    __weak typeof(_player) weakPlayer = _player;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(3, 30) queue:NULL usingBlock:^(CMTime time){

        //获取当前时间
        CMTime currentTime = weakPlayer.currentItem.currentTime;
        double currentPlayTime = (double)currentTime.value/currentTime.timescale;
        
        //转成秒数
        CGFloat remainingTime = (*movieLength_) - currentPlayTime;
        movieProgressSlider_.value = currentPlayTime/(*movieLength_);
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:currentPlayTime];
        NSDate *remainingDate = [NSDate dateWithTimeIntervalSince1970:remainingTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        [formatter setDateFormat:(currentPlayTime/3600>=1)? @"h:mm:ss":@"mm:ss"];
        NSString *currentTimeStr = [formatter stringFromDate:currentDate];
        [formatter setDateFormat:(remainingTime/3600>=1)? @"h:mm:ss":@"mm:ss"];
        NSString *remainingTimeStr = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:remainingDate]];
        
        currentLable_.text = currentTimeStr;
        remainingTimeLable_.text = remainingTimeStr;

    }];
}
@end


@implementation _LewVideoController_Net

@end

@implementation _LewVideoController_Local



@end