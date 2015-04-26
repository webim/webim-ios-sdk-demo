//
//  UIBubbleTableViewDataSource.h
//


#import <Foundation/Foundation.h>

@class NSBubbleData;
@class UIBubbleTableView;

@protocol UIBubbleTableViewDataSource <NSObject>

@optional

@required

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView;

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row;
- (void)tableView:(UIBubbleTableView *)tableView accessoryButtonTappedForItem:(id)item;

@end
