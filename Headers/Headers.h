//
//  Headers.h
//  91-saveVideo
//
//  Created by 于传峰 on 2017/8/14.
//  Copyright © 2017年 于传峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Headers : NSObject

@end


@interface TFNTwitterEntityMediaVideoVariant : UIView
@property ( nonatomic, copy) NSString* url;
@end


@interface TFNTwitterEntityMediaVideoInfo : UIView
@property ( nonatomic, strong) NSArray* variants;
@end

@interface TwitterEntityMedia : NSObject
@property ( nonatomic, strong) TFNTwitterEntityMediaVideoInfo* videoInfo;
@end

@interface T1SlideshowStatusView : UIView
@property ( nonatomic, strong) TwitterEntityMedia* media;
@end

//@interface T1ImmersiveVideoCollectionCell : UIView
//@property ( nonatomic, strong) UIView* playerChromeContainerView;
//- (void)setupNewUI:(UIView* )contentView;
//@end


@interface T1SlideshowViewController : UIViewController
@property ( nonatomic, strong) T1SlideshowStatusView* statusView;
- (void)setupNewUI:(UIView* )contentView;
- (NSString *)getVideoUrl;
@end
