//
//  AppDelegate.m
//  UIImageView+BlocksOperation
//
//  Created by t_hayashi on 12/04/29.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "AppDelegate.h"
#import "UIImageView+BlocksOperation.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
	[_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	
	{
		UIProgressView *progressView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
		progressView.frame = CGRectMake(15, 40, 140, 20);
		[self.window addSubview:progressView];
		
		UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
		imageView.frame = CGRectMake(15, 60, 140, 140);
		imageView.tag = 2112;
		[imageView requestWithURL:[NSURL URLWithString:@"http://farm8.staticflickr.com/7151/6760135001_14c59a1490_o.jpg"]
					   animations:^(float progress) {
						   [progressView setProgress:progress animated:YES];
					   }
					   completion:^(UIImage *image, NSError *error) {
						   if (!error) imageView.alpha = 0.0;
						   [imageView setImage:image];
						   [UIView animateWithDuration:0.2
											animations:^{
												imageView.alpha = 1.0;
												progressView.alpha = 0.0;
											}
											completion:^(BOOL finished) {
												[progressView removeFromSuperview];
											}
							];
					   }
		 ];
		
		[self.window addSubview:imageView];
	}
	{
		UIProgressView *progressView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
		progressView.frame = CGRectMake(165, 40, 140, 20);
		[self.window addSubview:progressView];
		
		UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
		imageView.frame = CGRectMake(165, 60, 140, 140);
		imageView.tag = 2113;
		[imageView requestWithURL:[NSURL URLWithString:@"http://farm8.staticflickr.com/7151/6760135001_14c59a1490_o.jpg"]
					   animations:^(float progress) {
						   [progressView setProgress:progress animated:YES];
					   }
					   completion:^(UIImage *image, NSError *error) {
						   if (!error) imageView.alpha = 0.0;
						   [imageView setImage:image];
						   [UIView animateWithDuration:0.2
											animations:^{
												imageView.alpha = 1.0;
												progressView.alpha = 0.0;
											}
											completion:^(BOOL finished) {
												[progressView removeFromSuperview];
											}
							];
					   }
		 ];
		
		[self.window addSubview:imageView];
	}
	

	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	cancelButton.frame = CGRectMake(100, 360, 120, 44);
	[cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.window addSubview:cancelButton];
	
	
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)cancelButtonClicked:(UIButton *)sender
{
	UIImageView *imageView = (UIImageView *)[self.window viewWithTag:2112];
	[imageView cancel];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
