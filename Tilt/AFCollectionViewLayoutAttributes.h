//
//  AFCollectionViewLayoutAttributes.h
//  Tilt
//
//  Created by Eric Harmon on 10/31/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AFCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) BOOL shouldRasterize;
@property (nonatomic, assign) CGFloat maskingValue;

@end
