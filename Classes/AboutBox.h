//
//  AboutBox.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/24/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol modalDelegate

-(void)dismissOptions;

@end

@interface AboutBox : UIViewController {
}
@property (nonatomic,assign) BOOL modal;
@property (nonatomic,weak) id <modalDelegate> controller;
@property (nonatomic, weak) IBOutlet UITextView *tv;


-(IBAction)done:(id)sender;
@end
