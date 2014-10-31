//
//  AFCollectionViewLayoutAttributes.m
//  Tilt
//
//  Created by Eric Harmon on 10/31/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import "AFCollectionViewLayoutAttributes.h"

@implementation AFCollectionViewLayoutAttributes

-(id)copyWithZone:(NSZone *)zone
{
    AFCollectionViewLayoutAttributes *attributes = [super copyWithZone:zone];
    
    attributes.shouldRasterize = self.shouldRasterize;
    attributes.maskingValue = self.maskingValue;
    
    return attributes;
}

@end
