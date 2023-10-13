//
//  TextEditCell.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/18/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "TextEditCell.h"


@implementation TextEditCell
@synthesize myTextEditField;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		CGRect r = self.frame;
		r = CGRectMake(20, 8, 230, 30);
		myTextEditField = [[UITextField alloc] initWithFrame:r];
		[self addSubview:myTextEditField];
		myTextEditField.frame = r;
		myTextEditField.clearButtonMode = UITextFieldViewModeWhileEditing;
		myTextEditField.borderStyle = UITextBorderStyleRoundedRect;
		myTextEditField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void) setWidth:(double)w
{
	CGRect r = myTextEditField.frame;
	r.size.width = w - 38;
	myTextEditField.frame = r;
	
} // setWidth

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
