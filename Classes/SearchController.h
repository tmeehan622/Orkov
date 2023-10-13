//
//  SearchController.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/9/09.
//  Copyright 2009 The Frodis Co.. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import "Pubmed_ExperimentAppDelegate.h"


@interface SearchController : UIViewController<UITextFieldDelegate> {
}

@property (nonatomic, weak) IBOutlet UIView 	*contentView;
@property (nonatomic, weak) IBOutlet UITableView	*advancedView;
@property (nonatomic, weak) IBOutlet UIView		*advancedViewContainer;
@property (nonatomic, weak) IBOutlet UITextField	*searchBox;
@property (nonatomic, weak) IBOutlet UITextField	*utilityBox;
@property (nonatomic, assign) BOOL			shouldSearch;	
@property (nonatomic, assign) BOOL			isEditingWithPicker;
@property (nonatomic, assign) BOOL			weAreANDingTerms;
@property (nonatomic, assign) int			historySearchIndex;
@property (nonatomic, assign) BOOL			isAdvanced;
@property (nonatomic, strong) NSArray							*segmentHeadings;
@property (nonatomic, strong) UIBarButtonItem					*cancelButton;
@property (nonatomic, strong) UIBarButtonItem					*searchButton;
@property (nonatomic, strong) NSDictionary						*advancedSearchOptions;
@property (nonatomic, strong) NSString							*allFields;
@property (nonatomic, strong) NSMutableArray					*searchHistory;
@property (nonatomic, strong) NSMutableArray					*limitFields;
@property (nonatomic, strong) NSMutableArray					*searchFields;
@property (nonatomic, strong) NSDictionary						*indexField;
@property (nonatomic, strong) UIAlertView						*andOrAlert;
@property (nonatomic, strong) UITextField						*activeBox;

- (IBAction) doBasicSearch:(id)sender;
- (IBAction) doAdvancedSearch:(id)sender;
- (IBAction) doSettings:(id)sender;
- (void) doHistorySearch:(int)row;
- (BOOL) screenSearch:(NSString*)searchString;

- (void) addSearchField:(NSDictionary*)info;
- (void) replaceSearchField:(NSDictionary*)oldInfo with:(NSDictionary*)newInfo;
- (void) removeTerm:(NSDictionary*)oldInfo;

- (void) replaceLimits:(NSArray*)newLimits;

- (void) removeIndexTerm:(NSDictionary*)oldInfo;
- (void) replaceTermField:(NSDictionary*)newInfo;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *assembleAdvancedSearchCriteria;
- (NSString*) groupTheseTogether:(NSArray*)tags withType:(NSString*)type operation:(NSString*)operation;

- (void) adjustNavBar;
- (void) loadHistory;
- (void) saveHistory;
- (void) clearHistory;

- (void) addToHistoryListner:(NSNotification*)notification;
- (void) addToHistory:(NSDictionary*)searchDictionary;
- (void) _addToHistory:(NSDictionary*)searchDictionary;

@end
