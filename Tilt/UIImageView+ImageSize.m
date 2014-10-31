//
//  UIImageView+ImageSize.m
//  Tilt
//
//  Created by Eric Harmon on 10/31/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import "UIImageView+ImageSize.h"

@implementation UIImageView (ImageSize)

-(CGSize)imageSizeAfterAspectFit{
    
    
    float newwidth;
    float newheight;
    
    UIImage *image=self.image;
    
    if (image.size.height>=image.size.width){
        newheight=self.frame.size.height;
        newwidth=(image.size.width/image.size.height)*newheight;
        
        if(newwidth>self.frame.size.width){
            float diff=self.frame.size.width-newwidth;
            newheight=newheight+diff/newheight*newheight;
            newwidth=self.frame.size.width;
        }
        
    }
    else{
        newwidth=self.frame.size.width;
        newheight=(image.size.height/image.size.width)*newwidth;
        
        if(newheight>self.frame.size.height){
            float diff=self.frame.size.height-newheight;
            newwidth=newwidth+diff/newwidth*newwidth;
            newheight=self.frame.size.height;
        }
    }
    
    NSLog(@"image after aspect fit: width=%f height=%f",newwidth,newheight);
    
    
    //adapt UIImageView size to image size
    //imgview.frame=CGRectMake(imgview.frame.origin.x+(imgview.frame.size.width-newwidth)/2,imgview.frame.origin.y+(imgview.frame.size.height-newheight)/2,newwidth,newheight);
    
    return CGSizeMake(newwidth, newheight);
    
}

@end
