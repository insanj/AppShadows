#import "substrate.h"
#import <objc/runtime.h>
#include <stdlib.h>

#define SHADOW_PADDING 0.f

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

-(void)setFrame:(CGRect)frame{

	//if(![newSuperview isKindOfClass:%c(SBDockIconListView)]){
		UIImageView *shadowView = objc_getAssociatedObject(self, &kAppShadowKey);

		if(!shadowView){
			shadowView = [[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"AppShadow.png"]];
			objc_setAssociatedObject(self, &kAppShadowKey, shadowView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			[self addSubview:shadowView];
		}

		[shadowView setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + SHADOW_PADDING, frame.size.width, shadowView.image.size.height)];
		CGRect expanded = frame;
		expanded.size.height = [self iconImageFrame].size.height + shadowView.image.size.height + SHADOW_PADDING;
		%orig(expanded);

	//}
}
%end