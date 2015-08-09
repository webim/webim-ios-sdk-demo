//
//  WMMessage.h
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WMMessageKindUnknown,
    WMMessageKindForOperator,
    WMMessageKindInfo,
    WMMessageKindVisitor,
    WMMessageKindOperator,
    WMMessageKindOperatorBusy,
    WMMessageKindContactsRequest,
    WMMessageKindContacts,
    WMMessageKindFileFromOperator,
    WMMessageKindFileFromVisitor,
} WMMessageKind;

@class WMBaseSession;

@interface WMMessage : NSObject

@property (nonatomic, assign) WMMessageKind kind;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) id messageData;
@property (nonatomic, strong) NSString *uid;

@property (nonatomic, readonly) NSString *senderUID;
@property (nonatomic, readonly) NSString *senderName;
@property (nonatomic, readonly) NSURL *senderAvatarURL;

@property (nonatomic, weak) WMBaseSession *session;
@property (nonatomic, strong) NSString *authorID;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *name;

- (NSString *)filePath;

- (BOOL)isTextMessage;
- (BOOL)isFileMessage;

@end
