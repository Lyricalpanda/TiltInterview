//
//  TrendingViewController.m
//  Tilt
//
//  Created by Eric Harmon on 10/30/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import "TrendingViewController.h"
#import "TiltNetworkManager.h"
#import "ImageCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

#include <stdlib.h>
#import "ImageResult.h"

@interface TrendingViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) IBOutlet UICollectionView *trendingView1;
@property (nonatomic, retain) IBOutlet UICollectionView *trendingView2;
@property (nonatomic, retain) IBOutlet UILabel *trendingLabel1;
@property (nonatomic, retain) IBOutlet UILabel *trendingLabel2;
@property (nonatomic, retain) NSTimer *viewTimer;

@property (nonatomic) int timerIndex;

@property (nonatomic, retain) NSMutableDictionary *trendingDict;

@end

@implementation TrendingViewController

- (void) onTick:(NSTimer *)timer
{
    if ([[self.trendingDict allKeys] count] > 0)
    {    [self.trendingView1 scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.timerIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self.trendingView2 scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.timerIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    self.timerIndex++;
    }
    
    if (self.timerIndex == 12)
    {
        [self.trendingView1 scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        [self.trendingView2 scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        self.timerIndex = 1;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timerIndex = 0;
    self.viewTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    self.trendingDict = [NSMutableDictionary new];
    
    [self.trendingView1 setTag:1];
    [self.trendingView2 setTag:2];
    [self initializeCollectionView:self.trendingView1];
    [self initializeCollectionView:self.trendingView2];
}

- (void) initializeCollectionView:(UICollectionView *)collectionView
{
    //Initialize FlowLayout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(collectionView.frame.size.height - 6, collectionView.frame.size.height - 6)];
    [layout setMinimumLineSpacing:10];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

    [collectionView setCollectionViewLayout:layout];
    collectionView.opaque = NO;
    collectionView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.trendingDict removeAllObjects];
    [self.trendingView1 reloadData];
    [self.trendingView2 reloadData];
    
    [TiltNetworkManager searchHotTrendsWithSuccessBlock:^(AFHTTPRequestOperation *task, id responseObject) {
        NSMutableArray *usaDict = [[(NSDictionary *)responseObject objectForKey:@"1"] mutableCopy];
        int count = (int)[usaDict count] - 1;
        int random = arc4random_uniform(count);
        [self searchGoogleImagesFor:[usaDict objectAtIndex:random] andCollectionView:self.trendingView1];
        [self.trendingLabel1 setText:[usaDict objectAtIndex:random]];
        [usaDict removeObjectAtIndex:random];
        count = (int)[usaDict count] - 1;
        random = arc4random_uniform(count);
        [self searchGoogleImagesFor:[usaDict objectAtIndex:random] andCollectionView:self.trendingView2];
        [self.trendingLabel2 setText:[usaDict objectAtIndex:random]];
        [self.viewTimer fire];
        
    } andFailureBlock:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];

}

- (void) searchGoogleImagesFor:(NSString *)query andCollectionView:(UICollectionView *)collectionView
{
    __block UICollectionView *bCollectionView = collectionView;
    [TiltNetworkManager searchImagesWithQuery:query atIndex:1 andSuccessBlock:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *imageArray;
        
        if ([self.trendingDict objectForKey:[NSString stringWithFormat:@"%ld", (long)bCollectionView.tag]])
            imageArray = [self.trendingDict objectForKey:[NSString stringWithFormat:@"%ld", (long)bCollectionView.tag]];
        else
            imageArray = [NSMutableArray new];
        
        NSArray *responseDict = [(NSDictionary *)responseObject objectForKey:@"items"];
        for (NSDictionary *imageDict in responseDict)
        {
            ImageResult *imgResult = [ImageResult new];
            imgResult.link = [imageDict objectForKey:@"link"];
            imgResult.thumbnailLink = [[imageDict objectForKey:@"image"] objectForKey:@"thumbnailLink"];
            [imageArray addObject:imgResult];
        }
        
        for (int i = 0; i < 4; i++)
        {
            [imageArray addObject:[imageArray objectAtIndex:i]];
        }
        
        [self.trendingDict setObject:imageArray forKey:[NSString stringWithFormat:@"%ld", (long)bCollectionView.tag]];
        [bCollectionView reloadData];
        
    } andFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Exceeded daily API usage for the day - try switching to the other API key!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];

        [alert show];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return [[self.trendingDict objectForKey:[NSString stringWithFormat:@"%ld", [view tag]]] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    NSArray *imageArray = [self.trendingDict objectForKey:[NSString stringWithFormat:@"%ld",cv.tag]];
    ImageResult *img = [imageArray objectAtIndex:indexPath.row];
    [cell.imageView setImageWithURL:[NSURL URLWithString:img.thumbnailLink] placeholderImage:nil];
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    return cell;
}


@end
