//
//  COEmailTableCell.m
//  COPeoplePickerViewController
//
//  Created by Maciej Trybiło on 17/06/2013.
//  Copyright (c) 2013 chocomoko.com. All rights reserved.
//

#import "COEmailTableCell.h"

#import "PIETheme.h"

@implementation COEmailTableCell

@synthesize nameLabel = _nameLabel;
@synthesize emailLabelLabel = _emailLabelLabel;
@synthesize emailAddressLabel = _emailAddressLabel;
@synthesize associatedRecord = _associatedRecord;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.nameLabel.font = [PIETheme brandFont:PIEFontTypeH5 weight:PIEFontWeightM];
        self.nameLabel.textColor = [PIETheme brandTundora];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.emailLabelLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.emailLabelLabel.font = [PIETheme brandFont:PIEFontTypeC3 weight:PIEFontWeightL];
        self.emailLabelLabel.textColor = [PIETheme brandGrey];
        self.emailLabelLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
        self.emailAddressLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.emailAddressLabel.font = [PIETheme brandFont:PIEFontTypeC3 weight:PIEFontWeightL];
        self.emailAddressLabel.textColor = [PIETheme brandGrey];
        self.emailAddressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.nameLabel];
        [self addSubview:self.emailLabelLabel];
        [self addSubview:self.emailAddressLabel];
        
        [self adjustLabels];
    }
    return self;
}

- (void)adjustLabels {
    CGSize emailLabelSize =
    [self.emailLabelLabel.text sizeWithAttributes:@{NSFontAttributeName : self.emailLabelLabel.font}];
    
    CGFloat leftInset = 8;
    CGFloat yInset = 4;
    CGFloat labelWidth = emailLabelSize.width;
    
    self.nameLabel.frame =
    CGRectMake(leftInset,
               yInset + 1,
               CGRectGetWidth(self.bounds) - leftInset * 2,
               CGRectGetHeight(self.bounds) / 2.0f - yInset);
    
    self.emailLabelLabel.frame =
    CGRectMake(leftInset,
               CGRectGetMaxY(self.nameLabel.frame),
               labelWidth,
               CGRectGetHeight(self.bounds) / 2.0f - yInset);
    
    self.emailAddressLabel.frame =
    CGRectMake(labelWidth + leftInset * 2,
               CGRectGetMaxY(self.nameLabel.frame),
               CGRectGetWidth(self.bounds) - labelWidth - leftInset * 3,
               CGRectGetHeight(self.bounds) / 2.0f - yInset);
}

@end
