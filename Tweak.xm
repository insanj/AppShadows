#import "substrate.h"
#import <objc/runtime.h>
#include <stdlib.h>

#define NSStringFromBOOL(given) given?@"YES":@"NO"
#define SHADOW_PADDING 8.f

@interface UIImage (Private)
+(UIImage *)kitImageNamed:(NSString *)name;
@end

/********************* Relevant Forward-Declarations *********************/

@interface SBApplicationIcon : NSObject
@end

@interface SBUserInstalledApplicationIcon : SBApplicationIcon
@end

@interface SBIconView : UIView
+(CGSize)defaultIconSize;
-(CGRect)iconImageFrame;
-(id)_iconImageView;
@end

@interface SBIconViewMap
-(id)mappedIconViewForIcon:(id)icon;
@end

@interface SBIconViewMap (AppShadows)
-(UIView *)addShadowToView:(UIView *)view;
-(UIImage *)addShadowToImage:(UIImage *)image;
@end

/************************** Categorized Classes **************************/

@interface NSObject (AppShadows)
-(int)shadowed;
-(void)interateShadowed;
@end

%hook NSObject
static void * const kShadowedStorageKey = (void*)&kShadowedStorageKey; 

%new -(int)shadowed{
	return [objc_getAssociatedObject(self, kShadowedStorageKey) intValue];
}

%new -(void)interateShadowed{
	int curr = [objc_getAssociatedObject(self, kShadowedStorageKey) intValue];
	objc_setAssociatedObject(self, kShadowedStorageKey, @(++curr), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%end

/************************** Main %hook for Apps **************************/

%hook SBIconViewMap

-(id)mappedIconViewForIcon:(SBApplicationIcon *)icon{
	if(icon != nil)
		return [self addShadowToView:%orig()];

	return %orig();
}

%new -(UIView *)addShadowToView:(UIView *)view{
	UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"AppShadow.png"]];
	CGRect expanded = view.frame;
	expanded.size.height += shadow.frame.size.height + SHADOW_PADDING;
	[shadow setFrame:CGRectMake(0.f, view.frame.size.height + SHADOW_PADDING, expanded.size.width, shadow.frame.size.height)];

	UIView *holder = [[UIView alloc] initWithFrame:expanded];
	[holder addSubview:view];
	[holder addSubview:shadow];
	
	return holder;
}

%new -(UIImage *)addShadowToImage:(UIImage *)image{
	UIImage *shadow = [UIImage kitImageNamed:@"AppShadow.png"];

	UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height + shadow.size.height + SHADOW_PADDING));

	[image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
	[shadow drawInRect:CGRectMake(0, image.size.height + SHADOW_PADDING, shadow.size.width, shadow.size.height) blendMode:kCGBlendModeNormal alpha:1.0];

	UIImage *combined = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return combined;
}

%end