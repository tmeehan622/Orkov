//
//  PopUpImage.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/10/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "PopUpImage.h"


@implementation PopUpImage


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"POPUP_DONE" object:self]];
} // touchesEnded


@end
