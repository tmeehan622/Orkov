//
//  BackgroundView.m
//  Pubmed Experiment
//
//  Created by Joseph Falcone on 10/11/16.
//
//

#import "BackgroundView.h"

@interface BackgroundView()
{
    BOOL setupComplete;
}
@end

@implementation BackgroundView

-(id)initWithFrame:(CGRect)frame
{
    if(self==[super initWithFrame:frame])
    {
        [self initMyStuff];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self == [super initWithCoder:aDecoder])
    {
        [self initMyStuff];
    }
    return self;
}

-(void)prepareForInterfaceBuilder
{
    [self initMyStuff];
}

-(void)initMyStuff
{
//    if(setupComplete)
//        return;
//    setupComplete = YES;
    
    self.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
//    self.backgroundColor = [UIColor colorWithRed:0.69 green:0.11 blue:0.11 alpha:1.0];
    
    //UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG_Caduceus"]];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG_Watermark"]];
    [self insertSubview:iv atIndex:0];
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    [iv.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = true;
    [iv.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = true;
}

@end
