//
//  ViewController.m
//  Tilt
//
//  Created by Eric Harmon on 10/26/14.
//  Copyright (c) 2014 Eric Harmon. All rights reserved.
//

#import "ViewController.h"

#import "TiltNetworkManager.h"
#import "ImageResult.h"

#import "ImageCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+ImageSize.h"

#define BLUR_VIEW_TAG 1
#define CLOSE_BUTTON_TAG 2
#define LEFT_BUTTON_TAG 3
#define RIGHT_BUTTON_TAG 4
#define IMAGEVIEW_TAG 5
#define GREYVIEW_TAG 6
#define SAVE_BUTTON_TAG 7

@interface ViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic) int cellWidth;
@property (nonatomic) int cellHeight;

@property (nonatomic, retain) NSDictionary *returnJSON;
@property (nonatomic, retain) NSMutableArray *imageResults;
@property (nonatomic, retain) UIVisualEffectView *blurEffectView;
@property (nonatomic, retain) UIImageView *bigImageView;
@property (nonatomic, retain) UIView *blurView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) UITapGestureRecognizer *tap;
@property (nonatomic, retain) UIView *greyView;
@property (nonatomic, retain) NSString *query;
@property (nonatomic) int paginationIndex;
@property (nonatomic) int selectedIndex;
@property (nonatomic) BOOL isSearching;

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;


@end

@implementation ViewController

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.view addSubview:self.greyView];
}

- (void) hideKeyboard
{
    [[self.view viewWithTag:GREYVIEW_TAG] removeFromSuperview];
    [self.searchBar resignFirstResponder];
    [self.greyView removeFromSuperview];
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
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    [self.imageResults removeAllObjects];
    [self.collectionView reloadData];
    [self hideKeyboard];
    [searchBar resignFirstResponder];
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
        
        self.paginationIndex = [[nextPageDict objectForKey:@"startIndex"] integerValue];
        [self.collectionView reloadData];
        
    } andFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        self.isSearching = NO;
        
    }];
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
    
    self.blurView = [[UIView alloc] initWithFrame:self.view.frame];
    
    self.greyView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];;
    self.greyView.frame = self.collectionView.frame;
    [self.greyView setTag:GREYVIEW_TAG];

    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];

    [self.greyView addGestureRecognizer:self.tap];
    
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.blurEffectView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height);
    
    UIButton *closeBlurButton = [[UIButton alloc] initWithFrame:CGRectMake(self.blurEffectView.frame.size.width - 46, self.blurEffectView.frame.origin.y + 30, 36, 36)];
    [closeBlurButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBlurButton addTarget:self action:@selector(closeBlurEffectView:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, closeBlurButton.frame.size.height + closeBlurButton.frame.origin.y + 20, self.blurView.frame.size.width - 20 ,leftBlurButton.frame.origin.y - self.bigImageView.frame.origin.y - 20)];
    [self.bigImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.bigImageView setTag:IMAGEVIEW_TAG];
    
    [self.blurEffectView addSubview:closeBlurButton];
    [self.blurEffectView addSubview:leftBlurButton];
    [self.blurEffectView addSubview:rightBlurButton];
    [self.blurEffectView addSubview:saveButton];
    [self.blurEffectView addSubview:self.bigImageView];
    [self.blurView setTag:BLUR_VIEW_TAG];
}

- (void) saveImage:(id)sender
{
    UIImageView *imgView = (UIImageView *)[self getBlurSubviewWithTag:IMAGEVIEW_TAG];
    ImageResult *curImage = [self.imageResults objectAtIndex:self.selectedIndex];
    // Create path.
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [[NSString stringWithFormat:@"%f-",timeStamp] stringByAppendingString:[[curImage.link componentsSeparatedByString:@"/"] lastObject]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    
    [UIImagePNGRepresentation(imgView.image) writeToFile:filePath atomically:YES];
}

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

- (void)closeBlurEffectView:(id)sender
{
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        UIView *blurView = [self.view viewWithTag:1];
        
        int height = self.view.frame.size.height;
        int width = self.view.frame.size.width;
        
        blurView.frame = CGRectMake(0, height/2 - 50, width, 100);

    } completion:^(BOOL finished) {
        UIView *blurView = [self.view viewWithTag:1];
        [blurView removeFromSuperview];
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
    NSLog(NSStringFromCGRect(self.view.frame));
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    self.isSearching = NO;
    self.imageResults = [NSMutableArray new];
    self.paginationIndex = 1;
    self.selectedIndex = 0;
    self.isSearching = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [cell setBackgroundColor:[UIColor orangeColor]];
     return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = (int)indexPath.row;
    self.blurView.clipsToBounds = YES;
    [self.blurView addSubview:self.blurEffectView];
    [self.view addSubview:self.blurView];

    int height = self.view.frame.size.height;
    int width = self.view.frame.size.width;
    
    [self setBigPictureForIndex:(int)indexPath.row];
    self.blurView.frame = CGRectMake(0, height/2 - 50, width, 100);

    [UIView animateWithDuration:1.0 delay:0.1 usingSpringWithDamping:1.0 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.blurView.frame = self.view.frame;
    } completion:^(BOOL finished) {
    
    }];
}

- (void) setBigPictureForIndex:(int)index
{
    UIView *blurView = [self.view viewWithTag:1];
    UIImageView *imgView = (UIImageView *)[blurView viewWithTag:5];

    ImageResult *img = [self.imageResults objectAtIndex:index];
    [imgView setImageWithURL:[NSURL URLWithString:img.link] placeholderImage:[UIImage imageNamed:@"loading"]];
}

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
