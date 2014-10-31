//
//  ImageResult.h
//  Tilt
//
//  Created by Eric Harmon on 10/27/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageResult : NSObject

@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *thumbnailLink;
@property (nonatomic) int thumbnailHeight;
@property (nonatomic) int thumbnailWidth;

@end
