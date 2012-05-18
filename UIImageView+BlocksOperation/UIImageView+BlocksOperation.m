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

@property (copy, nonatomic) void(^animations)(float);
@property (copy, nonatomic) void(^completion)(UIImage *, NSError *);

@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *downloadData;
@property (nonatomic) long long expectedLength;
@property (nonatomic) BOOL isExecuting;

- (void)clearDelegateAndCancel;
@end


@implementation UIImageView (BlocksOperation)

#pragma mark - Public method
+ (NSOperationQueue *)networkQueue
{
	static NSOperationQueue *networkQueue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		networkQueue = [[NSOperationQueue alloc] init];
		networkQueue.maxConcurrentOperationCount = MAX_CONCURRENT_OPERATION_COUNT;
	});
	return networkQueue;
}


- (void)requestWithURL:(NSURL *)URL animations:(void (^)(float))animations completion:(void (^)(UIImage *, NSError *))completion
{
	[self requestWithURL:URL defaultImage:self.defaultImage animations:animations completion:completion];
}

- (void)requestWithURL:(NSURL *)URL defaultImage:(UIImage *)defaultImage animations:(void (^)(float))animations completion:(void (^)(UIImage *, NSError *))completion
{
	if (self.animations || self.completion) {
		[self cancel];
	}
	self.defaultImage = defaultImage;
	self.animations = animations;
	self.completion = completion;
	self.isExecuting = YES;
	
	[self setImage:self.defaultImage];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[[UIImageView networkQueue] addOperationWithBlock:^{
		self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
		[self.connection start];
		
		if (self.connection) {
			do {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
			} while (self.isExecuting);
		}
	}];
}

- (void)cancel
{
	self.isExecuting = NO;
	if (!self.connection) return;
	dispatch_async(dispatch_get_main_queue(), ^{
		NSError *errorReason = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorCancelled userInfo:nil];
		if (self.completion) self.completion(self.defaultImage, errorReason);
		[self clearDelegateAndCancel];
	});
}

#pragma mark - Private method
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)clearDelegateAndCancel
{
	[self.connection cancel];
	self.connection = nil;
	self.downloadData = nil;
	self.animations = nil;
	self.completion = nil;
}
#pragma clang diagnostic pop

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.downloadData = [NSMutableData dataWithLength:0];
	self.expectedLength = [response expectedContentLength];
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.animations) self.animations(0);
	});
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.downloadData appendData:data];
	if (self.expectedLength) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.animations) self.animations((float)self.downloadData.length / self.expectedLength);
		});
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.isExecuting = NO;
	dispatch_queue_t convertQueue = dispatch_queue_create("convert data to image", NULL);
	dispatch_async(convertQueue, ^{
		UIImage *image = [UIImage imageWithData:self.downloadData];
		image = image ? image : self.defaultImage;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.completion) self.completion(image, nil);
			[self clearDelegateAndCancel];
		});
	});
	dispatch_release(convertQueue);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.isExecuting = YES;
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.completion) self.completion(self.defaultImage, error);
		[self clearDelegateAndCancel];
	});
}

#pragma mark - Category property
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

- (BOOL)isExecuting
{
	return [objc_getAssociatedObject(self, @"isExecuting") boolValue];
}

- (void)setIsExecuting:(BOOL)isExecuting
{
	objc_setAssociatedObject(self, @"isExecuting", [NSNumber numberWithBool:isExecuting], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
