//
//  LimitsController.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/9/09.
//  Copyright 2009 The Frodis Co.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LimitsController : UIViewController {
}

@property (nonatomic, weak) IBOutlet	UITableView    *myTable;
@property (nonatomic, strong) UIBarButtonItem               *cancelButton;
@property (nonatomic, strong) NSArray                       *segmentHeadings;
@property (nonatomic, strong) NSArray                       *tableValues;	// this is s stub
@property (nonatomic, assign) BOOL		cancelling;

- (IBAction) cancelEnditing:(id)sender;

@end
