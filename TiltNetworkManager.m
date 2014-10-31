//
//  TiltNetworkManager.m
//  Tilt
//
//  Created by Eric Harmon on 10/27/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import "TiltNetworkManager.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"

#define baseURL @"https://www.googleapis.com/customsearch/"
#define cx @"016164822929968605127:zafsrcubryc"

//Created 3 different API keys because the 100 use limit
#define API_KEY @"AIzaSyAYnv8v-1HB1pw012Hdwt-uKf2Taj6ejvU"
//#define API_KEY @"AIzaSyAR12LCQeHzSN8cfDBSrf7gs0bAMw3iUFs"
//#define API_KEY @"AIzaSyC0aa24NEwY0WaLQP7cMxJtlB_VJmiVtwc"

@implementation TiltNetworkManager

+ (id)sharedManager {
    static AFHTTPSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
    return sharedManager;
}

+ (void) searchImagesWithQuery:(NSString *)query atIndex:(int)index andSuccessBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock andFailureBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *queryEscaped = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPSessionManager *sessionManager = [TiltNetworkManager sharedManager];
    NSDictionary *parameters = @{@"searchType":@"image", @"key":API_KEY, @"cx":cx, @"start":[NSString stringWithFormat:@"%d",index]};
    [sessionManager GET:[NSString stringWithFormat:@"v1?q=%@",queryEscaped] parameters:parameters success:successBlock failure:failureBlock
     ];
}

+ (void) searchHotTrendsWithSuccessBlock:(void (^)(AFHTTPRequestOperation *task, id responseObject))successBlock andFailureBlock:(void (^)(AFHTTPRequestOperation *task, NSError *error))failureBlock
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hawttrends.appspot.com/api/terms/"]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:successBlock failure:failureBlock];
    [operation start];
}

@end
