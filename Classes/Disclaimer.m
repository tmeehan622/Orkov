//
//  Disclaimer.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/25/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "Disclaimer.h"


@implementation Disclaimer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.hidesBottomBarWhenPushed = YES;
	}
    return self;
}

- (void)viewDidLoad {
#ifndef __DEBUG_OUTPUT__
	[Flurry logEvent:@"Disclaimer open"];
#endif
    [super viewDidLoad];
	self.navigationItem.title = @"Disclaimer";
}


@end
