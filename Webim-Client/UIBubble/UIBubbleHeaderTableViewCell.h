#import <UIKit/UIKit.h>

@interface UIBubbleHeaderTableViewCell : UITableViewCell {
    CGFloat screenWidth;
    CGFloat screenHeight;
}

+ (CGFloat)height;

@property(nonatomic, strong) NSDate *date;

@end
