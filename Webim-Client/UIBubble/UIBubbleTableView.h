//
//  UIBubbleTableView.h
//


#import <UIKit/UIKit.h>

#import "UIBubbleTableViewDataSource.h"
#import "UIBubbleTableViewCell.h"

typedef enum _NSBubbleTypingType {
    NSBubbleTypingTypeNobody = 0,
    NSBubbleTypingTypeMe = 1,
    NSBubbleTypingTypeSomebody = 2,
    NSBubbleTypingTypeSyStem = 3,
    NSBubbleTypingTypeFile = 4,
} NSBubbleTypingType;

@class NSBubbleData;

@interface UIBubbleTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, assign) IBOutlet id <UIBubbleTableViewDataSource> bubbleDataSource;
@property(nonatomic) NSTimeInterval snapInterval;
@property(nonatomic) NSBubbleTypingType typingBubble;
@property(nonatomic) BOOL showAvatars;

- (NSBubbleData *)bubbleTableViewBubbleAtIndexPath:(NSIndexPath *)indexPath;

@end
