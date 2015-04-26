//
//  NSBubbleData.m
//


#import "NSBubbleData.h"

#import "UITextView+Size.h"

#import <QuartzCore/QuartzCore.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@implementation NSBubbleData

#pragma mark - Properties

@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;

#pragma mark - Lifecycle

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_date release];
	_date = nil;
    [_view release];
    _view = nil;
    
    self.avatar = nil;

    [super dealloc];
}
#endif

#pragma mark - Text bubble

const UIEdgeInsets textInsetsMine =     {0, 10,  0, 10};
const UIEdgeInsets textInsetsSomeone =  {0, 10,  0, 10};
const UIEdgeInsets textInsetsFile =     {-2, 10, -2, 5};
const UIEdgeInsets textInsetsSystem =   {-2, 5,  -5, 3};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text date:date type:type];
#endif
}

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type width:(CGFloat)width {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text date:date type:type width:width] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text date:date type:type width:width];
#endif
}

- (UIFont *)fontForBubleType:(NSBubbleType)type {
    switch (type) {
        case BubbleTypeSystem: return [UIFont italicSystemFontOfSize:9];
        case BubleTypeFile: return [UIFont italicSystemFontOfSize:12];
        default: return [UIFont systemFontOfSize:15];
    }
}

- (UIColor *)colorForBubbleType:(NSBubbleType)type {
    switch (type) {
        case BubbleTypeMine: return [UIColor whiteColor];
        default: return [UIColor blackColor];
    }
}

- (UIEdgeInsets)insetsForBubbleType:(NSBubbleType)type {
    switch (type) {
        case BubbleTypeMine: return textInsetsMine;
        case BubbleTypeSomeoneElse: return textInsetsSomeone;
        case BubbleTypeSystem: return textInsetsSystem;
        case BubleTypeFile: return textInsetsFile;
        default: return UIEdgeInsetsZero;
    }
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type width:(CGFloat)width {
    self.text = text;
    
    UIFont *font = [self fontForBubleType:type];
    CGSize size = [UITextView sizeWithText:(text ? text : @"")
                                      font:font
                           constratinWidth:width];
    CGRect frame = CGRectMake(0, 0, MAX(size.width, 56), MAX(size.height, 35));
    if (type == BubbleTypeSystem) {
        frame = CGRectMake(0, 0, width, size.height);
    }
    
    UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    textView.text = text;
    textView.font = font;
    textView.textColor = [self colorForBubbleType:type];
    textView.editable = NO;
    textView.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
    textView.backgroundColor = [UIColor clearColor];
    if (type == BubbleTypeSystem || type == BubleTypeFile) {
        textView.textAlignment = NSTextAlignmentCenter;
    }
    textView.scrollEnabled = NO;
    
#if !__has_feature(objc_arc)
    [textView autorelease];
#endif
    
    self.alpha = 1;
    
    return [self initWithView:textView date:date type:type insets:[self insetsForBubbleType:type]];
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type {
    return [self initWithText:text date:date type:type width:IS_IPAD ? 680.f : 290.f];
}



#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {10, 10, 10, 10};
const UIEdgeInsets imageInsetsFile = {11, 18, 16, 14};
const UIEdgeInsets imageInsetsSomeone = {11, 18, 16, 14};
const UIEdgeInsets imageInsetsSystem = {10, 10, 16, 15};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image date:date type:type];
#endif
}


- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type {
    CGSize size = image.size;
    if (type == BubbleTypeSystem) {
        if (size.width > 300) {
            size.height /= (size.width / 300);
            size.width = 300;
        }
    }
    else {
        if (size.width > 220) {
            size.height /= (size.width / 220);
            size.width = 220;
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;


#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    self.usesImage = YES;
    self.alpha = 1;

    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : (type == BubbleTypeSomeoneElse ? imageInsetsSomeone : (type == BubleTypeFile ? imageInsetsFile : imageInsetsSystem)));

    return [self initWithView:imageView date:date type:type insets:insets];
}

#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date type:type insets:insets] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date type:type insets:insets];
#endif
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets {
    self = [super init];
    if (self) {
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
#else
        _view = view;
        _date = date;
#endif
        _type = type;
        _insets = insets;
    }
    return self;
}

@end
