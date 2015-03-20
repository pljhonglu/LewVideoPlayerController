//
//  LewVideoController.m
//  LewVideoPlayerController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import "LewVideoController.h"

void *kCurrentItemDidChangeKVO  = &kCurrentItemDidChangeKVO;
void *kStatusDidChangeKVO       = &kStatusDidChangeKVO;
void *kLoadTimeRangesKVO        = &kLoadTimeRangesKVO;

/*************************************************************/
/*                    _LewVideoController_Net                */
/*************************************************************/

@interface _LewVideoController_Net : LewVideoController
@property (nonatomic, strong)AVPlayerItem *playerItem;

- (instancetype)initWithNetURL:(NSURL *)url;
@end

/*************************************************************/
/*                    _LewVideoController_Local              */
/*************************************************************/

@interface _LewVideoController_Local : LewVideoController
@property (nonatomic,strong)NSArray *playerItems;
@property (nonatomic,assign)NSInteger indexOfPlayingItem;
//@property (nonatomic,strong)NSArray *itemTimeArray;

- (instancetype)initWithLocalURLArray:(NSArray *)urlArray;
@end

/*************************************************************/
/*                    LewVideoController                     */
/*************************************************************/

@interface LewVideoController ()
@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)id timeObserver;// 检测播放进度
@property (nonatomic, assign)CMTime videoDuration;// 视频总时长
@property (nonatomic, assign)CMTime playedItemTime; // 播放过的playerItem的时长

@end

/*************************************************************/
/*                    LewVideoController.m                   */
/*************************************************************/

@implementation LewVideoController

#pragma mark - init

+ (instancetype)videoControllerWithNetURL:(NSURL *)url{
    _LewVideoController_Net *videoController = [[_LewVideoController_Net alloc]initWithNetURL:url];
    [videoController _registerPlayerKVO];
    [videoController _registerPlayerItemKVO:videoController.player.currentItem];
    [videoController _addNotification];

    return videoController;
}
+ (instancetype)videoControllerWithLocalURLArray:(NSArray *)urlArray{
    _LewVideoController_Local *videoController = [[_LewVideoController_Local alloc]initWithLocalURLArray:urlArray];
    [videoController _registerPlayerKVO];
    [videoController _registerPlayerItemKVO:videoController.player.currentItem];
    [videoController _addNotification];
    return videoController;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _playedItemTime = kCMTimeZero;
        _videoDuration = kCMTimeZero;
    }
    return self;
}

#pragma mark - public method

- (void)play{
    [_player play];
}

- (void)pause{
    [_player pause];
}

- (void)stop{
    [self _unRegiseterPlayerItemKVO:_player.currentItem];
}

- (void)replaceWithNewNetURL:(NSURL *)url{
    [_player pause];
    _videoDuration = kCMTimeZero;
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _videoDuration = playerItem.asset.duration;
    [_player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)seekToTime:(CMTime)time{
    [_player seekToTime:time];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler{
    NSLog(@"time value %@, time scale %@",@(time.value),@(time.timescale));
    [_player seekToTime:time completionHandler:completionHandler];
}

#pragma mark - init

//- (void)_playerItemDidChanged:(AVPlayerItem *)currentItem oldItem:(AVPlayerItem *)oldItem{
//    if (oldItem) {
//        [self _unRegiseterPlayerItemKVO:oldItem];
//    }
//    if (currentItem) {
//        [self _registerPlayerItemKVO:currentItem];
//    }
//}

- (void)_registerPlayerItemKVO:(AVPlayerItem *)item{
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusDidChangeKVO];// 视频加载状态
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:kLoadTimeRangesKVO];// 监听loadedTimeRanges属性
}

- (void)_unRegiseterPlayerItemKVO:(AVPlayerItem *)item{
    [item removeObserver:self forKeyPath:@"status" context:kStatusDidChangeKVO];
    [item removeObserver:self forKeyPath:@"loadedTimeRanges" context:kLoadTimeRangesKVO];
}

- (void)_registerPlayerKVO{
    __weak typeof(_player) weakPlayer = _player;
    __weak typeof(self) weakSelf = self;
    
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(3, 30) queue:NULL usingBlock:^(CMTime time){
        //获取当前时间
        CMTime currentTime = CMTimeAdd(weakSelf.playedItemTime, weakPlayer.currentTime);
        
        if (weakSelf.delegate) {
            [weakSelf.delegate LewVideoPlayingWithCurrentTime:currentTime];
        }
    }];
    [_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:kCurrentItemDidChangeKVO];
}

