//
//  History.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/25/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchController;

@interface History : UIViewController {
}

@property (nonatomic, strong) NSArray                                   *history;
@property (nonatomic,weak) SearchController        *delegate;
@property (nonatomic,weak) IBOutlet UITableView    *myTable;
@property (nonatomic,assign) int						recordIndex;


- (IBAction)clearHistory:(id) sender;

@end
