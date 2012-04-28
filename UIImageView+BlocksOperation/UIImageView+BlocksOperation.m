//
//  UIImageView+BlocksOperation.m
//  UIImageView+BlocksOperation
//
//  Created by t_hayashi on 12/04/29.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "UIImageView+BlocksOperation.h"
#import <objc/runtime.h>

@interface UIImageView () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@end

@interface UIImageView (AddBlocksInPrivate)

@property (copy, nonatomic) void(^animations)(float);
@property (copy, nonatomic) void(^completion)(UIImage *, NSError *);

@property (copy, nonatomic) UIImage *defaultImage;
@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *downloadData;
@property (nonatomic) long long expectedLength;


@end

@implementation UIImageView (BlocksOperation)

- (void)requestWithURL:(NSURL *)URL animations:(void (^)(float))animations completion:(void (^)(UIImage *, NSError *))completion
{
	[self requestWithURL:URL defaultImage:nil animations:animations completion:completion];
}

- (void)requestWithURL:(NSURL *)URL defaultImage:(UIImage *)defaultImage animations:(void (^)(float))animations completion:(void (^)(UIImage *, NSError *))completion// cancel:(void (^)(void))cancel
{
	if (self.animations || self.completion) {
		[self cancel];
	}
	self.defaultImage = defaultImage;
	self.animations = animations;
	self.completion = completion;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self setImage:self.defaultImage];
		
		self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
		[self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		[self.connection start];
	});
}

- (void)cancel
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.completion) {
			self.completion(self.defaultImage, [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorCancelled userInfo:nil]);
		}
		[self.connection cancel];
		self.connection = nil;
		self.downloadData = nil;
		self.animations = nil;
		self.completion = nil;
	});
}

#pragma mark - a
//- (void)

#pragma mark - 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.downloadData = [NSMutableData dataWithLength:0];
	self.expectedLength = [response expectedContentLength];
	dispatch_async(dispatch_get_main_queue(), ^{
		self.animations(0);
	});
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.downloadData appendData:data];
	if (self.expectedLength && self.animations) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.animations((float)self.downloadData.length / self.expectedLength);
		});
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	dispatch_queue_t convertQueue = dispatch_queue_create("convert data to image", NULL);
	dispatch_async(convertQueue, ^{
		UIImage *image = [UIImage imageWithData:self.downloadData];
		if (image == nil) image = self.defaultImage;
		self.downloadData = nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.completion) {
				self.completion(image, nil);
			}
			[self.connection cancel];
			self.connection = nil;
			self.downloadData = nil;
			self.animations = nil;
			self.completion = nil;
		});
	});
	dispatch_release(convertQueue);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.completion) {
			self.completion(self.defaultImage, error);
		}
		[self.connection cancel];
		self.connection = nil;
		self.downloadData = nil;
		self.animations = nil;
		self.completion = nil;
	});
}

@end


@implementation UIImageView (AddBlocksInPrivate)

- (void (^)(float))animations
{
	return objc_getAssociatedObject(self, @"animations");
}

- (void)setAnimations:(void (^)(float))animations
{
	objc_setAssociatedObject(self, @"animations", animations, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIImage *, NSError *))completion
{
	return objc_getAssociatedObject(self, @"completion");
}

- (void)setCompletion:(void (^)(UIImage *, NSError *))completion
{
	objc_setAssociatedObject(self, @"completion", completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *)defaultImage
{
	return objc_getAssociatedObject(self, @"defaultImage");
}

- (void)setDefaultImage:(UIImage *)defaultImage
{
	objc_setAssociatedObject(self, @"defaultImage", defaultImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSURLConnection *)connection
{
	return objc_getAssociatedObject(self, @"connection");
}

- (void)setConnection:(NSURLConnection *)connection
{
	objc_setAssociatedObject(self, @"connection", connection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableData *)downloadData
{
	return objc_getAssociatedObject(self, @"downloadData");
}

- (void)setDownloadData:(NSMutableData *)downloadData
{
	objc_setAssociatedObject(self, @"downloadData", downloadData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long long)expectedLength
{
	return [objc_getAssociatedObject(self, @"expectedLength") longLongValue];
}

- (void)setExpectedLength:(long long)expectedLength
{
	if (expectedLength < 0) expectedLength = 0;
	objc_setAssociatedObject(self, @"expectedLength", [NSNumber numberWithLongLong:expectedLength], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end