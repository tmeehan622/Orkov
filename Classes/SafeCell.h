//
//  SafeCell.h
//  Pubmed Experiment
//
//  Created by Tom Meehan on 3/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SafeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *recordNumber;
@property (weak, nonatomic) IBOutlet UILabel *titleLBL;
@property (weak, nonatomic) IBOutlet UILabel *descLBL;

@end

NS_ASSUME_NONNULL_END
