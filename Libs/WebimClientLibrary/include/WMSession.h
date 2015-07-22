//
//  WMSession.h
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMBaseSession.h"

@protocol WMSessionDelegate;
@class WMChat;
@class WMVisitor;
@class WMMessage;
@class WMOperator;

typedef enum {
    WMSessionStateUnknown,
    WMSessionStateIdle,
    WMSessionStateIdleAfterChat,
    WMSessionStateChat,
    WMSessionStateOfflineMessage,
} WMSessionState;

typedef enum {
    WMSessionConnectionStatusUnknown,
    WMSessionConnectionStatusOnline,
    WMSessionConnectionStatusOffline,
} WMSessionConnectionStatus;

// Optional keys for visitorData dictionary
extern NSString *const WMVisitorParameterDisplayName;
extern NSString *const WMVisitorParameterPhone;
extern NSString *const WMVisitorParameterEmail;
extern NSString *const WMVisitorParameterICQ;
extern NSString *const WMVisitorParameterProfileURL;
extern NSString *const WMVisitorParameterAvatarURL;
extern NSString *const WMVisitorParameterID;
extern NSString *const WMVisitorParameterLogin;
extern NSString *const WMVisitorParameterCRC; // Required, see http://webim.ru/help/identification/

typedef void (^WMResponseCompletionBlock)(BOOL successful);

@interface WMSession : WMBaseSession

@property (nonatomic, weak) id <WMSessionDelegate> delegate;
@property (nonatomic, readonly, assign) WMSessionState state;
@property (nonatomic, readonly, assign) BOOL hasOnlineOperator;
@property (nonatomic, strong) WMChat *chat;
@property (nonatomic, strong) WMVisitor *visitor;

@property (nonatomic, readonly) WMSessionConnectionStatus connectionStatus;

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location delegate:(id<WMSessionDelegate>)delegate;
- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location delegate:(id<WMSessionDelegate>)delegate visitorFields:(NSDictionary *)visitorFields;

- (void)startSession:(WMResponseCompletionBlock)block;
- (void)refreshSessionWithCompletionBlock:(WMResponseCompletionBlock)block;

- (void)startChat:(WMResponseCompletionBlock)block;
- (void)closeChat:(WMResponseCompletionBlock)block;
- (void)markChatAsRead:(WMResponseCompletionBlock)block;

- (void)sendMessage:(NSString *)message completion:(WMResponseCompletionBlock)block;
- (void)sendImage:(NSData *)imageData type:(WMChatAttachmentImageType)type completion:(WMResponseCompletionBlock)block;
- (void)downloadImageForMessage:(WMMessage *)message completion:(void (^)(BOOL successful, UIImage *image, NSError *error))block;
- (void)sendFile:(NSData *)fileData name:(NSString *)fileName mimeType:(NSString *)mimeType completion:(WMResponseCompletionBlock)block;

- (void)setComposingMessage:(BOOL)isComposing completion:(WMResponseCompletionBlock)block;

- (void)rateOperator:(NSString *)authorID withRate:(WMOperatorRate)rate completion:(WMResponseCompletionBlock)block;

+ (void)setDeviceToken:(NSData *)deviceToken;
+ (void)setDeviceTokenString:(NSString *)token;

@end


@protocol WMSessionDelegate <NSObject>

- (void)sessionDidReceiveFullUpdate:(WMSession *)session;
- (void)sessionDidChangeStatus:(WMSession *)session;
- (void)sessionDidChangeChatStatus:(WMSession *)session;
- (void)session:(WMSession *)session didStartChat:(WMChat *)chat;
- (void)session:(WMSession *)session didUpdateOperator:(WMOperator *)chatOperator;
- (void)session:(WMSession *)session didReceiveMessage:(WMMessage *)message;
- (void)session:(WMSession *)session didReceiveError:(WMSessionError)errorID;

@optional
- (void)session:(WMSession *)session didChangeConnectionStatus:(WMSessionConnectionStatus)status;
- (void)session:(WMSession *)session didChangeHasOnlineOperatorStatus:(BOOL)hasOnlineOperator;

@end
