//
//  SearchFieldEditor.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/16/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldEditorTemplate.h"

@class SearchController;

@interface SearchFieldEditor : FieldEditorTemplate {
}

@property (nonatomic, weak) IBOutlet		UIPickerView    *picker;
@property (nonatomic, weak) IBOutlet		UITextField     *termBox;
@property (nonatomic, weak) IBOutlet		UIButton        *removeButton;
@property (nonatomic, assign) BOOL                            addingNewTerm;
@property (nonatomic, assign) BOOL                            cancelled;
@property (nonatomic, assign) double                          pickerTop;
@property (nonatomic, strong) NSDictionary                    *advancedSearchOptions;
@property (nonatomic, strong) NSDictionary                    *info;
@property (nonatomic, strong) SearchController                *myController;

- (IBAction)deleteSearchTerm:(id) sender;

@end
