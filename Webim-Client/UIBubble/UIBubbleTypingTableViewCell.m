//
//  UIBubbleTypingTableCell.m
//  UIBubbleTableViewExample
//


#import "UIBubbleTypingTableViewCell.h"

@interface UIBubbleTypingTableViewCell ()

@property(nonatomic, retain) UIImageView *typingImageView;

@end

@implementation UIBubbleTypingTableViewCell

@synthesize type = _type;
@synthesize typingImageView = _typingImageView;
@synthesize showAvatar = _showAvatar;

+ (CGFloat)height {
    return 40.0;
}

- (void)setType:(NSBubbleTypingType)value {
    if (!self.typingImageView) {
        self.typingImageView = [[UIImageView alloc] init];
        [self addSubview:self.typingImageView];
    }

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    UIImage *bubbleImage = nil;
    CGFloat x = 0;

    if (value == NSBubbleTypingTypeMe) {
        bubbleImage = [UIImage imageNamed:@"typingMine.png"];
        x = self.frame.size.width - bubbleImage.size.width;
        self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
    }
    else if (value == BubbleTypeSomeoneElse) {
        bubbleImage = [UIImage imageNamed:@"typingSomeone.png"];
        x = 0;
        self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
    }
    else if (value == BubleTypeFile) {
        bubbleImage = [UIImage imageNamed:@"typingSomeone.png"];
        x = 0;
        self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
    }
    else if (value == BubbleTypeSystem) {
        bubbleImage = [UIImage imageNamed:@"System_Msg.png"];
        x = 10;
        self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
    }

    self.typingImageView.image = bubbleImage;
    // self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
}

@end
