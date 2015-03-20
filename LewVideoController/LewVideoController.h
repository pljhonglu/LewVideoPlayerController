//
//  LewVideoController.h
//  LewVideoPlayerController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol LewVideoControllerDelegate <NSObject>
/**
 *  播放进度
 *
 *  @param currentTime 播放进度
 */
- (void)LewVideoPlayingWithCurrentTime:(CMTime)currentTime;
/**
 *  缓冲完毕
 */
- (void)lewVideoReadyToPlay;
/**
 *  缓冲进度
 *
 *  @param progress 缓冲百分比 0.0-1.0
 */
- (void)lewVideoLoadedProgress:(CGFloat)progress;
/**
 *  播放结束
 */
- (void)lewVideoDidPlayToEnd;

@end

//typedef NS_ENUM(NSUInteger, LewVideoPlayerStatus) {
//    LewVideoPlayerStatusPause,
//    LewVideoPlayerStatusPlaying,
//};

@interface LewVideoController : NSObject
@property (nonatomic, strong, readonly)AVPlayer *player;

@property (nonatomic, assign, readonly)CMTime videoDuration;

@property (nonatomic, weak) id<LewVideoControllerDelegate> delegate;

- (void)seekToTime:(CMTime)time;
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler;

+ (instancetype)videoControllerWithNetURL:(NSURL *)url;
+ (instancetype)videoControllerWithLocalURLArray:(NSArray *)urlArray;
//- (instancetype)initWithLocalURL:(NSURL *)url;
//- (instancetype)initWithLocalURLList:(NSArray *)urlList;


- (void)play;
- (void)pause;
- (void)stop;

- (void)replaceWithNewNetURL:(NSURL *)url;
@end
