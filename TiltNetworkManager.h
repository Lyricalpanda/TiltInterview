//
//  TiltNetworkManager.h
//  Tilt
//
//  Created by Eric Harmon on 10/27/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPSessionManager;
@class AFHTTPRequestOperation;

@interface TiltNetworkManager : NSObject

+ (void) searchImagesWithQuery:(NSString *)query atIndex:(int)index andSuccessBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock andFailureBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failureBlock;

+ (void) searchHotTrendsWithSuccessBlock:(void (^)(AFHTTPRequestOperation *task, id responseObject))successBlock andFailureBlock:(void (^)(AFHTTPRequestOperation *task, NSError *error))failureBlock;
@end
