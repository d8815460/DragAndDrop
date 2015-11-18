//
//  SourceViewController.m
//  DragAndDropDemo
//
//  Created by Son Ngo on 2/10/14.
//  Copyright (c) 2014 Son Ngo. All rights reserved.
//

#import "SourceViewController.h"
#import "CardCell.h"
#import "CollectionReusableView.h"

@interface SourceViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
    UICollectionView *_collectionView;
    ViewController *_parentController;
    NSMutableArray *_models;
    MyModel *_selectedModel;
}
@end

#pragma mark -
@implementation SourceViewController
@synthesize index = _index;

- (instancetype)initWithCollectionView:(UICollectionView *)view andParentViewController:(ViewController *)parent fromIndex:(int)index{
  if (self = [super init]) {
      [self setUpModels];
      [self initCollectionView:view];
      [self setUpGestures];
      
      _parentController = parent;
      self.index = index;
  }
  return self;
}

- (void)addModel:(MyModel *)model {
    [_models addObject:model];
    
    [_collectionView reloadData];
}

- (void)cellDragCompleteWithModel:(MyModel *)model withValidDropPoint:(BOOL)validDropPoint fromIndex:(int)index{
  if (model != nil) {
    // get indexPath for the model
    NSUInteger index = [_models indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
      if (self.index == index) {
          //不作任何處理
      }else{
          if (validDropPoint && indexPath != nil) {
              [_models removeObjectAtIndex:index];
              [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
              
              [_collectionView reloadData];
          } else {
              
              UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
              cell.alpha = 1.0f;
          }
      }
  }
}

#pragma mark - Setup methods
- (void)setUpModels {
  _models = [NSMutableArray array];
  
  for (int i=0; i<10; i++) {
    [_models addObject:[[MyModel alloc] initWithValue:i]];
  }
}

- (void)initCollectionView:(UICollectionView *)view {
  _collectionView            = view;
  _collectionView.delegate   = self;
  _collectionView.dataSource = self;
  
  [_collectionView registerClass:[CardCell class] forCellWithReuseIdentifier:CELL_REUSE_ID];
}

- (void)setUpGestures {
  
  UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handlePress:)];
  longPressGesture.numberOfTouchesRequired = 1;
  longPressGesture.minimumPressDuration    = 0.1f;
  [_collectionView addGestureRecognizer:longPressGesture];
}

#pragma mark - Gesture Recognizer
- (void)handlePress:(UILongPressGestureRecognizer *)gesture {
  CGPoint point = [gesture locationInView:_collectionView];
 
  if (gesture.state == UIGestureRecognizerStateBegan) {
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    if (indexPath != nil) {
      _selectedModel = [_models objectAtIndex:indexPath.item];
      
      // calculate point in parent view
      point = [gesture locationInView:_parentController.view];
      
      [_parentController setSelectedModel:_selectedModel atPoint:point fromValue:self.index];
      
      // hide the cell
      [_collectionView cellForItemAtIndexPath:indexPath].alpha = 0.0f;
    }
  }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  CardCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_ID forIndexPath:indexPath];
  
  MyModel *model = [_models objectAtIndex:indexPath.item];
  [cell setModel:model];
  
  return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(60, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsMake(0, 5, 0, 5);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                   UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    [self updateSectionHeader:headerView forIndexPath:indexPath];
    
    NSLog(@"header = %@", headerView.label);
    return headerView;
}

- (void)updateSectionHeader:(CollectionReusableView *)header forIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [NSString stringWithFormat:@"header %li", (long)indexPath.row];
//    header.label.text = text;
}

@end
