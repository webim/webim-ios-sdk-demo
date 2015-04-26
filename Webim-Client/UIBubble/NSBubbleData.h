//
//  NSBubbleData.h

#import <Foundation/Foundation.h>

typedef enum _NSBubbleType {
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1,
    BubbleTypeSystem = 2,
    BubleTypeFile = 3

} NSBubbleType;

@interface NSBubbleData : NSObject


@property(readonly, nonatomic, strong) NSDate *date;
@property(nonatomic) NSBubbleType type;
@property(readonly, nonatomic, strong) UIView *view;
@property(readonly, nonatomic) UIEdgeInsets insets;
@property(nonatomic, strong) UIImage *avatar;
@property CGFloat screenWidth;
@property CGFloat screenHeight;
@property NSString *text;
@property (nonatomic, strong) NSDictionary *details;
@property NSString *typeContentFile;
@property NSString *recivedFileName;
@property float alpha;
@property (nonatomic, strong) id userData;
@property (nonatomic, assign) BOOL usesImage;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type width:(CGFloat)width;

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type width:(CGFloat)width;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;


@end
