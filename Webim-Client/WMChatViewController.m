//
//  WMChatViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatViewController.h"

#import "UIBubbleTableView.h"
#import "SVPullToRefresh.h"

#import "WebimController.h"
#import "WMHistoryTableViewController.h"

#import "WMSession.h"
#import "WMChat.h"
#import "WMOperator.h"
#import "WMMessage.h"

typedef NS_ENUM(NSInteger, AlertIndex) {
    AlertIndexClosingChat,
    AlertIndexSendOffline,
};

@interface WMChatViewController () <UIAlertViewDelegate, WMChatDataSourceProtocol>

@end

@implementation WMChatViewController {
    BOOL                 sendingMessage_;
    BOOL                 didStartComposing_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onlineSessionFullUpdateNotification:) name:WebimNotifications.onlineFullUpdate object:nil];
    [nc addObserver:self selector:@selector(onlineSessionNewMessageNotification:) name:WebimNotifications.onlineNewMessage object:nil];
    [nc addObserver:self selector:@selector(onlineSessionOperatorUpdateNotification:) name:WebimNotifications.onlineOperatorUpdate object:nil];
    [nc addObserver:self selector:@selector(onlineSessionStartChatNotification:) name:WebimNotifications.onlineChatStart object:nil];
    [nc addObserver:self selector:@selector(onlineSessionChatStatusChangeNotification:) name:WebimNotifications.onlineChatStatusChange object:nil];
    [nc addObserver:self selector:@selector(onlineSessionStatusChangeNotification:) name:WebimNotifications.onlineSessionStatusChange object:nil];
    
    [self.clientMessageTextField addTarget:self action:@selector(textInputValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    WMSession *session = [WebimController shared].realtimeSession;
    [session startChat:^(BOOL successful) {
        [self reloadChat];
    }];
    
    // Update tableView's content size and add pull-to-refresh control
    if (self.bubbleTableView.contentSize.height < self.bubbleTableView.frame.size.height) {
        self.bubbleTableView.contentSize = self.bubbleTableView.frame.size;
    }
    __weak WMChatViewController *weakSelf = self;
    [self.bubbleTableView addPullToRefreshWithActionHandler:^{
        [[WebimController shared].realtimeSession refreshSessionWithCompletionBlock:^(BOOL successful) {
            [weakSelf.bubbleTableView.pullToRefreshView stopAnimating];
        }];
    } position:SVPullToRefreshPositionBottom];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self reloadBubbleTableView];
}

- (void)updateOperatorInfo {
    WMSession *session = [WebimController shared].realtimeSession;
    
    if (session.chat.chatOperator != nil) {
        NSString *avatarURL = [NSString stringWithFormat:@"%@/%@",
                               session.host,
                               session.chat.chatOperator.avatarPath];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarURL]];
        self.operatorImageView.image = [UIImage imageWithData:data];
        self.operatorNameLabel.text = session.chat.chatOperator.name;
        self.navigationItem.leftBarButtonItems =  @[self.operatorBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItems = nil;
    }
}

- (void)setMessageSendControlsEnabled:(BOOL)enabled {
    self.sendMessageButton.enabled = enabled;
    sendingMessage_ = !enabled;
}

- (WMChat *)chatDataSourceCurrentChat {
    return [WebimController shared].realtimeSession.chat;
}

- (void)chatDataSourceDownloadImageForMessage:(WMMessage *)message completion:(void (^)(BOOL, UIImage *, NSError *))block {
    [[WebimController shared].realtimeSession downloadImageForMessage:message completion:block];
}

- (void)reloadBubbleTableView {
    [super reloadBubbleTableView];
    
    WMSession *session = [WebimController shared].realtimeSession;
    if (session.chat.hasUnreadMessages) {
        [session markChatAsRead:nil];
    }
}

#pragma mark - User Actions

- (IBAction)sendMessageButtonAction:(id)sender {
    NSString *message = self.clientMessageTextField.text;
    if (message.length == 0) {
        return;
    }
    [self setMessageSendControlsEnabled:NO];
    [[WebimController shared].realtimeSession sendMessage:message completion:^(BOOL successful) {
        [self setMessageSendControlsEnabled:YES];
        if (successful) {
            self.clientMessageTextField.text = @"";
        }
    }];
}

- (IBAction)closeChatBarButtonAction:(id)sender {
    NSString *message = WMLocString(@"CloseChatConfirmationAlertMessage");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:WMLocString(@"DialogCancelButton")
                                          otherButtonTitles:WMLocString(@"DialogYesButton"), nil];
    alert.tag = AlertIndexClosingChat;
    [alert show];
}

- (IBAction)tapInTableViewGestureAction:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessageButtonAction:textField];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return !sendingMessage_;
}

- (void)showUnableToStartOnlineChatAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WMLocString(@"NoOnlineOperatorsAlertTitle")
                                                    message:WMLocString(@"NoOnlineOperatorsAlertMessage")
                                                   delegate:self
                                          cancelButtonTitle:WMLocString(@"NoOnlineOperatorsAlertCloseButtonTitle")
                                          otherButtonTitles:WMLocString(@"NoOnlineOperatorsAlertStartOfflineChatButtonTitle"), nil];
    alert.tag = AlertIndexSendOffline;
    [alert show];
}

- (IBAction)textInputValueChanged:(id)sender {
    if (!didStartComposing_) {
        didStartComposing_ = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelComposingState) object:nil];
        [[WebimController shared].realtimeSession setComposingMessage:YES completion:^(BOOL successful) {
            [self performSelector:@selector(cancelComposingState:) withObject:nil afterDelay:7];
        }];
    }
}

- (void)cancelComposingState:(id)sender {
    didStartComposing_ = NO;
    [[WebimController shared].realtimeSession setComposingMessage:NO completion:^(BOOL successful) {
    }];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertIndexClosingChat) {
        [self closeChatAlertView:alertView clickedButtonAtIndex:buttonIndex];
    } else if (alertView.tag == AlertIndexSendOffline) {
        [self goOfflineAlertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)closeChatAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self.view endEditing:YES];
        [[WebimController shared].realtimeSession closeChat:^(BOOL successful) {
            if (successful) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (void)goOfflineAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [WMHistoryTableViewController setReopenChatOnViewDidAppear];
    }
}

- (void)sendImage:(UIImage *)image {
    WMSession *session = [WebimController shared].realtimeSession;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
#if 1
    [session sendImage:imageData type:WMChatAttachmentImageJPEG completion:^(BOOL successful) {
        ;
    }];
#else
    // Optionaly file could be sent this way
    [session sendFile:imageData name:@"anyfile.jpg" mimeType:@"image/jpg" completion:nil];
#endif
}

- (void)reloadChat {
    [self reloadBubbleTableView];
    [self updateOperatorInfo];
}

#pragma mark - Online Session Notification Handlers

- (void)onlineSessionFullUpdateNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionNewMessageNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionOperatorUpdateNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionStartChatNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionChatStatusChangeNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionStatusChangeNotification:(NSNotification *)notification {
    if ([WebimController shared].realtimeSession.state == WMSessionStateOfflineMessage) {
        [self showUnableToStartOnlineChatAlert];
    }
}

@end
