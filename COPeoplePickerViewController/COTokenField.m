//
//  COTokenField.m
//  COPeoplePickerViewController
//
//  Created by Maciej Trybiło on 17/06/2013.
//  Copyright (c) 2013 chocomoko.com. All rights reserved.
//


#import "COTokenField.h"
#import "COToken.h"
#import "ABContact.h"
// #import "CORecordEmail.h"
#import "DDLog.h"

#ifdef DEBUG
static int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static int ddLogLevel = LOG_LEVEL_WARN;
#endif


const CGFloat kTokenFieldShadowHeight = 14.0;

@interface COTokenField() {
    NSString * _hint;
    BOOL _compactMode;
}

@end

@implementation COTokenField

@synthesize tokenFieldDelegate = _tokenFieldDelegate;
@synthesize textField = _textField;
@synthesize hintLabel = _hintLabel;
@synthesize addContactButton = _addContactButton;
@synthesize tokens = _tokens;
@synthesize selectedToken = _selectedToken;

static NSString *kCOTokenFieldDetectorString = @"\u200B";


+ (void)initialize
{
    NSNumber *logLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"LogLevel"];
    if (logLevel) {
        ddLogLevel = [logLevel intValue];
    }
}


- (void) initContents
{
    self.tokens = [NSMutableArray new];
    self.opaque = NO;
    _compactMode = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    // Setup contact add button
    self.addContactButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.addContactButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.addContactButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect buttonFrame = self.addContactButton.frame;
    self.addContactButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - 2*kTokenFieldPaddingX,
                                             CGRectGetHeight(self.bounds) - CGRectGetHeight(buttonFrame) - 2*kTokenFieldPaddingY,
                                             buttonFrame.size.height,
                                             buttonFrame.size.width);
    
    [self addSubview:self.addContactButton];
    self.addContactButton.hidden = YES;
    
    // Setup text field
    CGFloat textFieldHeight = self.computedRowHeight;
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(kTokenFieldPaddingX,
                                                                   (CGRectGetHeight(self.bounds) - textFieldHeight) / 2.0,
                                                                   CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - kTokenFieldPaddingX * 3.0,
                                                                   textFieldHeight)];
    self.textField.opaque = NO;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.font = [UIFont systemFontOfSize:kTokenFieldFontSize];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.text = kCOTokenFieldDetectorString;
    self.textField.delegate = self;
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    hintLabel.font = self.textField.font;
    hintLabel.textColor = [UIColor grayColor];
    
    self.hintLabel = hintLabel;
    [self addSubview:hintLabel];
    
    [self.textField addTarget:self action:@selector(tokenInputChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self addSubview:self.textField];
    
    [self setNeedsLayout];
}

- (void) awakeFromNib
{
    [self initContents];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initContents];
        
    }
    return self;
}

- (void) updateHintLabel
{
    UILabel *hintLabel = self.hintLabel;
    hintLabel.text = _hint;
    [hintLabel sizeToFit];
    
    CGRect frame = hintLabel.frame;
    frame.origin = CGPointMake(kTokenFieldInsetX, kTokenFieldPaddingY);
    frame.size.height = self.textField.frame.size.height;
    frame.size.width += 5;
    hintLabel.frame = frame;
    
}

- (void) viewDidLoad
{
    [self updateHintLabel];
}

- (void)setHint:(NSString *)hint
{
    _hint = hint;
    [self updateHintLabel];
}

- (NSString *)hint
{
    return _hint;
}

- (void)addContact:(id)sender
{
    id<COTokenFieldDelegate> tokenFieldDelegate = self.tokenFieldDelegate;
    [tokenFieldDelegate tokenFieldDidPressAddContactButton:self];
}

- (CGFloat)computedRowHeight
{
    CGFloat buttonHeight = CGRectGetHeight(self.addContactButton.frame);
    return MAX(buttonHeight, (CGFloat)(kTokenFieldPaddingY * 2.0 + kTokenFieldTokenHeight));
}

- (CGFloat)heightForNumberOfRows:(NSUInteger)rows
{
    return (CGFloat)rows * self.computedRowHeight + (CGFloat)kTokenFieldPaddingY * 2.0f;
}

- (void)layoutSubviews
{
    if (_compactMode) {
        [self layoutCompactedSubviews];
    } else {
        [self layoutExpandedSubviews];
    }
}

