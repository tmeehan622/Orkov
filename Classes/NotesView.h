//
//  NotesView.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/31/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NotesView : UIViewController {
}
@property (nonatomic,weak) IBOutlet	UILabel     *noteTitle;
@property (nonatomic,weak) IBOutlet	UITextView  *notes;
@property (nonatomic,weak) IBOutlet	id	        delegate;
@property (nonatomic,assign) BOOL	            editing;
@property (nonatomic,assign) BOOL	            changed;
@property (nonatomic, strong) UIBarButtonItem   *editButton;
@property (nonatomic, strong) NSDictionary        *info;
@property (nonatomic, strong) NSMutableDictionary        *currentNote;
@property (weak, nonatomic) IBOutlet UILabel *dateLBL;

-(IBAction)toggleEditing:(id)sender;

@end
