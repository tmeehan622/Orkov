#import <UIKit/UIKit.h>


@interface SegmentedPref : UIViewController {
}
@property (nonatomic,weak) IBOutlet UISegmentedControl   *segmentedControl;
@property (nonatomic,weak) IBOutlet UILabel              *prompt;
@property (nonatomic,strong) NSArray                       *segments;
@property (nonatomic, strong) NSString                      *prefName;
@property (nonatomic, strong) NSString                      *prefTitle;
@end
