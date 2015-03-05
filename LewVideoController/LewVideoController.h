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

- (void)LewVideoPlayProgress:(CGFloat *)progress;

@end

@interface LewVideoController : NSObject
@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)AVPlayerLayer *playerLayer;

- (instancetype)initWithVideoURL:(NSString *)url;

- (void)play;
- (void)pause;
- (void)cancel;
@end
