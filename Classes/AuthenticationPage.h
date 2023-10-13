//
//  AuthenticationPage.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/21/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AuthenticationPage : UIViewController {
}
@property (nonatomic, weak)		IBOutlet	UIWebView*	myWebView;
@property (nonatomic, strong)		IBOutlet	UIView*				busy;
@property (nonatomic, strong)		NSData*		html;
@property (nonatomic, strong)		id			delegate;
@property (nonatomic, strong)		NSString*	formName;
@property (nonatomic, strong)		NSString*	action;
@property (nonatomic, strong)		NSString*	method;



-(void)kickStartAuthentication;
@property (NS_NONATOMIC_IOSONLY, getter=getFormElements, readonly, copy) NSMutableArray *formElements;
-(BOOL) fillFormElements:(NSMutableArray*)loginInfo;
-(BOOL) sendLoginForm:(NSArray*) loginInfo;
- (void) popLater:(NSTimer*)timer;

@end