- (void) layoutCompactedSubviews
{
    DDLogInfo(@"layoutCompactedView");

    self.addContactButton.hidden = YES;

    for (COToken * token in self.tokens) {
        [token removeFromSuperview];
    }
    
    NSMutableString * names = [[NSMutableString alloc] init];
    NSString * displayText;
    BOOL insertComma = NO;
    NSInteger nameCount = [self.tokens count];
    
    for (COToken * token in self.tokens) {
        NSString * separationString = insertComma ? @", " : @"";
        NSString * previousNames = [names copy];
        [names appendFormat:@"%@%@", separationString, [token displayString]];
        //
        // Make sure this the name is not too long
        //
        _textField.text = names;
        [_textField sizeToFit];
        
        if ((_textField.frame.size.height > 44) || (_textField.frame.size.width > 150)) {
            if (nameCount == 1) displayText = [previousNames stringByAppendingString:@", and 1 other"];
            else displayText = [previousNames stringByAppendingFormat:@", and %d others", nameCount];
            break;
        }
        insertComma = YES;
        --nameCount;
        displayText = names;
    }
    
    // adjust the text field frame
    CGFloat left = self.hintLabel.frame.size.width + self.hintLabel.frame.origin.x;
    CGRect textFieldFrame = self.textField.frame;
    
    textFieldFrame.origin.x = left;
    textFieldFrame.origin.y = kTokenFieldPaddingY;
    
    textFieldFrame.size = CGSizeMake(self.frame.size.width - left,
                                     self.computedRowHeight);
    
    _textField.text = displayText;
    _textField.frame = textFieldFrame;
    _textField.hidden = NO;
    
    CGRect frame = self.frame;
    frame.size.height = textFieldFrame.size.height + 1.5*kTokenFieldPaddingY;
    self.frame = frame;
}

- (void) layoutExpandedSubviews
{
    DDLogInfo(@"layoutExpandedView");
    
    self.addContactButton.hidden = NO;
    
    NSUInteger row = 0;
    
    // span of the free space in the last row
    CGFloat left = self.hintLabel.frame.size.width + self.hintLabel.frame.origin.x;
    CGFloat right = self.frame.size.width - CGRectGetWidth(self.addContactButton.frame) - 2*kTokenFieldPaddingX;
    
    CGFloat rowHeight = self.computedRowHeight;
    
    for (COToken *token in self.tokens) {
        
        CGFloat tokenRight = left + CGRectGetWidth(token.bounds);
        if (tokenRight > right) {
            row++;
            left = kTokenFieldInsetX;
        }
        
        // Adjust token frame
        CGRect tokenFrame = token.frame;
        tokenFrame.origin.x = left;
        tokenFrame.origin.y = row * rowHeight + (rowHeight - CGRectGetHeight(tokenFrame)) / 2.0f + kTokenFieldPaddingY;
        
        token.frame = tokenFrame;
        
        left += CGRectGetWidth(tokenFrame) + kTokenFieldPaddingX;
        
        [self addSubview:token];
    }
    
    if (right - left < 60) {
        row++;
        left = kTokenFieldInsetX;
    }
    
    // adjust the text field frame
    CGRect textFieldFrame = self.textField.frame;
    
    textFieldFrame.origin.x = left;
    textFieldFrame.origin.y = row * rowHeight + (rowHeight - CGRectGetHeight(textFieldFrame)) / 2.0f + kTokenFieldPaddingY;
    
    textFieldFrame.size = CGSizeMake(right - left,
                                     CGRectGetHeight(textFieldFrame));
    
    self.textField.frame = textFieldFrame;
    
    // adjust the height of the self
    CGRect tokenFieldFrame = self.frame;
    CGFloat minHeight = MAX(rowHeight,
                            CGRectGetHeight(self.addContactButton.frame) + kTokenFieldPaddingY * 2.0f);
    
    tokenFieldFrame.size.height = MAX(minHeight,
                                      CGRectGetMaxY(textFieldFrame) + kTokenFieldPaddingY);
    
    DDLogInfo(@"frame of TokenField changing height from %f to %f", self.frame.size.height, tokenFieldFrame.size.height);
    self.frame = tokenFieldFrame;
}

- (void) tokenPressed:(COToken *) token
{
    DDLogInfo(@"tokenPressd called");
    [self selectToken:token];
    [self setNeedsLayout];
}

- (void)selectToken:(COToken *)token
{
    @synchronized (self) {
        if (token != nil) {
            self.textField.hidden = YES;
        }
        else {
            self.textField.hidden = NO;
            [self.textField becomeFirstResponder];
        }
        
        self.selectedToken = token;
        
        if (token.isSelected) [token toggleDisplayName];
        
        for (COToken *t in self.tokens) {
            if (t == token) {
                t.selected = YES;
            } else {
                t.selected = NO;
            }
            [t setNeedsDisplay];
        }
    }
}

