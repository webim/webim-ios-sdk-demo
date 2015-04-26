//
//  WMChatDataViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatDataViewController.h"

#import "WebimController.h"

@interface WMChatDataViewController () <UIBubbleTableViewDataSource, UITableViewDelegate, WMChatDataSourceProtocol>

@end

@implementation WMChatDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bubbleTableView.delegate = self.bubbleTableView;
    self.bubbleTableView.snapInterval = 60;
    self.bubbleTableView.showAvatars = NO;
    self.bubbleTableView.bubbleDataSource = self;
}

- (NSBubbleType)bubbleTypeFromMessageKind:(WMMessageKind)kind {
    switch (kind) {
        case WMMessageKindOperator: return BubbleTypeSomeoneElse;
        case WMMessageKindVisitor: return BubbleTypeMine;
        case WMMessageKindFileFromOperator: return BubbleTypeSomeoneElse;
        case WMMessageKindFileFromVisitor: return BubbleTypeMine;
        default: return BubbleTypeSystem;
    }
}

- (void)bubbleTableScrollToBottom {
    NSInteger sec = [self.bubbleTableView numberOfSections] - 1;
    if (sec < 0) {
        return;
    }
    NSInteger row = [self.bubbleTableView numberOfRowsInSection:sec] - 1;
    [self.bubbleTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:sec]
                                atScrollPosition:UITableViewScrollPositionNone
                                        animated:NO];
}

- (void)reloadBubbleTableView {
    if (![self respondsToSelector:@selector(chatDataSourceCurrentChat)]) {
        return;
    }
    WMChat *chat = [self chatDataSourceCurrentChat];
    NSMutableArray *newBubbleData = [NSMutableArray new];
    CGFloat bubbleMaxWidth = CGRectGetWidth(self.bubbleTableView.frame) - 20.f;
    
    NSBubbleData *bubbleDataItem = nil;
    for (WMMessage *message in chat.messages) {
        NSBubbleType type = [self bubbleTypeFromMessageKind:message.kind];
        if (message.kind == WMMessageKindFileFromVisitor || message.kind == WMMessageKindFileFromOperator) {
            UIImage *image = [[WebimController shared].imagesMap objectForKey:message.text];
            if (image != nil) {
                bubbleDataItem = [NSBubbleData dataWithImage:image date:message.timestamp type:type];
            } else {
                bubbleDataItem = [NSBubbleData dataWithText:WMLocString(@"BubbleLoadingImageMessage")
                                                       date:message.timestamp
                                                       type:type
                                                      width:bubbleMaxWidth];
            }
        } else {
            bubbleDataItem = [NSBubbleData dataWithText:message.text
                                                   date:message.timestamp
                                                   type:type
                                                  width:bubbleMaxWidth];
        }
        [newBubbleData addObject:bubbleDataItem];
    }
    self.messagesDataSource = newBubbleData;
    [self.bubbleTableView reloadData];
    [self bubbleTableScrollToBottom];
    
    if (![self respondsToSelector:@selector(chatDataSourceDownloadImageForMessage:completion:)]) {
        return;
    }
    for (WMMessage *message in chat.messages) {
        if ((message.kind == WMMessageKindFileFromVisitor || message.kind == WMMessageKindFileFromOperator) &&
            [[WebimController shared].imagesMap objectForKey:message.text] == nil) {
            
            [self chatDataSourceDownloadImageForMessage:message completion:^(BOOL successful, UIImage *image, NSError *error) {
                if (successful) {
                    [WebimController shared].imagesMap[message.text] = image;
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedTableUpdate) object:nil];
                    [self performSelector:@selector(delayedTableUpdate) withObject:nil afterDelay:0.3];
                } else {
                    NSLog(@"%@", error);
                }
            }];
        }
    }
}

- (void)delayedTableUpdate {
    [self reloadBubbleTableView];
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView {
    return [self.messagesDataSource count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row {
    return [self.messagesDataSource objectAtIndex:row];
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.bubbleTableView tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UIBubbleTableView *)tableView accessoryButtonTappedForItem:(id)item {
    WMMessage *message = item;
    NSString *fileURL = [NSString stringWithFormat:@"%@/%@",
                         [WebimController shared].realtimeSession.host,
                         [message.filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fileURL]];
}

@end
