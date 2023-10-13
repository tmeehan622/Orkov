//
//  TextEditCell.h
//  Pubmed Experiment
//
//  Created by Matthew Mashyna on 7/18/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextEditCell : UITableViewCell {
}
@property (nonatomic, readonly) 	UITextField     *myTextEditField;

- (void) setWidth:(double)w;

@end
