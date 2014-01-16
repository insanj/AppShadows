#import "substrate.h"
#import <objc/runtime.h>
#include <stdlib.h>

#define SHADOW_PADDING 2.f

@interface UIImage (Private)
+(UIImage *)kitImageNamed:(NSString *)name;
@end

@interface SBIconListView : UIView
-(void)_layoutIcon:(id)icon atIndex:(unsigned)index createViewNow:(BOOL)now pop:(BOOL)pop;
-(id)icons;
-(BOOL)isDock;
-(void)layoutIconsNow;
-(id)placeIcon:(id)icon atIndex:(unsigned)index moveNow:(BOOL)now pop:(BOOL)pop;
-(void)removeIcon:(id)icon;
-(void)removeIconAtIndex:(unsigned)index;
-(id)viewForIcon:(id)icon;
@end

@interface SBRootIconListView : SBIconListView
-(float)bottomIconInset;
-(float)sideIconInset;
-(float)topIconInset;
@end

@interface UIView (AppShadows)
-(BOOL)shadow;
@end

%hook UIView
static char kAppShadowKey;
%new -(BOOL)shadow{
	if([objc_getAssociatedObject(self, &kAppShadowKey) boolValue])
		return YES;

	objc_setAssociatedObject(self, &kAppShadowKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return NO;
}
%end

%hook SBRootIconListView
-(id)viewForIcon:(id)icon{
	UIView *o = %orig();

	if(![o shadow]){
		UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"AppShadow.png"]];
		[shadow setFrame:CGRectMake(o.frame.origin.x, o.frame.origin.y + o.frame.size.height + SHADOW_PADDING, o.frame.size.width, ceilf(o.frame.size.height / 4.f))];

		CGRect curr = o.frame;
		curr.size.height += shadow.image.size.height + SHADOW_PADDING;
		[o setFrame:curr];
		[o addSubview:shadow];
	}

	return o;
}
%end

/*
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

%end*/