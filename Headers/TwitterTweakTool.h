//
//  InstagramTweakTool.h
//  78-huibian
//
//  Created by 于传峰 on 2017/5/21.
//  Copyright © 2017年 于传峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterTweakTool : NSObject

@property ( nonatomic, strong) UIView* backView;

+ (instancetype)shareTool;

+ (void)showTitle:(NSString *)title text:(NSString *)text;

+ (void)downloadAndSaveVideo:(NSString *)url;
@end
