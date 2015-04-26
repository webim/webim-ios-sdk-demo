//
//  UIBubbleTableViewCell.m
//


#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"

UIImage *bubbleSomeoneImage;
UIImage *bubbleMineImage;
UIImage *SystemMsgImage;
UIImage *bubbleMsgFileImage;

@interface UIBubbleTableViewCell ()

@property(nonatomic, retain) UIView *customView;
@property(nonatomic, retain) UIImageView *bubbleImage;
@property(nonatomic, retain) UIImageView *avatarImage;

- (void)setupInternalData;

@end

@implementation UIBubbleTableViewCell


@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value {
    self.data = value;
    [self setupInternalData];
}

- (void)setupInternalData {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    if (!self.bubbleImage) {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];
#endif
        [self addSubview:self.bubbleImage];
    }

    NSBubbleType type = self.data.type;

    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse ? 0 : (type == BubbleTypeSystem ? 0 : (type == BubleTypeFile ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right)));
    CGFloat y = 0;

    // Adjusting the x coordinate for avatar
    if (self.showAvatar) {
        [self.avatarImage removeFromSuperview];
#if !__has_feature(objc_arc)
        self.avatarImage = [[[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])] autorelease];
#else
        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
#endif
        self.avatarImage.layer.cornerRadius = 9.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;

        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
        CGFloat avatarY = self.frame.size.height - 50;

        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50);
        [self addSubview:self.avatarImage];

        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta;

        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
        if (type == BubbleTypeSystem) x -= 54;
        if (type == BubleTypeFile) x += 54;
    }

    [self.customView removeFromSuperview];
    self.customView = self.data.view;
 
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    [self.contentView addSubview:self.customView];

    [self.bubbleImage.layer removeAllAnimations];
    if (type == BubbleTypeSomeoneElse) {
        if (bubbleSomeoneImage == nil) {
            bubbleSomeoneImage = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        }
        self.bubbleImage.image = bubbleSomeoneImage;
    } else if (type == BubleTypeFile) {
        if (bubbleMsgFileImage == nil) {
            bubbleMsgFileImage = [[UIImage imageNamed:@"bubbleFile.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        }
        self.bubbleImage.image = bubbleMsgFileImage;
    } else if (type == BubbleTypeMine) {
        if (bubbleMineImage == nil) {
            bubbleMineImage = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
        }
        self.bubbleImage.image = bubbleMineImage;
    } else if (type == BubbleTypeSystem) {
        if (SystemMsgImage == nil) {
            SystemMsgImage = [[UIImage imageNamed:@"System_Msg.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
        }
        self.bubbleImage.image = SystemMsgImage;
        x += self.data.insets.left;
    }

    self.bubbleImage.frame = CGRectMake(x,
                                        y - self.data.insets.top,
                                        width + self.data.insets.left + self.data.insets.right,
                                        height + self.data.insets.top + self.data.insets.bottom);
    self.alpha = self.data.alpha;
    self.bubbleImage.hidden = self.data.usesImage;
}

@end
