//
//  UITextView+Size.m
//  Webim.Ru
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "UITextView+Size.h"

static const CGFloat MarginAdjustment = 16.0;

@implementation UITextView (Size)

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font constratinWidth:(CGFloat)width {
    CGSize bounds = CGSizeMake(width - MarginAdjustment, CGFLOAT_MAX);
    
    CGRect frame = [text boundingRectWithSize:bounds
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName: font}
                                      context:nil];
    CGSize size = CGSizeMake(ceilf(frame.size.width), ceilf(frame.size.height));
    return CGSizeMake(MIN(size.width + MarginAdjustment, width),
                      size.height + MarginAdjustment);
}

@end
