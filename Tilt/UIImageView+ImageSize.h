//
//  UIImageView+ImageSize.h
//  Tilt
//
//  Created by Eric Harmon on 10/31/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ImageSize)

//Found from SO http://stackoverflow.com/questions/6278876/how-to-know-the-image-size-after-applying-aspect-fit-for-the-image-in-an-uiimage

-(CGSize)imageSizeAfterAspectFit;

@end
