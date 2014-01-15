#import "substrate.h"
#define NSStringFromBOOL(given) given?@"YES":@"NO"
#define SHADOW_PADDING 8.f

@interface UIImage (Private)
+(UIImage *)kitImageNamed:(NSString *)name;
@end

/********************* Relevant Forward-Declarations *********************/

@interface SBApplicationIcon
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

@interface SBApplicationIcon (AppShadows)
-(BOOL)shadowed;
-(void)setShadowed:(BOOL)given;
@end

%hook SBApplicationIcon
BOOL shadowed;
-(BOOL)shadowed{
	return shadowed;
}

-(void)setShadowed:(BOOL)given{
	shadowed = given;
}
%end

/************************** Main %hook for Apps **************************/

%hook SBIconViewMap

-(id)mappedIconViewForIcon:(SBApplicationIcon *)icon{
	NSLog(@"--- trying to shadow:%@", icon);
	if(icon == nil || [icon shadowed])
		return %orig();

	[icon setShadowed:YES];
	SBIconView *view = %orig();
	return [self addShadowToView:view];
}

%new -(UIView *)addShadowToView:(UIView *)view{
	UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"AppShadow.png"]];

	CGRect expanded = view.frame;
	expanded.size.height += shadow.frame.size.height + SHADOW_PADDING;

	[view setFrame:expanded];
	[shadow setFrame:CGRectMake(0.f, view.frame.size.height + SHADOW_PADDING, expanded.size.width, shadow.frame.size.height)];
	[view addSubview:shadow];
	
	NSLog(@"[AppShadows] Finished combining icon view (%@) with shadow (this will probably be one of many, sorry for the log spam!)", view);

	return view;
}

%new -(UIImage *)addShadowToImage:(UIImage *)image{
	UIImage *shadow = [UIImage kitImageNamed:@"AppShadow.png"];

	UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height + shadow.size.height + SHADOW_PADDING));

	[image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
	[shadow drawInRect:CGRectMake(0, image.size.height + SHADOW_PADDING, shadow.size.width, shadow.size.height) blendMode:kCGBlendModeNormal alpha:1.0];

	UIImage *combined = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	NSLog(@"[AppShadows] Finished combining icon image (%@) with shadow (this will probably be one of many, sorry for the log spam!)", image);

	return combined;
}

%end