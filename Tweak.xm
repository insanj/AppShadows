#import "substrate.h"
#define NSStringFromBOOL(given) given?@"YES":@"NO"

@interface UIImage (Private)
+(UIImage *)kitImageNamed:(NSString *)name;
@end
/*
@interface SBIconScrollView : UIScrollView
@end

@interface SBFolderView <SBIconScrollViewDelegate> {
	SBIconScrollView *_scrollView;
}

@property(readonly, assign, nonatomic) SBIconViewMap *viewMap;
-(id)scrollView;
@end*/

@interface SBIconView : UIView
+(CGSize)defaultIconSize;
-(CGRect)iconImageFrame;
-(id)_iconImageView;
@end

@interface SBIconViewMap{
	NSMapTable *_iconViewsForIcons;
}

+(id)homescreenMap;
+(id)switcherMap;
-(id)initWithIconModel:(id)iconModel delegate:(id)delegate;
-(void)_addIconView:(id)view forIcon:(id)icon;
-(id)_iconViewForIcon:(id)icon;
-(id)iconModel;
-(id)iconViewForIcon:(id)icon;
-(id)mappedIconViewForIcon:(id)icon;
@end

@interface SBIconViewMap (AppShadows)
-(UIView *)addShadowToView:(UIView *)view;
-(UIImage *)addShadowToImage:(UIImage *)image;
@end

%hook SBIconViewMap

/*
-(void)_addIconView:(id)view forIcon:(id)icon{
	NSLog(@"---- addiconview:%@ foricon:%@", view, icon);
	%orig();
}

-(id)_iconViewForIcon:(id)icon{
	NSLog(@"---- _iconviewforicon:%@, return:%@", icon, %orig());
	return %orig();
}

-(id)iconModel{
	NSLog(@"---- iconmodel:%@", %orig());
	return %orig();
}

-(id)iconViewForIcon:(id)icon{
	NSLog(@"---- iconviewforicon:%@, return:%@", icon, %orig());
	return %orig();
}
*/

-(id)mappedIconViewForIcon:(id)icon{
	SBIconView *view = %orig();
	NSLog(@"---- adding to view");
	return [self addShadowToView:view];
}

%new -(UIView *)addShadowToView:(UIView *)view{
	UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"AppShadow.png"]];

	CGRect expanded = view.frame;
	expanded.size.height += shadow.frame.size.height + 10.f;

	[view setFrame:expanded];
	[shadow setFrame:CGRectMake(0.f, view.frame.size.height + 10.f, expanded.size.width, shadow.frame.size.height)];
	[view addSubview:shadow];
	
	return view;
}

%new -(UIImage *)addShadowToImage:(UIImage *)image{
	UIImage *shadow = [UIImage kitImageNamed:@"AppShadow.png"];

	UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height + shadow.size.height + 10.f));

	[image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
	[shadow drawInRect:CGRectMake(0, image.size.height + 10.f, shadow.size.width, shadow.size.height) blendMode:kCGBlendModeNormal alpha:1.0];

	UIImage *combined = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	NSLog(@"[AppShadows] Finished combining icon image (%@) with shadow (this will probably be one of many, sorry for the log spam!)", image);

	return combined;
}
%end

/*
@interface SBUIController{
	UIWindow *_window;
	UIView *_iconsView;
	UIView *_contentView;
}

-(id)init;
-(id)contentView;
@end



%hook SBUIController

-(id)init{
	SBUIController *controller = %orig();
	UIView *iconsView = MSHookIvar<UIView *>(controller, "_iconsView");
	UIView *contentView = [controller contentView];
	NSLog(@"---- init: %@!\n\ticonsView: %@, subviews:%@\n\tcontentView: %@, subviews:%@", controller, iconsView, [iconsView subviews], contentView, [contentView subviews]); 

	//UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"AppShadow.png"]];
	//[shadow setCenter:CGPointMake(view.center.x, view.center.y + view.frame.size.height)];
	//[view addSubview:shadow];
    return %orig();
}

%end*/