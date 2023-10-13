#import "GradiantView.h"


@implementation GradiantView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGColorRef colors[2];
	CGFloat locations[2] = {0.0, 1.0};
	CGColorSpaceRef colorSpace;

	colorSpace = CGColorSpaceCreateDeviceRGB();
	colors[0] = CGColorRetain([UIColor colorWithHue:221.0/360.0 saturation:0.73 brightness:0.78 alpha:1].CGColor);
	colors[1] = CGColorRetain([UIColor colorWithHue:213/360 saturation:0 brightness:1 alpha:1].CGColor);

	CFArrayRef gradientColors = CFArrayCreate(NULL, (void *)colors, 2, &kCFTypeArrayCallBacks);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, gradientColors, locations);
	CGContextRef ctxt = UIGraphicsGetCurrentContext();
	CGContextDrawLinearGradient(ctxt, gradient, rect.origin, CGPointMake(rect.origin.x, rect.origin.y+rect.size.height), 0);
	CFRelease(gradientColors);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);	
}




@end
