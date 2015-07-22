//
//  WMChatDataViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatDataViewController.h"

#import "WebimController.h"
#import <JSQMessage.h>

#import "WMOperator.h"

static const NSTimeInterval DisplayDateEachTimeInterval = 60; // One minute

@interface WMChatDataViewController () < WMChatDataSourceProtocol>

@property (nonatomic, strong) JSQMessagesBubbleImageFactory *imageFactory;

@end

@implementation WMChatDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareDataSource];
}

- (void)prepareDataSource {
    WMChat *chat = nil;
    if ([self respondsToSelector:@selector(chatDataSourceCurrentChat)]) {
        chat = [self chatDataSourceCurrentChat];
    }
    
    [self loadOperator:chat.chatOperator];
    [self loadSender];
    [self loadSystem];
    [self loadMessages:chat];
}

- (void)loadOperator:(WMOperator *)operator {
    self.operatorID = @"operator";
    self.operatorName = @"Operator";
    self.operatorBubbleImage = [self.imageFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    if (operator != nil && operator.name.length > 0) {
        self.operatorName = operator.name;
    }
    if (operator != nil && operator.avatarPath.length > 0) {
        WMBaseSession *session = [self session];
        NSString *avatarPath = [NSString stringWithFormat:@"%@%@", [session host], operator.avatarPath];
        NSURL *avatarURL = [NSURL URLWithString:avatarPath];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:avatarURL]];
        self.operatorAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                              diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
    if (self.operatorAvatarImage == nil) {
        self.operatorAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"visitor_avatar_default"]
                                                                              diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
}

- (void)loadSender {
    self.senderId = @"sender";
    self.senderDisplayName = @"Me";
    self.senderBubbleImage = [self.imageFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.senderAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"visitor_avatar_default"]
                                                                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

- (void)loadSystem {
    self.systemID = @"system";
    self.systemName = @"System";
    self.systemBubbleImage = [self.imageFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.systemAvararImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"system_avatar_default"]
                                                                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

- (void)loadMessages:(WMChat *)chat {
    NSMutableArray *newMessagesArray = [NSMutableArray arrayWithCapacity:chat.messages.count];
    
    for (WMMessage *message in chat.messages) {
        JSQMessage *jsqMessage = [self chatMessageForWMMessage:message];
        if (jsqMessage != nil) {
            [newMessagesArray addObject:jsqMessage];
        }
    }
    self.messagesDataSource = newMessagesArray;
    [self prepareTimestampDataSource];
}
                              
- (JSQMessage *)chatMessageForWMMessage:(WMMessage *)message {
    JSQPhotoMediaItem *mediaItem = nil;
    switch (message.kind) {
        case WMMessageKindVisitor:
            return [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:message.timestamp text:message.text];
        case WMMessageKindOperator:
            return [[JSQMessage alloc] initWithSenderId:self.operatorID senderDisplayName:self.operatorName date:message.timestamp text:message.text];
        case WMMessageKindFileFromVisitor:
            mediaItem = [self photoItemForWMMessage:message];
            return [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:message.timestamp media:mediaItem];
        case WMMessageKindFileFromOperator:
            mediaItem = [self photoItemForWMMessage:message];
            return [[JSQMessage alloc] initWithSenderId:self.operatorID senderDisplayName:self.operatorName date:message.timestamp media:mediaItem];
        case WMMessageKindInfo:
            return [[JSQMessage alloc] initWithSenderId:self.systemID senderDisplayName:self.systemName date:message.timestamp text:message.text];
        default: return nil;
    }
}

- (JSQPhotoMediaItem *)photoItemForWMMessage:(WMMessage *)message {
    UIImage *image = [WebimController shared].imagesMap[message.text];
    if (image != nil) {
        return [[JSQPhotoMediaItem alloc] initWithImage:image];
    } else {
        if (![self respondsToSelector:@selector(chatDataSourceDownloadImageForMessage:completion:)]) {
            return nil;
        }
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
    return [[JSQPhotoMediaItem alloc] initWithImage:nil];
}

- (void)delayedTableUpdate {
    [self reloadBubbleTableView];
}

- (void)prepareTimestampDataSource {
    NSMutableDictionary *timeStampsDictionary = [NSMutableDictionary new];
    NSDate *lastTs = nil;
    
    for (NSInteger i = 0; i < self.messagesDataSource.count; i++) {
        JSQMessage *message = self.messagesDataSource[i];

        if (lastTs == nil || [message.date timeIntervalSinceDate:lastTs] > DisplayDateEachTimeInterval) {
            lastTs = message.date;
            [timeStampsDictionary setObject:[[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date]
                                     forKey:@(i)];
        }
    }
    self.timestampMessageDictionary = timeStampsDictionary;
}

- (void)reloadBubbleTableView {
    [self prepareDataSource];
    [self.collectionView reloadData];
}

#pragma mark - Properties

- (JSQMessagesBubbleImageFactory *)imageFactory {
    if (_imageFactory == nil) {
        _imageFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    }
    return _imageFactory;
}

#pragma mark - JSQMessages
#pragma mark - JSQMessagesCollectionViewDataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.messagesDataSource objectAtIndex:indexPath.item];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return self.timestampMessageDictionary[@(indexPath.item)];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.messagesDataSource objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.operatorID]) {
        return [[NSAttributedString alloc] initWithString:self.operatorName];
    } else if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    } else if ([message.senderId isEqualToString:self.systemID]) {
        return nil;
    }
    return nil;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {

    JSQMessage *message = [self.messagesDataSource objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.operatorID]) {
        return self.operatorBubbleImage;
    } else if ([message.senderId isEqualToString:self.senderId]) {
        return self.senderBubbleImage;
    } else if ([message.senderId isEqualToString:self.systemID]) {
        return self.systemBubbleImage;
    }
    
    return nil;
}


- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.messagesDataSource objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.operatorID]) {
        return self.operatorAvatarImage;
    } else if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    } else if ([message.senderId isEqualToString:self.systemID]) {
        return nil;
    }
    
    return nil;
}

#pragma mark - JSQMessagesCollectionViewDelegateFlowLayout Delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (self.timestampMessageDictionary[@(indexPath.item)] != nil) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.messagesDataSource objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.operatorID]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    } else if ([message.senderId isEqualToString:self.senderId]) {
        return 0.f;
    } else if ([message.senderId isEqualToString:self.systemID]) {
        return 0.f;
    }
    return 0.0f;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messagesDataSource.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = nil;
    
    JSQMessage *msg = [self.messagesDataSource objectAtIndex:indexPath.item];
    cell = (id)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.operatorID]) {
            cell.textView.textColor = [UIColor blackColor];
        } else if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        } else if ([msg.senderId isEqualToString:self.systemID]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor ?: [UIColor whiteColor],
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

#pragma mark - JSQMessagesCollectionViewDelegateFlowLayout

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    // You can resend failed messages from here
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.messagesDataSource objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.operatorID]) {
        [self openOperatorRatingView:message.senderId];
    }
}

#pragma mark - JSQMessagesViewController

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    // Send a message
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    [self cameraButtonAction:sender];
}


@end
