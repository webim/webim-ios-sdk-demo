//
//  WMChatDataViewController.h
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatBaseViewController.h"

#import "WMMessage.h"
#import "WMChat.h"

@protocol WMChatDataSourceProtocol <NSObject>
@optional
- (WMChat *)chatDataSourceCurrentChat;
- (void)chatDataSourceDownloadImageForMessage:(WMMessage *)message completion:(void (^)(BOOL successful, UIImage *image, NSError *error))block;
@end

@interface WMChatDataViewController : WMChatBaseViewController

@property (strong, nonatomic) NSMutableArray *messagesDataSource;

- (NSBubbleType)bubbleTypeFromMessageKind:(WMMessageKind)kind;
- (void)bubbleTableScrollToBottom;
- (void)reloadBubbleTableView;

@end