- (void)removeAllTokens
{
    for (COToken *token in self.tokens) {
        [token removeFromSuperview];
    }
    [self.tokens removeAllObjects];
    self.textField.hidden = NO;
    self.selectedToken = nil;
    [self setNeedsLayout];
}

- (void)removeToken:(COToken *)token
{
    [token removeFromSuperview];
    [self.tokens removeObject:token];
    self.textField.hidden = NO;
    self.selectedToken = nil;
    [self setNeedsLayout];
}

- (void)modifyToken:(COToken *)token
{
    if (token != nil) {
        if (token == self.selectedToken) {
            [self removeToken:token];
        }
        else {
            [self selectToken:token];
        }
        [self setNeedsLayout];
    }
}

- (void)modifySelectedToken
{
    COToken *token = self.selectedToken;
    if (token == nil) {
        token = [self.tokens lastObject];
    }
    [self modifyToken:token];
}

- (void)processTokenWithEmailAddress:(NSString *) emailAddress contactName:(NSString *) contactName  associatedRecord:(ABContact *)contact
{
    COToken *token = [COToken tokenWithEmailAddress:emailAddress contactName:contactName  associatedObject:contact];
    [token addTarget:self action:@selector(tokenPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.tokens addObject:token];
    self.textField.text = kCOTokenFieldDetectorString;
    id<COTokenFieldDelegate> tokenFieldDelegate = self.tokenFieldDelegate;
    [tokenFieldDelegate tokenField:self searchingModeChanged:NO];
    [self setNeedsLayout];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self selectToken:nil];
}

- (NSString *)textWithoutDetector
{
    NSString *text = self.textField.text;
    if (text.length > 0) {
        return [text substringFromIndex:1];
    }
    return text;
}

static BOOL containsString(NSString *haystack, NSString *needle)
{
    return ([haystack rangeOfString:needle options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound);
}

- (void)tokenInputChanged:(id)sender
{
    NSString *searchText = self.textWithoutDetector;
    NSArray *matchedRecords = @[];
    if (searchText.length > 0) {
        // Generate new search dict only after a certain delay
        static NSDate *lastUpdated = nil;;
        static NSMutableArray *records = nil;
        if (records == nil || [lastUpdated timeIntervalSinceDate:[NSDate date]] < -10) {
            ABAddressBookRef ab = [_tokenFieldDelegate addressBookForTokenField:self];
            NSArray *people = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(ab));
            records = [NSMutableArray new];
            for (id obj in people) {
                ABRecordRef recordRef = (__bridge CFTypeRef)obj;
                ABContact *contact = [ABContact contactWithRecord:recordRef];
                [records addObject:contact];
            }
            lastUpdated = [NSDate date];
        }
        
        NSIndexSet *resultSet = [records indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            ABContact *contact = (ABContact *)obj;
            if ([contact.contactName length] != 0 && containsString(contact.contactName, searchText)) {
                return YES;
            }
            for (NSString *email in contact.emailArray) {
                if (containsString(email, searchText)) {
                    return YES;
                }
            }
            return NO;
        }];
        
        // Generate results to pass to the delegate
        matchedRecords = [records objectsAtIndexes:resultSet];
    }
    
    [_tokenFieldDelegate tokenField:self
              searchingModeChanged:[self.textField.text length] > 0];
    
    [_tokenFieldDelegate tokenField:self updateAddressBookSearchResults:matchedRecords];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0 && [textField.text isEqualToString:kCOTokenFieldDetectorString]) {
        [self modifySelectedToken];
        return NO;
    }
    else if (textField.hidden) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.hidden) {
        return NO;
    }
    NSString *text = self.textField.text;
    if ([text length] > 1) {
        [self processTokenWithEmailAddress:[text substringFromIndex:1] contactName:nil associatedRecord:nil];
    }
    else {
        return [textField resignFirstResponder];
    }
    return YES;
}

#pragma - Keyboard Notifications

- (BOOL) textFieldShouldBeginEditing:(UITextField *) textField
{
    _compactMode = NO;
    _textField.text = kCOTokenFieldDetectorString;
    [self setNeedsLayout];
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *) textField
{
    _compactMode = YES;
    [self setNeedsLayout];
    return YES;
}

@end