- (void)_unRegisterPlayerKVO{
    [_player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    [_player removeObserver:self forKeyPath:@"currentItem" context:kCurrentItemDidChangeKVO];
}

- (void)_addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerItemDidPlayToEnd:(NSNotification *)nf{
    if (self.delegate && [self.delegate respondsToSelector:@selector(lewVideoDidPlayToEnd)]) {
        [self.delegate lewVideoDidPlayToEnd];
    }
}
#pragma mark - observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (kStatusDidChangeKVO == context) {
//        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        if (_player.status == AVPlayerStatusReadyToPlay) {
            //视频加载完成,去掉等待
            if (_delegate && [_delegate respondsToSelector:@selector(lewVideoReadyToPlay)]) {
                [_delegate lewVideoReadyToPlay];
            }
        }
    }else if (kLoadTimeRangesKVO == context){
        NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval bufferTime = startSeconds + durationSeconds;// 计算缓冲总进度
        if (_delegate && [_delegate respondsToSelector:@selector(lewVideoLoadedProgress:)]) {
            [_delegate lewVideoLoadedProgress:(bufferTime/CMTimeGetSeconds(_videoDuration))];
        }
    }
//    else if (kCurrentItemDidChangeKVO == context){
//        NSLog(@"currentItem did change");
//        AVPlayerItem *currentItem = change[NSKeyValueChangeNewKey];
//        AVPlayerItem *oldPlayerItem = change[NSKeyValueChangeOldKey];
//        _playedItemTime = CMTimeAdd(_playedItemTime, oldPlayerItem.duration);
//        [self _unRegiseterPlayerItemKVO:oldPlayerItem];
//        [self _registerPlayerItemKVO:currentItem];
//    }
}


- (void)dealloc{
    [self _unRegisterPlayerKVO];
    [self _unRegiseterPlayerItemKVO:_player.currentItem];
    NSLog(@"video controller dealloc");
}
@end

/*************************************************************/
/*               _LewVideoController_Net.m                   */
/*************************************************************/

@implementation _LewVideoController_Net

- (instancetype)initWithNetURL:(NSURL *)url{
    self = [super init];
    if (self) {
        _playerItem = [AVPlayerItem playerItemWithURL:url];
        self.videoDuration = _playerItem.asset.duration;
        self.player = [AVPlayer playerWithPlayerItem:_playerItem];
        NSLog(@"duration is %@",@(self.videoDuration.value/self.videoDuration.timescale));
    }
    return self;
}

//- (void)playerItemDidPlayToEnd:(NSNotification *)nf{
//
//    if (self.delegate && [self.delegate respondsToSelector:@selector(lewVideoDidPlayToEnd)]) {
//        [self.delegate lewVideoDidPlayToEnd];
//    }
//}

@end

/*************************************************************/
/*               _LewVideoController_Local.m                 */
/*************************************************************/

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
        _playerItems = [playItems copy];
        _indexOfPlayingItem = 0;
        self.player = [AVPlayer playerWithPlayerItem:[_playerItems firstObject]];
        NSLog(@"duration is %@",@(self.videoDuration.value/self.videoDuration.timescale));
    }
    return self;
}

- (void)playerItemDidPlayToEnd:(NSNotification *)nf{
    NSLog(@"playerItemDidPlayToEnd");
    _indexOfPlayingItem++;
    if (_indexOfPlayingItem < _playerItems.count) {
        [self _unRegiseterPlayerItemKVO:self.player.currentItem];
        self.playedItemTime = CMTimeAdd(self.playedItemTime, self.player.currentItem.duration);

        [self.player replaceCurrentItemWithPlayerItem:_playerItems[_indexOfPlayingItem]];
        [self.player play];
        [self _registerPlayerItemKVO:_playerItems[_indexOfPlayingItem]];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(lewVideoDidPlayToEnd)]) {
            [self.delegate lewVideoDidPlayToEnd];
        }
    }
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler{
    CMTime addTime = kCMTimeZero;
    [self _unRegiseterPlayerItemKVO:self.player.currentItem];
    for (NSInteger i = 0; i<_playerItems.count; i++) {
        AVPlayerItem *item = _playerItems[i];
        addTime = CMTimeAdd(addTime, item.asset.duration);

        int32_t res =  CMTimeCompare(time, addTime);
        if (res<=0) {
            self.playedItemTime = CMTimeSubtract(addTime, item.asset.duration);
            CMTime subTime = CMTimeSubtract(time,self.playedItemTime);

            [self.player replaceCurrentItemWithPlayerItem:item];
            self.playedItemTime = CMTimeSubtract(addTime, item.asset.duration);

            [item seekToTime:subTime completionHandler:completionHandler];
            [self _registerPlayerItemKVO:item];
            _indexOfPlayingItem = i;
            break;
        }
    }
}
@end