//
//  LewVideoController.m
//  LewVideoPlayerController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import "LewVideoController.h"

@interface _LewVideoController_Net : LewVideoController
@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)AVPlayerLayer *playerLayer;
@property (nonatomic, strong)id timeObserver;// 检测播放进度
@property (nonatomic, assign)CMTime videoDuration;// 视频总时长
@property (nonatomic, assign)CMTime currentTime; // 当前播放时长

@property (nonatomic, strong)NSURL *videoURL;

- (instancetype)initWithNetURL:(NSURL *)url;
@end

@interface _LewVideoController_Local : LewVideoController
- (instancetype)initWithLocalURLArray:(NSArray *)urlArray;
@end

@interface LewVideoController ()
@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)AVPlayerLayer *playerLayer;
@property (nonatomic, strong)id timeObserver;// 检测播放进度
@property (nonatomic, assign)CMTime videoDuration;// 视频总时长

@property (nonatomic, assign)CMTime currentTime; // 当前播放时长
@end

@implementation LewVideoController

#pragma mark - init

+ (instancetype)videoControllerWithNetURL:(NSURL *)url{
    _LewVideoController_Net *videoController = [[_LewVideoController_Net alloc]initWithNetURL:url];
    [videoController _addProgressObserver];
    [videoController _addPlayerStausObserver];
    [videoController _addLoadedProcessObserver];
    return videoController;
}
+ (instancetype)videoControllerWithLocalURLArray:(NSArray *)urlArray{
    _LewVideoController_Local *videoController = [[_LewVideoController_Local alloc]initWithLocalURLArray:urlArray];
    [videoController _addProgressObserver];
//    [videoController _addPlayerStausObserver];

    return videoController;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
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
    [_player pause];
    
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    _videoDuration = kCMTimeZero;
    _currentTime = kCMTimeZero;
}

- (void)replaceWithNewNetURL:(NSURL *)url{
    [self cancel];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _videoDuration = playerItem.asset.duration;
    [_player replaceCurrentItemWithPlayerItem:playerItem];
    [self _addPlayerStausObserver];
    [self _addLoadedProcessObserver];
}

- (void)seekToTime:(CMTime)time{
    [_player seekToTime:time];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler{
    [_player seekToTime:time completionHandler:completionHandler];
}

#pragma mark - init
- (void)_addProgressObserver{
    __weak typeof(_player) weakPlayer = _player;
    __weak typeof(self) weakSelf = self;
    
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(3, 30) queue:NULL usingBlock:^(CMTime time){
        //获取当前时间
        weakSelf.currentTime = weakPlayer.currentTime;
        
        if (weakSelf.delegate) {
            [weakSelf.delegate LewVideoPlayingWithCurrentTime:weakSelf.currentTime];
        }
    }];
}
- (void)_removeProgressObserver{
    [_player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
}

- (void)_addPlayerStausObserver{
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 视频加载状态
}

- (void)_addLoadedProcessObserver{
    [_player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            //视频加载完成,去掉等待
            if (_delegate) {
                [_delegate lewVideoReadyToPlay];
            }
        }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval bufferTime = startSeconds + durationSeconds;// 计算缓冲总进度
        if (_delegate) {
            [_delegate lewVideoLoadedProgress:(bufferTime/CMTimeGetSeconds(_videoDuration))];
        }
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


- (void)dealloc{
    [self _removeProgressObserver];
}
@end


@implementation _LewVideoController_Net

- (instancetype)initWithNetURL:(NSURL *)url{
    self = [super init];
    if (self) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        self.videoDuration = playerItem.asset.duration;
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        NSLog(@"duration is %@",@(self.videoDuration.value/self.videoDuration.timescale));
    }
    return self;
}


@end

@implementation _LewVideoController_Local

- (instancetype)initWithLocalURLArray:(NSArray *)urlArray{
    self = [super init];
    if (self) {
        __block CMTime duration = kCMTimeZero;
        NSMutableArray *playItems = [[NSMutableArray alloc]initWithCapacity:urlArray.count];
        [urlArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AVPlayerItem *playItem = [AVPlayerItem playerItemWithURL:obj];
            duration = CMTimeAdd(duration, playItem.asset.duration);
            [playItems addObject:playItem];
        }];
        self.videoDuration = duration;
        self.player = [AVQueuePlayer queuePlayerWithItems:playItems];
        NSLog(@"duration is %@",@(self.videoDuration.value/self.videoDuration.timescale));

    }
    return self;
}

@end