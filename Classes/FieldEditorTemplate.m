//
//  FieldEditorTemplate.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/16/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "FieldEditorTemplate.h"


@implementation FieldEditorTemplate

- (IBAction) cancelEnditing:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}
@end
