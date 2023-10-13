//
//  InAppWebBrowser.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 10/13/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InAppWebBrowser : UIViewController {
}
@property (nonatomic, weak) IBOutlet	UIWebView		*mainWebView;
@property (nonatomic, weak) IBOutlet	UINavigationBar	*navBar;
@property (nonatomic, weak) IBOutlet	UIToolbar		*toolBar;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem	*backButton;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem	*forwardButton;
@property (nonatomic, weak) IBOutlet	UIBarButtonItem	*refreshButton;
@property (nonatomic, strong) NSString	*destination;

- (IBAction) done:(id)sender;
- (IBAction) back:(id)sender;
- (IBAction) next:(id)sender;
- (IBAction) refresh:(id)sender;

-(void) showControls;

@end
