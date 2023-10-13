//
//  Settings.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/24/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface Settings : UIViewController <MFMailComposeViewControllerDelegate>{
}



@property (nonatomic,weak) IBOutlet UITableView *myTable;
@property (nonatomic, strong)  NSArray  *tableHeadings;
@end
