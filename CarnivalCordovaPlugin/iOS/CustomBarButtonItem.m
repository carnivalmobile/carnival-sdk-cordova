//
//  CPBarButtonItem.m
//  Carnival
//
//  Created by Blair McArthur on 8/08/14.
//  Copyright (c) 2014 Carnival Labs . All rights reserved.
//

#import "CustomBarButtonItem.h"

@implementation CustomBarButtonItem {}

#pragma mark - convenience init

+ (instancetype)closeButtonForTarget:(id)target action:(SEL)action {
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    [closeButton setImage:[self blackCloseButtonImage] forState:UIControlStateNormal];
    [closeButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[CustomBarButtonItem alloc] initWithCustomView:closeButton];
}

#pragma mark - overriden getters/setters

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    [self.customView setTintColor:tintColor];
}

#pragma mark - helpers

+ (UIImage *)blackCloseButtonImage {
    return [[UIImage imageNamed:@"cp_close_button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - image insets

+ (UIEdgeInsets)closeButtonImageEdgeInsets {
    return UIEdgeInsetsMake(11.0f, 30.0f, 11.0f, -8.0f);
}

@end
