/*
 * Copyright (c) 2012 Mario Negro Martín
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "MNMBottomPullToRefreshView.h"

/*
 * Defines the localized strings table
 */
#define MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE                          @"MNMBottomPullToRefresh"

/*
 * Texts to show in different states
 */
#define MNM_BOTTOM_PTR_PULL_TEXT_KEY                                    NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_PULL_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)
#define MNM_BOTTOM_PTR_RELEASE_TEXT_KEY                                 NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_RELEASE_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)
#define MNM_BOTTOM_PTR_LOADING_TEXT_KEY                                 NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_LOADING_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)

#define MNM_BOTTOM_PTR_LAST_UPDATED_NEVER_KEY                               NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_LAST_UPDATED_NEVER", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)

/*
 * Defines icon image
 */
#define MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE                                @"Arrow.png"

@interface MNMBottomPullToRefreshView()

/*
 * View that contains all controls
 */
@property (nonatomic, readwrite, strong) UIView *containerView;

/*
 * Image with the icon that changes with states
 */
@property (nonatomic, readwrite, strong) UIImageView *iconImageView;

/*
 * Activiry indicator to show while loading
 */
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *loadingActivityIndicator;

/*
 * Label to set state message
 */
@property (nonatomic, readwrite, strong) UILabel *messageLabel;

@property (nonatomic, readwrite, strong) UILabel *lastUpdatedLabel;

/*
 * Current state of the control
 */
@property (nonatomic, readwrite, assign) MNMBottomPullToRefreshViewState state;

/*
 * YES to apply rotation to the icon while view is in MNMBottomPullToRefreshViewStatePull state
 */
@property (nonatomic, readwrite, assign) BOOL rotateIconWhileBecomingVisible;

@end

@implementation MNMBottomPullToRefreshView

@synthesize containerView = containerView_;
@synthesize iconImageView = iconImageView_;
@synthesize loadingActivityIndicator = loadingActivityIndicator_;
@synthesize messageLabel = messageLabel_;
@synthesize lastUpdatedLabel = lastUpdatedLabel_;
@synthesize state = state_;
@synthesize rotateIconWhileBecomingVisible = rotateIconWhileBecomingVisible_;
@dynamic isLoading;
@synthesize fixedHeight = fixedHeight_;

#pragma mark -
#pragma mark Initialization

/*
 * Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 * @param aRect: The frame rectangle for the view, measured in points.
 * @return An initialized view object or nil if the object couldn't be created.
 */
- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [self setBackgroundColor:[UIColor clearColor]];
        
        containerView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        
        [containerView_ setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BG_Upload.png"]]];
        
        [self addSubview:containerView_];
        
        UIImage *iconImage = [UIImage imageNamed:MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE];
        
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(floorf((CGRectGetHeight(frame) - 16) / 2),
                                                                       (floorf(CGRectGetHeight(frame) - 22) / 2),
                                                                        16, 22)];
        [iconImageView_ setContentMode:UIViewContentModeCenter];
        [iconImageView_ setImage:iconImage];
        [iconImageView_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        [containerView_ addSubview:iconImageView_];
        
        loadingActivityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingActivityIndicator_ setCenter:[iconImageView_ center]];
        [loadingActivityIndicator_ setHidesWhenStopped:YES];
        [loadingActivityIndicator_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        [containerView_ addSubview:loadingActivityIndicator_];
        
        messageLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 270, 20)];
        [messageLabel_ setBackgroundColor:[UIColor clearColor]];
        [messageLabel_ setTextColor:[UIColor colorWithRed:85.0 / 255 green:85.0 / 255 blue:85.0 / 255 alpha:1]];
        [messageLabel_ setFont:[UIFont boldSystemFontOfSize:14.0]];
        [messageLabel_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        [containerView_ addSubview:messageLabel_];
        
        lastUpdatedLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 270, 30)];
        lastUpdatedLabel_.backgroundColor = [UIColor clearColor];
        lastUpdatedLabel_.font = [UIFont systemFontOfSize:12];
        lastUpdatedLabel_.textAlignment = NSTextAlignmentLeft;
        lastUpdatedLabel_.textColor = [UIColor colorWithRed:85.0 / 255 green:85.0 / 255 blue:85.0 / 255 alpha:1];
        [lastUpdatedLabel_ setText:MNM_BOTTOM_PTR_LAST_UPDATED_NEVER_KEY];
    
        [containerView_ addSubview:lastUpdatedLabel_];
        
        fixedHeight_ = CGRectGetHeight(frame);
        rotateIconWhileBecomingVisible_ = YES;
        
        [self changeStateOfControl:MNMBottomPullToRefreshViewStateIdle offset:CGFLOAT_MAX];
    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Lays out subviews.
 */
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize messageSize = [[messageLabel_ text] sizeWithFont:[messageLabel_ font]];
    
    CGRect frame = [messageLabel_ frame];
    frame.size.width = messageSize.width;
    [messageLabel_ setFrame:frame];
}

/*
 * Changes the state of the control depending on state_ value
 */
- (void)changeStateOfControl:(MNMBottomPullToRefreshViewState)state offset:(CGFloat)offset {
    
    state_ = state;
    
    CGFloat height = fixedHeight_;
    
    switch (state_) {
        
        case MNMBottomPullToRefreshViewStateIdle: {
            
            [iconImageView_ setTransform:CGAffineTransformIdentity];
            [iconImageView_ setHidden:NO];
            
            [loadingActivityIndicator_ stopAnimating];
            
            [messageLabel_ setText:MNM_BOTTOM_PTR_PULL_TEXT_KEY];
            
            break;
            
        } case MNMBottomPullToRefreshViewStatePull: {
            
            if (rotateIconWhileBecomingVisible_) {
            
                CGFloat angle = (-offset * M_PI) / CGRectGetHeight([self frame]);
                
                [iconImageView_ setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
                
            } else {
            
                [iconImageView_ setTransform:CGAffineTransformIdentity];
            }
            
            [messageLabel_ setText:MNM_BOTTOM_PTR_PULL_TEXT_KEY];
            
            break;
            
        } case MNMBottomPullToRefreshViewStateRelease: {
            
            [iconImageView_ setTransform:CGAffineTransformMakeRotation(M_PI)];
            
            [messageLabel_ setText:MNM_BOTTOM_PTR_RELEASE_TEXT_KEY];
            
            height = fixedHeight_ + fabs(offset);
            
            break;
            
        } case MNMBottomPullToRefreshViewStateLoading: {
            
            [iconImageView_ setHidden:YES];
            
            [loadingActivityIndicator_ startAnimating];
            
            [messageLabel_ setText:MNM_BOTTOM_PTR_LOADING_TEXT_KEY];
            
            height = fixedHeight_ + fabs(offset);
            
            break;
            
        } default:
            break;
    }
    
    CGRect frame = [self frame];
    frame.size.height = height;
    [self setFrame:frame];
    
    [self setNeedsLayout];
}

- (void)updateLastUpdatedTime:(NSString *)string {
    lastUpdatedLabel_.text = string;
}

#pragma mark -
#pragma mark Properties

/*
 * Returns state of activity indicator
 */
- (BOOL)isLoading {
    
    return [loadingActivityIndicator_ isAnimating];
}

@end
