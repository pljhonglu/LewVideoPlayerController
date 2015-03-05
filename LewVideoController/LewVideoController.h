//
//  LewVideoController.h
//  LewVideoPlayerController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LewVideoController : NSObject
@property (nonatomic,strong)AVPlayer *player;

@end

@interface LewVideoController (LocalView)

@end

@interface LewVideoController (NetVideo)

@end