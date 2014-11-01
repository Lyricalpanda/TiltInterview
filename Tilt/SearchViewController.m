//
//  ViewController.m
//  Tilt
//
//  Created by Eric Harmon on 10/26/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import "SearchViewController.h"

#import "TiltNetworkManager.h"
#import "ImageResult.h"

#import "ImageCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

#define BLUR_VIEW_TAG 1
#define CLOSE_BUTTON_TAG 2
#define LEFT_BUTTON_TAG 3
#define RIGHT_BUTTON_TAG 4
#define IMAGE_VIEW_TAG 5
#define GREY_VIEW_TAG 6
#define SAVE_BUTTON_TAG 7

@interface SearchViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@property (nonatomic, retain) UIView *fullImageView;
@property (nonatomic, retain) UIView *queryBlurView;
@property (nonatomic, retain) UIVisualEffectView *blurEffectView;
@property (nonatomic, retain) UIImageView *bigImageView;

@property (nonatomic, retain) UITapGestureRecognizer *tap;

@property (nonatomic, retain) NSDictionary *returnJSON;
@property (nonatomic, retain) NSMutableArray *imageResults;
@property (nonatomic, retain) NSString *query;

@property (nonatomic) int paginationIndex;
@property (nonatomic) int selectedIndex;
@property (nonatomic) BOOL isSearching;

@property (nonatomic) int cellWidth;
@property (nonatomic) int cellHeight;

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;


@end

@implementation SearchViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.view.frame.size.width > 320)
    {
        self.cellHeight = 170;
        self.cellWidth = 170;
    }
    else
    {
        self.cellHeight = 140;
        self.cellWidth = 140;
    }
    
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    self.isSearching = NO;
    self.imageResults = [NSMutableArray new];
    self.paginationIndex = 1;
    self.selectedIndex = 0;
    self.isSearching = YES;
}

- (void) viewDidLayoutSubviews
{
    //Initialize FlowLayout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(self.cellWidth, self.cellHeight)];
    [layout setMinimumLineSpacing:10];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    //Initialize collectionView
    [self.collectionView setCollectionViewLayout:layout];
    self.collectionView.opaque = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.fullImageView = [[UIView alloc] initWithFrame:self.view.frame];
    
    self.queryBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];;
    self.queryBlurView.frame = self.collectionView.frame;
    [self.queryBlurView setTag:GREY_VIEW_TAG];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    [self.queryBlurView addGestureRecognizer:self.tap];
    
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.blurEffectView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height);
    
    UIButton *closeBlurButton = [[UIButton alloc] initWithFrame:CGRectMake(self.blurEffectView.frame.size.width - 46, self.blurEffectView.frame.origin.y + 30, 36, 36)];
    [closeBlurButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBlurButton addTarget:self action:@selector(closeFullView:) forControlEvents:UIControlEventTouchUpInside];
    [closeBlurButton setTag:CLOSE_BUTTON_TAG];
    
    UIButton *leftBlurButton = [[UIButton alloc] initWithFrame:CGRectMake(25, self.blurEffectView.frame.size.height - 40, 36, 36)];
    [leftBlurButton setBackgroundImage:[UIImage imageNamed:@"arrow-left"] forState:UIControlStateNormal];
    [leftBlurButton addTarget:self action:@selector(leftArrow:) forControlEvents:UIControlEventTouchUpInside];
    [leftBlurButton setTag:LEFT_BUTTON_TAG];
    
    UIButton *rightBlurButton = [[UIButton alloc] initWithFrame:CGRectMake(self.blurEffectView.frame.size.width - 45, self.blurEffectView.frame.size.height - 40, 36, 36)];
    [rightBlurButton setBackgroundImage:[UIImage imageNamed:@"arrow-right"] forState:UIControlStateNormal];
    [rightBlurButton addTarget:self action:@selector(rightArrow:) forControlEvents:UIControlEventTouchUpInside];
    [rightBlurButton setTag:RIGHT_BUTTON_TAG];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake((rightBlurButton.frame.origin.x - (leftBlurButton.frame.origin.x + leftBlurButton.frame.size.width))/2 - 30 + leftBlurButton.frame.origin.x + leftBlurButton.frame.size.width, leftBlurButton.frame.origin.y, 60, 36)];
    [saveButton addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTag:SAVE_BUTTON_TAG];
    [saveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:26.0]];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    
    self.bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, closeBlurButton.frame.size.height + closeBlurButton.frame.origin.y + 20, self.fullImageView.frame.size.width - 20 ,leftBlurButton.frame.origin.y - self.bigImageView.frame.origin.y - 20)];
    [self.bigImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.bigImageView setTag:IMAGE_VIEW_TAG];
    
    [self.blurEffectView addSubview:closeBlurButton];
    [self.blurEffectView addSubview:leftBlurButton];
    [self.blurEffectView addSubview:rightBlurButton];
    [self.blurEffectView addSubview:saveButton];
    [self.blurEffectView addSubview:self.bigImageView];
    
    [self.fullImageView setTag:BLUR_VIEW_TAG];
}

