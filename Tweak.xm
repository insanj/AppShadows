#import "substrate.h"
#import <objc/runtime.h>
#include <stdlib.h>

#define SHADOW_PADDING 8.f

@interface UIImage (Private)
+(UIImage *)kitImageNamed:(NSString *)name;
@end

@interface SBIconView : UIView
@property (nonatomic, retain, readonly) UIImageView *_iconImageView;
@end

@interface SBIconView (AppShadows)
-(BOOL)_appShadows_needsShadow;
@end

static char kAppShadowKey;

%hook SBIconView
-(void)prepareForRecycling{
	objc_setAssociatedObject(self, &kAppShadowKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	%orig();
}

%new -(BOOL)_appShadows_needsShadow{
	if([objc_getAssociatedObject(self, &kAppShadowKey) boolValue])
		return NO;

	objc_setAssociatedObject(self, &kAppShadowKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return YES;
}
%end

%hook SBRootIconListView
-(SBIconView *)viewForIcon:(id)icon{
	SBIconView *iconView = %orig();

	if([iconView _appShadows_needsShadow]){
		UIView *containerView = iconView._iconImageView.superview;
		CGRect frame = containerView.frame;

		UIImageView *shadowView = [[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"AppShadow.png"]];
		[shadowView setFrame:CGRectMake(0.f, iconView._iconImageView.frame.size.height + SHADOW_PADDING, frame.size.width, shadowView.frame.size.height)];
		[containerView insertSubview:shadowView belowSubview:iconView._iconImageView];
	}

	return iconView;
}
%end
