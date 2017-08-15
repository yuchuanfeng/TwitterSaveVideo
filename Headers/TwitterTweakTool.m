//
//  InstagramTweakTool.m
//  78-huibian
//
//  Created by 于传峰 on 2017/5/21.
//  Copyright © 2017年 于传峰. All rights reserved.
//

#import "TwitterTweakTool.h"

#import "YQAssetOperator.h"

@interface T1AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

static TwitterTweakTool* _sharedInstance;

@interface TwitterTweakTool()<NSURLSessionDownloadDelegate>
@property ( nonatomic, strong) NSURLSession* session;
@property ( nonatomic, strong) NSURLSessionDownloadTask* downloadTask;
@property ( nonatomic, strong) YQAssetOperator* operator;
@property ( nonatomic, strong) UIProgressView* progressView;
@end

@implementation TwitterTweakTool
+ (instancetype)shareTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
        _sharedInstance.operator = [[YQAssetOperator alloc] initWithFolderName:@"twitter"];
    });
    return _sharedInstance;
}
+ (void)initialize
{
    [TwitterTweakTool shareTool];
}
- (id)copyWithZone:(NSZone *)zone
{
    return [TwitterTweakTool shareTool];;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [TwitterTweakTool shareTool];
}

+ (void)downloadAndSaveVideo:(NSString *)url {
    [_sharedInstance downloadMP4Video:url];
    //    [_sharedInstance getMP4Url:url complete:^(NSString *mp4URL) {
    //    }];
}

- (void)getMP4Url:(NSString *)m3u8URL complete: (void (^)(NSString *mp4URL))complete{
    //入参直接拼接在URL后（？衔接），多个入参用&分割
    NSString *urlstring = [NSString stringWithFormat:@"http://hishow.top/toMp4?url=%@", m3u8URL];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //获取的内容是字符串
        if (!error && complete) {
            NSDictionary *str = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([str[@"code"] integerValue] == 1) {
                NSString* mp4URL = [NSString stringWithFormat:@"http://hishow.top/toMp4%@", str[@"path"]];
                complete(mp4URL);
            }
        }
    }];
    [dataTask resume];
}

- (void)downloadMP4Video:(NSString *)mp4URL {
    
    [_sharedInstance setupProgressBar];
    NSURL* url = [NSURL URLWithString:mp4URL];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
    self.downloadTask = [self.session downloadTaskWithURL:url];
    
    [self.downloadTask resume];
}


#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"didFinishDownloadingToURL: %@", location);
    NSString* lastCom = [location lastPathComponent];
    lastCom = [lastCom stringByReplacingCharactersInRange:[lastCom rangeOfString:[lastCom pathExtension]] withString:@"mp4"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* docuPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES).lastObject;
    NSString* toPath = [docuPath stringByAppendingPathComponent:lastCom];
    NSString* fromPath = [location.absoluteString stringByReplacingOccurrencesOfString:@"file:///private" withString:@""];
    NSError* error;
    [fileManager moveItemAtPath:fromPath toPath:toPath error:&error];

    if (error) {
//        NSLog(@"moveError: %@", error.userInfo);
        NSLog(@"6************************");
    }else {
        NSLog(@"download_success*****************");
        [self.operator saveVideoPath:toPath];
    }
    NSLog(@"location: %@", fromPath);
    NSLog(@"toUrl: %@", toPath);
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CGFloat progress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSLog(@"didWriteData: %02f", progress);
    self.progressView.progress = progress;
    if (progress>=1.0) {
        [self.progressView removeFromSuperview];
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"didResumeAtOffset: %zd", fileOffset);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"didCompleteWithError: %@", error);
}


- (void)setupProgressBar {
//    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    UIWindow* window = [delegate window];
    UIViewController* mainVC = [TwitterTweakTool getRootVC];
    UIProgressView* progressView = [[UIProgressView alloc] init];
    progressView.backgroundColor = [UIColor greenColor];
    [mainVC.view addSubview:progressView];
    [mainVC.view bringSubviewToFront:progressView];
    self.progressView = progressView;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat borderMargin = 10;
    progressView.frame = CGRectMake(borderMargin, 25, width-borderMargin*2, 5);
    progressView.trackTintColor = [UIColor yellowColor];
    progressView.progressTintColor = [UIColor redColor];
}

+ (void)showTitle:(NSString *)title text:(NSString *)text {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:nil]];
        [[TwitterTweakTool getRootVC] presentViewController:alertVC animated:YES completion:nil];
//        [vc presentViewController:alertVC animated:YES completion:nil];
    });
}


+ (UIViewController *)getRootVC {
    
    T1AppDelegate* delegate = (T1AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow* window = [delegate window];
    UIViewController* rootVC = [self findBestViewController:window.rootViewController];
    NSLog(@"window.rootViewController****%@", rootVC);
    return rootVC;
    
//    UIResponder* nextR;
//    nextR = [view nextResponder];
//    while (!nextR || ![nextR isKindOfClass:[UIViewController class]] )
//    {
//        nextR = [nextR nextResponder];
//        if (!nextR)
//        {
//            break;
//        }
//    }
//    
//    UIViewController* controller = (UIViewController *)nextR;
//    
//    return controller;
}

+ (UIViewController *) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self  findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController  *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController * svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController  *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

@end
