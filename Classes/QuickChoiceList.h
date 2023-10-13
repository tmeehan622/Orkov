//
//  QuickChoiceList.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 9/21/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuickChoiceList : UITableViewController {
	id			referenceObject;
	int			currentSelection;
	NSArray*	referenceList;
	NSString*	referenceKey;
	NSString*	navTitle;
}
@property (nonatomic, retain) id		referenceObject;
@property (nonatomic, retain) NSArray*	referenceList;
@property (nonatomic, retain) NSString*	referenceKey;
@property (nonatomic, retain) NSString*	navTitle;
@property int currentSelection;

@end
