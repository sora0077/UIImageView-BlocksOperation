//
//  UIImageView+BlocksOperation.h
//  UIImageView+BlocksOperation
//
//  Created by t_hayashi on 12/04/29.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (BlocksOperation)

- (void)requestWithURL:(NSURL *)URL
			animations:(void(^)(float progress))animations
			completion:(void(^)(UIImage *image, NSError *error))completion;

- (void)requestWithURL:(NSURL *)URL
		  defaultImage:(UIImage *)defaultImage
			animations:(void (^)(float progress))animations
			completion:(void (^)(UIImage *image, NSError *error))completion;



- (void)cancel;
@end
