#import "substrate.h"
#import <objc/runtime.h>
#include <stdlib.h>

#define SHADOW_PADDING 2.f

@interface UIImage (Private)
+(UIImage *)kitImageNamed:(NSString *)name;
@end

@interface SBIconView : UIView
+(CGSize)defaultIconSize;
-(CGRect)iconImageFrame;
-(id)_iconImageView;
@end

%hook SBIconView
static char kAppShadowKey;

-(void)willMoveToSuperview:(UIView *)newSuperview{
	%orig();

	if(newSuperview != nil && ![newSuperview isKindOfClass:%c(SBDockIconListView)]){
		UIImage *shadow = [UIImage kitImageNamed:@"AppShadow.png"];
	
		CGRect ordinary = [self iconImageFrame], expanded = ordinary;
		ordinary.origin.x = self.frame.origin.x;
		expanded.size.height += shadow.size.height + SHADOW_PADDING;

		UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadow];
		[shadowView setFrame:CGRectMake(ordinary.origin.x, ordinary.origin.y + ordinary.size.height + SHADOW_PADDING, ordinary.size.width, shadow.size.height)];
		[self setFrame:expanded];

		NSString *shadowString = NSStringFromCGRect(shadowView.frame);
		NSString *shadows = objc_getAssociatedObject(self, &kAppShadowKey);
		if(!shadows){
			shadows = shadowString;
			[self addSubview:shadowView];
		}
		else if([shadows rangeOfString:shadowString].location == NSNotFound){
			shadows = [shadows stringByAppendingString:shadowString];
			[self addSubview:shadowView];
		}

        objc_setAssociatedObject(self, &kAppShadowKey, shadowString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}
/*
-(void)setFrame:(CGRect)frame{
    UIImageView *shadowView = objc_getAssociatedObject(self, &kAppShadowKey);

    if(shadowView)
        [shadowView removeFromSuperview];
    
    CGRect expanded = frame;
    expanded.size.height = [self iconImageFrame].size.height + shadowView.image.size.height + SHADOW_PADDING;
    %orig(expanded);
}*/

%end