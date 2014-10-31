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

@interface SavedViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) NSMutableArray *imagesArray;

@end

@implementation SavedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagesArray = [NSMutableArray new];
    [self.collectionView setCollectionViewLayout:[AFCoverFlowFlowLayout new]];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.imagesArray removeAllObjects];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *paths2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[path objectAtIndex:0] error:NULL];
    [paths2 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        if (![filename isEqualToString:@".DS_Store"])
            [self.imagesArray addObject:[[path objectAtIndex:0] stringByAppendingPathComponent:filename]];
    }];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.imagesArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    [cell.imageView setImage:[UIImage imageWithContentsOfFile:[self.imagesArray objectAtIndex:indexPath.row]]];
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        // Portrait is the same in either orientation
        return UIEdgeInsetsMake(0, 70, 0, 70);
    }
    else
    {
        // We need to get the height of the main screen to see if we're running
        // on a 4" screen. If so, we need extra side padding.
        if (CGRectGetHeight([[UIScreen mainScreen] bounds]) > 480)
        {
            return UIEdgeInsetsMake(0, 190, 0, 190);
        }
        else
        {
            return UIEdgeInsetsMake(0, 150, 0, 150);
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end