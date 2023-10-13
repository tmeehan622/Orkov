//
//  EZProxySettings.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 8/11/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EZProxySettings : UIViewController {
}

@property (nonatomic, weak) IBOutlet	UITextField     *ezProxyURL;
@property (nonatomic, weak) IBOutlet	UITextField     *ezProxyUser;
@property (nonatomic, weak) IBOutlet	UITextField     *ezProxyPassword;
@property (nonatomic, weak) IBOutlet	UISwitch        *proxyOnOff;
@property (nonatomic, strong) UITextField                                   *activeBox;

-(IBAction) toggleOnOff:(id) sender;

@end
