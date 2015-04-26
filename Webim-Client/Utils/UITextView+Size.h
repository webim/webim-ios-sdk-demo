//
//  UITextView+Size.h
//  Webim.Ru
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Size)

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font constratinWidth:(CGFloat)width;

@end
