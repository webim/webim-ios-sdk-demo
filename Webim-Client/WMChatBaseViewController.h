//
//  WMChatBaseViewController.h
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIBubbleTableView.h"

@interface WMChatBaseViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIBubbleTableView *bubbleTableView;
@property (strong, nonatomic) IBOutlet UITextField *clientMessageTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (strong, nonatomic) IBOutlet UIView *textInputPlaceholder;
@property (strong, nonatomic) IBOutlet UITextView *supportedByTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *operatorBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *operatorImageView;
@property (strong, nonatomic) IBOutlet UILabel *operatorNameLabel;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

- (IBAction)cameraButtonAction:(id)sender;

- (void)sendImage:(UIImage *)image;

@end
