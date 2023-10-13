//
//  LimitEditor.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/16/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchController;

@interface LimitEditor : UIViewController {
}
@property (nonatomic, strong) SearchController      *myController;
@property (nonatomic, weak) IBOutlet UITableView    *myTable;		
@property (nonatomic, strong) NSMutableArray    *infoContainer;
@property (nonatomic, strong) NSMutableArray    *info;
@property (nonatomic, assign) int index;

- (void) setInfo:(NSMutableArray*)newInfo atIndex:(int)newIndex;
- (IBAction) clearFields:(id)sender;
@end
