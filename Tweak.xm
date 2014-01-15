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

@interface SBIconViewMap
-(id)mappedIconViewForIcon:(id)icon;
@end

@interface SBIconImageView : UIImageView
@end

@interface SBFolderIconImageView : SBIconImageView
@end

@interface SBIconView : UIView
+(CGSize)defaultIconSize;
-(CGRect)iconImageFrame;
-(id)_iconImageView;
@end

@interface SBIconView (AppShadows)
-(UIView *)addShadowToView:(UIView *)view;
-(SBFolderIconImageView *)addShadowToImageView:(SBFolderIconImageView *)imageView;
@end

/************************** Main %hook for Apps **************************/

%hook SBIconView
-(CGRect)iconImageFrame{
	CGRect expanded = %orig();
	expanded.size.height += 50.f;
	return expanded;
}

-(SBFolderIconImageView *)_iconImageView{
	return [self addShadowToImageView:%orig()];
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

%new -(UIImageView *)addShadowToImageView:(UIImageView *)imageView{
	UIImage *shadow = [UIImage kitImageNamed:@"AppShadow.png"];

	UIGraphicsBeginImageContext(CGSizeMake(imageView.frame.size.width, imageView.frame.size.height + shadow.size.height + SHADOW_PADDING));

	[imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
	[shadow drawInRect:CGRectMake(0, imageView.frame.size.height + SHADOW_PADDING, shadow.size.width, shadow.size.height) blendMode:kCGBlendModeNormal alpha:1.0];

	UIImage *combined = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return [[UIImageView alloc] initWithImage:combined];
}

%end