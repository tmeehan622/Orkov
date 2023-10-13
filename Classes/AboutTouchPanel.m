//
//  AboutTouchPanel.m
//  GSA Per Diem
//
//  Created by Matthew Mashyna on 12/16/09.
//  Copyright 2009 The Frodis Co. All rights reserved.
//

#import "AboutTouchPanel.h"

@implementation AboutTouchPanel

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self=[super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

-(void)prepareForInterfaceBuilder
{
    [self setup];
    
    NSBundle *b = [NSBundle bundleForClass:self.class];
    UIImage *image = [UIImage imageNamed:@"Misc_VSLogo" inBundle:b compatibleWithTraitCollection:self.traitCollection];
    logo.image = image;
}

-(void)setup
{
    // Just a quick check to prevent calling this multiple times. Not super safe, but this is a simple class.
    if(label != nil)
        return;
    
    self.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    
    label = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = FALSE;
    label.text = @"Orkov by";
    label.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    
    logo = [UIImageView new];
    logo.translatesAutoresizingMaskIntoConstraints = FALSE;
    logo.image = [UIImage imageNamed:@"Misc_VSLogo"];
    
    [self addSubview:label];
    [self addSubview:logo];
    
    CGFloat paddingH = 8;
    CGFloat paddingV = 8;
    CGFloat spacerH  = 8;
    [logo.topAnchor     constraintEqualToAnchor:self.topAnchor      constant:paddingV].active = TRUE;
    [logo.bottomAnchor  constraintEqualToAnchor:self.bottomAnchor   constant:-paddingV].active = TRUE;
    [logo.rightAnchor   constraintEqualToAnchor:self.rightAnchor    constant:-paddingH].active = TRUE;
    [label.bottomAnchor constraintEqualToAnchor:logo.bottomAnchor   constant:0]       .active = TRUE;
    [label.rightAnchor  constraintEqualToAnchor:logo.leftAnchor     constant:-spacerH].active = TRUE;
}

// This is kind of a dumb way of doing things, but whatevs! Leave it for now.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ABOUT_TOUCH" object:self]];
}

@end
