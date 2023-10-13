//
//  NotesView.m
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/31/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "NotesView.h"
#import "BookMarksController.h"


@implementation NotesView
@synthesize noteTitle;
@synthesize notes;
@synthesize delegate;
@synthesize editing;
@synthesize changed;
@synthesize editButton,dateLBL;
@synthesize info,currentNote;

//NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//formatter.dateStyle = NSDateFormatterMediumStyle;
//expireDateField.text = [formatter stringFromDate:expireDate];


- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = kCFDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    //expireDateField.text = [formatter stringFromDate:expireDate];

	self.navigationItem.title = @"Notes";
	editing = NO;
	changed = NO;
	
	NSDictionary    *medlineCitation = info[@"MedlineCitation"];
	NSDictionary    *article         = medlineCitation[@"Article"];
	
    if(article[@"ArtcleTitle"] == nil){
        NSDictionary *journal  = article[@"Journal"];
        NSString     *jTitle   = journal[@"Title"];
        NSString     *theTitle = @"No Title Listed";
        
        if (journal != nil){
            if (jTitle != nil){
                theTitle = jTitle;
            }
        }
        
        noteTitle.text  = theTitle;
    } else {
        noteTitle.text  = article[@"ArticleTitle"];
    }
    currentNote     = [NSMutableDictionary dictionary];
    
    if (info[@"notes"] != nil){
        currentNote[@"date"] = info[@"notes"][@"date"];
        currentNote[@"text"] = info[@"notes"][@"text"];
    } else {
        currentNote[@"date"] = [NSDate date];
        currentNote[@"text"] = @"";
    }
    
    self.dateLBL.text = [formatter stringFromDate:currentNote[@"date"]];
    self.notes.text = currentNote[@"text"];
    
	editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit",@"")
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(toggleEditing:)];
	
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if (currentNote == nil){
        currentNote = [NSMutableDictionary dictionary];
        currentNote[@"date"] = [NSDate date];
    }
    currentNote[@"text"] = notes.text;
    
    if ([self noteChanged]){
        if(delegate) {
            NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
            if (currentNote == nil){
                currentNote = [NSMutableDictionary dictionary];
            }
            currentNote[@"date"] = [NSDate date];
            newInfo[@"notes"]            = currentNote;
            
            [delegate updateBookmarkInfo:newInfo];
        }
    }
}

-(BOOL)noteChanged{
    
    NSDictionary *origianlNote = info[@"notes"];
    
    if ((origianlNote == nil) && (currentNote != nil)){
        return YES;
    }
    
    if ((origianlNote == nil) && (currentNote == nil)){
        return NO;
    }
   
    if ((origianlNote != nil) && (currentNote == nil)){
        return YES;
    }

    NSString *originalText = origianlNote[@"text"];
//NSDate   *originalDate = origianlNote[@"date"];
    NSString *currentText  = currentNote[@"text"];
 //   NSDate   *currentDate  = currentNote[@"date"];

    if(![originalText isEqualToString:currentText]){
        return YES;
    }
    
//    if(![originalDate isEqualToDate:currentDate]){
//        return YES;
//    }

    return NO;
}

-(IBAction)toggleEditing:(id)sender {
	if(editing) {
		[notes resignFirstResponder];
		[self.navigationController popViewControllerAnimated:YES];
    }   else {
		[notes becomeFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	//changed = YES;
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	editButton.title = @"Save";
	editing = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	editButton.title = @"Edit";
	editing          = NO;

	if(changed) {
		UIAlertView*	alert = [[UIAlertView alloc] initWithTitle:@"Notes"
														message:@"Your note has been saved."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
