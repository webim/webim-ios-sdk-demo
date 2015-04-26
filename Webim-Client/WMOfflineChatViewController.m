//
//  WMOfflineChatViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMOfflineChatViewController.h"

#import "WebimController.h"

@interface WMOfflineChatViewController () <WMChatDataSourceProtocol>

@end

@implementation WMOfflineChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textInputPlaceholder.hidden = self.chat != nil && !self.chat.isOffline;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(webimNotificationsDidReceiveUpdateNotification:)
               name:WebimNotifications.didReceiveUpdate
             object:nil];

    [self reloadBubbleTableView];
    [self bubbleTableScrollToBottom];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadBubbleTableView {
    [super reloadBubbleTableView];
    if (self.chat.hasUnreadMessages) {
        [[WebimController shared].offlineSession markChatAsRead:self.chat completion:^(BOOL successful, NSError *error) {
            if (error != nil) {
                [WebimController processCommonErrorInResponse:error];
            }
        }];
    }
}

- (WMChat *)chatDataSourceCurrentChat {
    return self.chat;
}

- (void)chatDataSourceDownloadImageForMessage:(WMMessage *)message completion:(void (^)(BOOL, UIImage *, NSError *))block {
    [[WebimController shared].offlineSession downloadImageForMessage:message completion:block];
}

#pragma mark - User Actions

- (IBAction)sendMessageButtonAction:(id)sender {
    NSString *message = self.clientMessageTextField.text;
    if (message.length == 0) {
        return;
    }
    CGFloat bubbleMaxWidth = CGRectGetWidth(self.bubbleTableView.frame) - 20.f;
    
    NSBubbleData *bubbleDataItem = nil;
    bubbleDataItem = [NSBubbleData dataWithText:message
                                           date:[NSDate date]
                                           type:BubbleTypeMine
                                          width:bubbleMaxWidth];
    [self.messagesDataSource addObject:bubbleDataItem];
    [self.bubbleTableView reloadData];
    
    self.clientMessageTextField.text = nil;
    
    WMOfflineSession *session = [WebimController shared].offlineSession;
    [session sendMessage:message inChat:self.chat onDataBlock:^(BOOL successful, WMChat *chat, WMMessage *chatMessage, NSError *error) {
        if (successful) {
            self.chat = chat;
        } else {
            self.clientMessageTextField.text = message;
            [self tryToProcessSendMessageError:error];
        }
    } completion:^(BOOL successful) {
        [self reloadBubbleTableView];
        [self bubbleTableScrollToBottom];
    }];
}

- (IBAction)tapInTableViewGestureAction:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessageButtonAction:textField];
    return YES;
}

- (void)sendImage:(UIImage *)image {
    WMOfflineSession *session = [WebimController shared].offlineSession;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [session sendImage:imageData type:WMChatAttachmentImageJPEG inChat:self.chat onDataBlock:^(BOOL successful, WMChat *chat, WMMessage *message, NSError *error) {
        if (successful) {
            self.chat = chat;
            [WebimController shared].imagesMap[message.text] = image;
        } else {
            [self tryToProcessSendMessageError:error];
            NSLog(@"%@", error);
        }
    } completion:^(BOOL successful) {
        [self reloadBubbleTableView];
        [self bubbleTableScrollToBottom];
    }];
}

#pragma mark - Error handers

- (void)tryToProcessSendMessageError:(NSError *)error {
    if ([WebimController processCommonErrorInResponse:error]) {
        return;
    }
    if ([error.domain isEqualToString:WMWebimErrorDomain]) {
        NSString *alertMessage = nil;
        if (error.code == WMSessionErrorVisitorBanned) {
            alertMessage = WMLocString(@"WMSessionErrorVisitorBanned");
        } else if (error.code == WMSessionErrorAttachmentSizeExceeded) {
            alertMessage = WMLocString(@"WMSessionErrorAttachmentSizeExceeded");
        } else if (error.code == WMSessionErrorMessageSizeExceeded) {
            alertMessage = WMLocString(@"WMSessionErrorMessageSizeExceeded");
        }
        if (alertMessage.length > 0) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:alertMessage
                                       delegate:nil
                              cancelButtonTitle:WMLocString(@"DialogDismissButton")
                              otherButtonTitles:nil] show];
        }
    }
}

#pragma mark - History update notifications

- (void)webimNotificationsDidReceiveUpdateNotification:(NSNotification *)notification {
    if (self.chat == nil ||
            [notification.userInfo[WMOfflineChatChangesNewChatsKey] containsObject:self.chat] ||
            [notification.userInfo[WMOfflineChatChangesModifiedChatsKey] containsObject:self.chat]) {
        [self reloadBubbleTableView];
        [self bubbleTableScrollToBottom];
    }
}


@end
