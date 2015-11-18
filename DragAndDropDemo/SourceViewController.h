//
//  SourceViewController.h
//  DragAndDropDemo
//
//  Created by Son Ngo on 2/10/14.
//  Copyright (c) 2014 Son Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "MyModel.h"

@interface SourceViewController : NSObject

@property (nonatomic, assign) int index;

- (instancetype)initWithCollectionView:(UICollectionView *)view
               andParentViewController:(ViewController *)parent fromIndex:(int)index;

- (void)cellDragCompleteWithModel:(MyModel *)model
               withValidDropPoint:(BOOL)validDropPoint fromIndex:(int)index;

- (void)addModel:(MyModel *)model;

@end
