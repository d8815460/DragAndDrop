//
//  SDNViewController.m
//  DragAndDropDemo
//
//  Created by Son Ngo on 2/9/14.
//  Copyright (c) 2014 Son Ngo. All rights reserved.
//

#import "ViewController.h"
#import "CardView.h"
#import "SourceViewController.h"
#import "DestinationViewController.h"

@interface ViewController () <UIGestureRecognizerDelegate> {
  SourceViewController *_sourceViewController;
  SourceViewController *_destinationViewController;
  CardView *_draggedCard;
  MyModel *_model;
    IBOutlet UICollectionReusableView *header;
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *destinationCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *sourceCollectionView;

@end

#pragma mark -
@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _destinationViewController = [[SourceViewController alloc] initWithCollectionView:self.destinationCollectionView andParentViewController:self fromIndex:0];
    
  _sourceViewController = [[SourceViewController alloc] initWithCollectionView:self.sourceCollectionView andParentViewController:self fromIndex:1];
    
  
  
  [self initDraggedCardView];
  
  UIPanGestureRecognizer *panGesture =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
  panGesture.delegate = self;
  [self.view addGestureRecognizer:panGesture];
}

- (void)setSelectedModel:(MyModel *)model atPoint:(CGPoint)point fromValue:(int)value{
  _model = model;
  
  if (_model != nil) {
      _draggedCard.label.text = [NSString stringWithFormat:@"%d", model.value];
      _draggedCard.center = point;
      _draggedCard.hidden = NO;
      _draggedCard.locationValue = value;
      if (value == 0) {
          [self updateCardViewDragState:[self isValidDragPoint:point atSourceCollectionView:self.destinationCollectionView]];
      }else{
          [self updateCardViewDragState:[self isValidDragPoint:point atSourceCollectionView:self.sourceCollectionView]];
      }
      
  } else {
      _draggedCard.hidden = YES;
  }
}

#pragma mark - Validation helper methods on drag and drop
- (BOOL)isValidDragPoint:(CGPoint)point atSourceCollectionView:(UICollectionView *)collectionView
{
  return !CGRectContainsPoint(collectionView.frame, point);
}

- (void)updateCardViewDragState:(BOOL)validDropPoint {
  if (validDropPoint) {
    _draggedCard.alpha = 1.0f;
  } else {
    _draggedCard.alpha = 0.2f;
  }
}

#pragma mark - initialization code
//長按後，在self.view跟著手指跑
- (void)initDraggedCardView {
  _draggedCard = [[CardView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
  _draggedCard.hidden = YES;
  [_draggedCard setHighlightSelection:YES];
  
  [self.view addSubview:_draggedCard];
}

#pragma mark - Pan Gesture Recognizers/delegate
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
  CGPoint touchPoint = [gesture locationInView:self.view];
  if (gesture.state == UIGestureRecognizerStateChanged
             && !_draggedCard.hidden) {
    // card is dragged
    _draggedCard.center = touchPoint;
      if (_draggedCard.locationValue == 0) {
          [self updateCardViewDragState:[self isValidDragPoint:touchPoint atSourceCollectionView:self.destinationCollectionView]];
      } else {
          [self updateCardViewDragState:[self isValidDragPoint:touchPoint atSourceCollectionView:self.sourceCollectionView]];
      }
    
  } else if (gesture.state == UIGestureRecognizerStateRecognized
             && _model != nil) {
    _draggedCard.hidden = YES;
    
      BOOL validDropPoint;
      
      if (_draggedCard.locationValue == 0) {
          validDropPoint = [self isValidDragPoint:touchPoint atSourceCollectionView:self.destinationCollectionView];
      }else{
          validDropPoint = [self isValidDragPoint:touchPoint atSourceCollectionView:self.sourceCollectionView];
      }
      
      if (_draggedCard.locationValue == _sourceViewController.index) {
          [_sourceViewController cellDragCompleteWithModel:_model withValidDropPoint:validDropPoint fromIndex:_destinationViewController.index]; //完成拖曳要移除。
          if (validDropPoint) {
              [_destinationViewController addModel:_model];
          }
          
      }else{
          [_destinationViewController cellDragCompleteWithModel:_model withValidDropPoint:validDropPoint fromIndex:_sourceViewController.index]; //完成拖曳要移除。
          if (validDropPoint) {
              [_sourceViewController addModel:_model];
          }
      }
    _model = nil;
  }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

@end
