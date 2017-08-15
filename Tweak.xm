/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/
#import "Headers/Headers.h"
#import "Headers/TwitterTweakTool.h"
#import "Headers/YQAssetOperator.h"

%hook T1SlideshowViewController
// %hook T1ImmersiveVideoCollectionCell
- (void)viewDidLoad {
	%orig;
	[self setupNewUI:self.view]; 
}
// - (void)viewWillAppear:(BOOL)animated {
//     %orig;
//     [TwitterTweakTool shareTool].backView.hidden = NO;
// }
%new
- (void)setupNewUI:(UIView* )contentView {
    UIView* backView = [[UIView alloc] init];
    [contentView addSubview:backView];
    [contentView bringSubviewToFront:backView];
    backView.frame = CGRectMake(20, 40, 160, 30);
    backView.backgroundColor = [UIColor clearColor];
    TwitterTweakTool* tool = [TwitterTweakTool shareTool];
	tool.backView = backView;
    
    UIButton* urlButton = [[UIButton alloc] init];
    [urlButton addTarget:self action:@selector(urlButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:urlButton];
    [urlButton setTitle:@"复制URL" forState:UIControlStateNormal];
    urlButton.frame = CGRectMake(0, 0, 70, 30);
    urlButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [urlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    urlButton.layer.cornerRadius = 4;
    urlButton.clipsToBounds = YES;
    urlButton.titleLabel.font = [UIFont systemFontOfSize:13];
    
    UIButton* saveButton = [[UIButton alloc] init];
    [saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:saveButton];
    [saveButton setTitle:@"保存到本地" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(80, 0, 70, 30);
    saveButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.layer.cornerRadius = 4;
    saveButton.clipsToBounds = YES;
    saveButton.titleLabel.font = [UIFont systemFontOfSize:13];
}

%new
- (void)urlButtonAction:(UIButton *)button {
	NSLog(@"urlButtonAction*****************");
	// [TwitterTweakTool shareTool].backView.hidden = YES;
	button.hidden = YES;
    NSString* urlStr = [self getVideoUrl];
    UIPasteboard* pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = urlStr;
    
    [TwitterTweakTool showTitle:@"Copy url success !" text:urlStr];
}

%new
- (void)saveButtonAction:(UIButton *)button {
	NSLog(@"saveButtonAction*****************");
	// [TwitterTweakTool shareTool].backView.hidden = YES;
	button.hidden = YES;
	NSString* urlStr = [self getVideoUrl];
    [TwitterTweakTool downloadAndSaveVideo:urlStr];
}

%new
- (NSString *)getVideoUrl {
    TwitterEntityMedia* media =  self.statusView.media;
    TFNTwitterEntityMediaVideoInfo* videoInfo = media.videoInfo;
    TFNTwitterEntityMediaVideoVariant* last = videoInfo.variants.lastObject;
    return last.url;
}


%end
