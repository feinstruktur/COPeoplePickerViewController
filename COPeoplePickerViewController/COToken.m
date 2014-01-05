//
//  COToken.m
//  COPeoplePickerViewController
//
//  Created by Maciej Trybiło on 17/06/2013.
//  Copyright (c) 2013 chocomoko.com. All rights reserved.
//

#import "COToken.h"
#import "COTokenField.h"

const CGFloat kTokenFieldFontSize = 14.0;
static const CGFloat kTokenFieldMaxTokenWidth = 260.0;
const CGFloat kTokenFieldTokenHeight = (kTokenFieldFontSize + 4.0);
const CGFloat kTokenFieldPaddingX = 6.0;
const CGFloat kTokenFieldInsetX = 20;
const CGFloat kTokenFieldPaddingY = 6.0;

@implementation COToken

@synthesize contactName = _contactName;
@synthesize emailAddress = _emailAddress;
@synthesize associatedObject = _associatedObject;
@synthesize showName = _showName;


+ (COToken *)tokenWithEmailAddress:(NSString *)emailAddress contactName:(NSString *)contactName  associatedObject:(id)obj

{
    COToken *token = [self buttonWithType:UIButtonTypeCustom];
    token.associatedObject = obj;
    token.contactName = contactName;
    token.emailAddress = emailAddress;
    token.accessibilityLabel = token.contactName;
    
    // Show contact name if provided, otherwise show email address initially
    token.showName = contactName != nil;

    token.backgroundColor = [UIColor clearColor];
    
    UIFont *font = [UIFont systemFontOfSize:kTokenFieldFontSize];
    token.titleLabel.font = font;
    [token updateBounds];
    
    return token;
}

- (void) updateBounds
{
    NSString * displayText = self.showName ? self.contactName : self.emailAddress;
    CGSize tokenSize = [displayText sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    tokenSize.width = MIN((CGFloat)kTokenFieldMaxTokenWidth, tokenSize.width);
    tokenSize.width += kTokenFieldPaddingX * 2.0;
    
    tokenSize.height = MIN((CGFloat)kTokenFieldFontSize, tokenSize.height);
    tokenSize.height += kTokenFieldPaddingY * 2.0;
    
    self.frame = (CGRect){CGPointZero, tokenSize};
}

- (void) toggleDisplayName
{
    //
    // Only toggle the display name if we have a contactName to display
    //
    if (self.contactName != nil) {
        self.showName = !self.showName;
    }
    [self updateBounds];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat radius = CGRectGetHeight(self.bounds) / 2.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    cornerRadius:radius];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path.CGPath);
    CGContextClip(ctx);
    
    NSArray *colors = nil;
    if (self.isHighlighted || self.isSelected) {
        colors =
        @[(__bridge id)[UIColor colorWithRed:0.322 green:0.541 blue:0.976 alpha:1.0].CGColor,
          (__bridge id)[UIColor colorWithRed:0.235 green:0.329 blue:0.973 alpha:1.0].CGColor];
    }
    else {
        colors =
        @[(__bridge id)[UIColor colorWithRed:0.863 green:0.902 blue:0.969 alpha:1.0].CGColor,
          (__bridge id)[UIColor colorWithRed:0.741 green:0.808 blue:0.937 alpha:1.0].CGColor];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient =
    CGGradientCreateWithColors(colorSpace, (__bridge CFTypeRef)colors, NULL);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawLinearGradient(ctx, gradient,
                                CGPointZero,
                                CGPointMake(0, CGRectGetHeight(self.bounds)), 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
    
//    NSLog(@"drawing Token with highlighted %@ selected %@", self.isHighlighted ? @"ON" : @"OFF", self.isSelected ? @"ON" : @"OFF");
    if (self.highlighted || self.selected) {
        [[UIColor colorWithRed:0.275f green:0.478f blue:0.871f alpha:1.0f] set];
    }
    else {
        [[UIColor colorWithRed:0.667f green:0.757f blue:0.914f alpha:1.0f] set];
    }
    
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 1.5, 1.5)
                                      cornerRadius:radius];
    [path setLineWidth:0.5];
    [path stroke];
    
    if (self.isHighlighted || self.isSelected) {
        [[UIColor whiteColor] set];
    }
    else {
        [[UIColor blackColor] set];
    }

    NSString * displayText = self.showName ? self.contactName : self.emailAddress;

    UIFont *titleFont = [UIFont systemFontOfSize:kTokenFieldFontSize];
    CGSize titleSize = [displayText sizeWithAttributes:@{NSFontAttributeName:titleFont}];
    CGRect titleFrame = CGRectMake((CGRectGetWidth(self.bounds) - titleSize.width) / 2.0f,
                                   (CGRectGetHeight(self.bounds) - titleSize.height) / 2.0f,
                                   titleSize.width,
                                   titleSize.height);
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [displayText drawInRect:titleFrame withAttributes:@{NSFontAttributeName:titleFont,  NSParagraphStyleAttributeName:paragraphStyle}];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ contactName: '%@'; associatedObj: '%@'>",
            NSStringFromClass([self class]), self.contactName, self.associatedObject];
}

@end

