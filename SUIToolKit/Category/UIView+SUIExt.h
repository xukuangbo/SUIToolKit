//
//  UIView+SUIExt.h
//  SUIToolKitDemo
//
//  Created by zzZ on 15/6/26.
//  Copyright (c) 2015年 SUIO~. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SUIExt)



#pragma mark - IB

@property (nonatomic,assign) IBInspectable CGFloat cornerRadius;



#pragma mark - Frame

@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;



#pragma mark -

- (UIViewController *)currVC;

- (NSLayoutConstraint *)contantTop;
- (NSLayoutConstraint *)contantBottom;

- (NSLayoutConstraint *)contantHeight;



- (UIImage *)snapshot;

- (id)subviewWithClassName:(NSString *)className;


- (void)setBorder:(UIColor *)color width:(CGFloat)width;
- (void)setShadow:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset blurRadius:(CGFloat)blurRadius;

@end
