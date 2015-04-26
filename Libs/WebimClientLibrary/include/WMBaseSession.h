//
//  WMBaseSession.h
//  WebimClientLibrary
//
//  Created by Oleg Bogumirsky on 09/07/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WMSessionErrorUnknown,
    WMSessionErrorReinitRequired,
    WMSessionErrorServerNotReady,
    WMSessionErrorAccountBlocked,
    WMSessionErrorVisitorBanned,
    WMSessionErrorNetworkError,
    WMSessionErrorVisitorNotSet,            // ex WMSessionErrorNotAnError
    WMSessionErrorEmptyMessageText,         // ex WMSessionErrorChatText
    WMSessionErrorChatNotFound,             // to be removed
    WMSessionErrorNotConfigured,            // to be removed
    WMSessionErrorAttachmentTypeNotAllowed,
    WMSessionErrorAttachmentSizeExceeded,
    WMSessionErrorMessageSizeExceeded,
    WMSessionErrorResponseDataError,
} WMSessionError;

typedef enum {
    WMChatAttachmentImageJPEG,
    WMChatAttachmentImagePNG,
} WMChatAttachmentImageType;

@class WMMessage;

extern NSString *const WMWebimErrorDomain;

@interface WMBaseSession : NSObject

@property (nonatomic, strong) NSString *location;
@property (nonatomic, readonly, strong) NSString *accountName;

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location;

- (NSString *)host;
- (void)clearCachedUserData;

- (NSURL *)attachmentURLForMessage:(WMMessage *)message;

@end