#pragma mark - Searchbar delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.view addSubview:self.queryBlurView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideKeyboard];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.query = searchBar.text;
    [self searchGoogleImagesFor:self.query];
    if ([self.imageResults count] > 0)
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    [self.imageResults removeAllObjects];
    [self.collectionView reloadData];
    [self hideKeyboard];
    [searchBar resignFirstResponder];
}

- (void) hideKeyboard
{
    [[self.view viewWithTag:GREY_VIEW_TAG] removeFromSuperview];
    [self.searchBar resignFirstResponder];
    [self.queryBlurView removeFromSuperview];
}

- (void) searchGoogleImagesFor:(NSString *)query
{
    self.isSearching = YES;
    [TiltNetworkManager searchImagesWithQuery:query atIndex:self.paginationIndex andSuccessBlock:^(NSURLSessionDataTask *task, id responseObject) {
        self.isSearching = NO;
        
        NSArray *responseDict = [(NSDictionary *)responseObject objectForKey:@"items"];
        for (NSDictionary *imageDict in responseDict)
        {
            ImageResult *imgResult = [ImageResult new];
            imgResult.link = [imageDict objectForKey:@"link"];
            imgResult.thumbnailLink = [[imageDict objectForKey:@"image"] objectForKey:@"thumbnailLink"];
            imgResult.thumbnailHeight = [[[imageDict objectForKey:@"image"] objectForKey:@"thumbnailHeight"] intValue];
            imgResult.thumbnailWidth = [[[imageDict objectForKey:@"image"] objectForKey:@"thumbnailWidth"] intValue];
            [self.imageResults addObject:imgResult];
        }
        NSDictionary *nextPageDict = [[[(NSDictionary *)responseObject objectForKey:@"queries"] objectForKey:@"nextPage"] objectAtIndex:0];
        
        self.paginationIndex = (int)[[nextPageDict objectForKey:@"startIndex"] integerValue];
        [self.collectionView reloadData];
        
    } andFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        self.isSearching = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Exceeded daily API usage for the day - try switching to the other API key!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

#pragma mark - fullScreenView methods

// This method will save the image down into the phone so the user can view it in the Saved tab in a coverflow manner. It grabs the timestamp and puts it as the filename so to make sure there are no collisions between images that have the same filename (i.e. image.jpg)

- (void) saveImage:(id)sender
{
    UIImageView *imgView = (UIImageView *)[self getBlurSubviewWithTag:IMAGE_VIEW_TAG];
    ImageResult *curImage = [self.imageResults objectAtIndex:self.selectedIndex];
    // Create path.
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [[NSString stringWithFormat:@"%f-",timeStamp] stringByAppendingString:[[curImage.link componentsSeparatedByString:@"/"] lastObject]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    [UIImagePNGRepresentation(imgView.image) writeToFile:filePath atomically:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved Image!" message:@"Image has been saved - click on the Saved tab in the tab bar to see your saved images!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (void)closeFullView:(id)sender
{
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        UIView *fullView = [self.view viewWithTag:1];
        
        int height = self.view.frame.size.height;
        int width = self.view.frame.size.width;
        
        fullView.frame = CGRectMake(0, height/2 - 50, width, 100);

    } completion:^(BOOL finished) {
        UIView *fullView = [self.view viewWithTag:1];
        [fullView removeFromSuperview];
    }];
}

- (UIView *) getBlurSubviewWithTag:(int)tag
{
    UIView *blurView = [self.view viewWithTag:1];
    return [blurView viewWithTag:tag];
}

- (void)leftArrow:(id)sender
{
    self.selectedIndex--;
    if (self.selectedIndex == 0)
    {
        [[self getBlurSubviewWithTag:LEFT_BUTTON_TAG] setHidden:YES];
    }
    else if (self.selectedIndex == [self.imageResults count] - 2)
    {
        [[self getBlurSubviewWithTag:RIGHT_BUTTON_TAG] setHidden:NO];
    }
    
    [self setBigPictureForIndex:self.selectedIndex];
}

- (void)rightArrow:(id)sender
{
    self.selectedIndex++;
    if (self.selectedIndex == [self.imageResults count] - 1)
    {
        [[self getBlurSubviewWithTag:RIGHT_BUTTON_TAG] setHidden:YES];
    }
    else if (self.selectedIndex == 1)
    {
        [[self getBlurSubviewWithTag:LEFT_BUTTON_TAG] setHidden:NO];
    }

    [self setBigPictureForIndex:self.selectedIndex];
}

- (void) setBigPictureForIndex:(int)index
{
    UIView *blurView = [self.view viewWithTag:1];
    UIImageView *imgView = (UIImageView *)[blurView viewWithTag:5];
    
    ImageResult *img = [self.imageResults objectAtIndex:index];
    [imgView setImageWithURL:[NSURL URLWithString:img.link] placeholderImage:[UIImage imageNamed:@"loading"]];
}

#pragma mark - CollectionView delegate methods

//Try to resize the cell based on the ratio in case we can collapse cells a little further into 3 per row. However, due to the API only allowing 10 results per call, this wouldn't work very well with the pagination feature. We would need to do 2-3 calls if we tried to make it 3 cells per row, since the cells would have to be smaller. This would result in the cells only taking 1/3 - 1/2 the screen with only 10 image results.

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ImageResult *imgResult = [self.imageResults objectAtIndex:indexPath.row];
    float ratio;
    if (imgResult.thumbnailHeight < imgResult.thumbnailWidth)
        ratio = (float)self.cellWidth / imgResult.thumbnailWidth;
    else
        ratio = (float)self.cellHeight / imgResult.thumbnailHeight;
    
    return CGSizeMake(imgResult.thumbnailWidth * ratio, imgResult.thumbnailHeight * ratio);
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.imageResults count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    ImageResult *img = [self.imageResults objectAtIndex:indexPath.row];
    [cell.imageView setImageWithURL:[NSURL URLWithString:img.thumbnailLink]];
     return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = (int)indexPath.row;
    self.fullImageView.clipsToBounds = YES;
    [self.fullImageView addSubview:self.blurEffectView];
    [self.view addSubview:self.fullImageView];

    int height = self.view.frame.size.height;
    int width = self.view.frame.size.width;
    
    //Do quick sanity check to disable left/right arrow if we select first/last element
    if (self.selectedIndex == 0)
    {
        [[self getBlurSubviewWithTag:LEFT_BUTTON_TAG] setHidden:YES];
    }
    else if (self.selectedIndex == [self.imageResults count] - 2)
    {
        [[self getBlurSubviewWithTag:RIGHT_BUTTON_TAG] setHidden:YES];
    }

    [self setBigPictureForIndex:(int)indexPath.row];
    self.fullImageView.frame = CGRectMake(0, height/2 - 50, width, 100);

    [UIView animateWithDuration:1.0 delay:0.1 usingSpringWithDamping:1.0 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.fullImageView.frame = self.view.frame;
    } completion:^(BOOL finished) {
    
    }];
}

#pragma mark - Scrollview delegate methods

// This method detects when we should make a call out to grab the next page of results, based on where we are in the scrollview

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    
    float reload_distance = -80;
    if(y > h + reload_distance && !self.isSearching) {
        [self searchGoogleImagesFor:self.query];
    }
}

@end
