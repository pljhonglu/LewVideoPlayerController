//
//  LewVideoPlayerViewController.h
//  LewVideoPlayerController
//
//  Created by deng on 15/3/10.
//  Copyright (c) 2015年 独奏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LewVideoPlayerViewController : UIViewController
- (instancetype)initWithNetURL:(NSURL *)url;

- (instancetype)initWithLocalURLArray:(NSArray *)urlArray;


@end
