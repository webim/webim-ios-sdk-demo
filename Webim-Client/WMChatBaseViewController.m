//
//  WMChatBaseViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatBaseViewController.h"

#import "UIImage+OrientationFix.h"

@interface WMChatBaseViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation WMChatBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef NSFoundationVersionNumber_iOS_6_1
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)cameraButtonAction:(id)sender {
    UIActionSheet *actionSheet = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:WMLocString(@"DialogCancelButton")
                       destructiveButtonTitle:nil
                       otherButtonTitles:WMLocString(@"ImagePickerUseCamera"), WMLocString(@"ImagePickerUserPhotos"), nil];
    } else {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil delegate:self
                       cancelButtonTitle:WMLocString(@"DialogCancelButton")
                       destructiveButtonTitle:nil
                       otherButtonTitles:WMLocString(@"ImagePickerUserPhotos"), nil];
    }
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (buttonIndex == 0) {
            [self pickPhotoWithSourceType:UIImagePickerControllerSourceTypeCamera];
        } else if (buttonIndex == 1) {
            [self pickPhotoWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    } else {
        [self pickPhotoWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)pickPhotoWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        if (self.imagePickerController == nil) {
            self.imagePickerController = [[UIImagePickerController alloc] init];
        }
        self.imagePickerController.delegate = self;
        self.imagePickerController.sourceType = sourceType;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self sendImage:[image imageWithOrientationUp]];
}

- (void)sendImage:(UIImage *)image {
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        kbSize = CGSizeMake(kbSize.height, kbSize.width);
    }
    __block CGRect frame = _textInputPlaceholder.frame;
    frame.origin.y -= kbSize.height - CGRectGetHeight(_supportedByTextView.frame);
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _textInputPlaceholder.frame = frame;
        frame = self.bubbleTableView.frame;
        frame.size.height -= kbSize.height - CGRectGetHeight(_supportedByTextView.frame);;
        
        if (self.bubbleTableView.contentSize.height - self.bubbleTableView.contentOffset.y == self.bubbleTableView.frame.size.height ||
            (self.bubbleTableView.contentSize.height < self.bubbleTableView.frame.size.height &&
             self.bubbleTableView.contentSize.height > frame.size.height)) {
                self.bubbleTableView.contentOffset = CGPointMake(0, self.bubbleTableView.contentSize.height - frame.size.height);
            }
    } completion:^(BOOL finished) {
        self.bubbleTableView.frame = frame;
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    __block CGRect frame = self.bubbleTableView.frame;
    CGFloat delimiterPosition = CGRectGetHeight(self.view.frame) -
    CGRectGetHeight(_textInputPlaceholder.frame) -
    CGRectGetHeight(_supportedByTextView.frame);
    frame.size.height = delimiterPosition;
    CGPoint offset = self.bubbleTableView.contentOffset;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bubbleTableView.frame = frame;
        self.bubbleTableView.contentOffset = offset;
        if (self.bubbleTableView.contentSize.height - self.bubbleTableView.contentOffset.y < self.bubbleTableView.frame.size.height) {
            NSInteger hiddenContentHeight = self.bubbleTableView.contentSize.height - frame.size.height;
            self.bubbleTableView.contentOffset = CGPointMake(0, hiddenContentHeight > 0 ? hiddenContentHeight : 0);
        }
        frame = _textInputPlaceholder.frame;
        frame.origin.y = delimiterPosition;
        _textInputPlaceholder.frame = frame;
    } completion:nil];
}

@end
