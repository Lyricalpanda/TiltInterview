//
//  SavedViewController.m
//  Tilt
//
//  Created by Eric Harmon on 10/31/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import "SavedViewController.h"
#import "AFCoverFlowFlowLayout.h"

#import "ImageResult.h"
#import "ImageCollectionViewCell.h"

/*
 This uses Ash Furrow's UICollectionView coverflow sample. This is used to show UI/UX thinking instead of ability to come up with my own custom coverflow!
 */

@interface SavedViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) NSMutableArray *imagesArray;

@end

@implementation SavedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagesArray = [NSMutableArray new];
    [self.collectionView setCollectionViewLayout:[AFCoverFlowFlowLayout new]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.imagesArray removeAllObjects];
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *documentsDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[filePath objectAtIndex:0] error:NULL];
    [documentsDirectory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        if (![filename isEqualToString:@".DS_Store"])
            [self.imagesArray addObject:[[filePath objectAtIndex:0] stringByAppendingPathComponent:filename]];
    }];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView delegate methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.imagesArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    [cell.imageView setImage:[UIImage imageWithContentsOfFile:[self.imagesArray objectAtIndex:indexPath.row]]];
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 70, 0, 70);
}

@end