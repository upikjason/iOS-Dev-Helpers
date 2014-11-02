//
//  UIView+Transform.h
//  ZoomTable_iPhone
//
//  Created by Nguyen on 11/2/14.
//
//

#import <UIKit/UIKit.h>

@interface UIView(Transform)

-(CGRect)getOriginalFrame;
-(CGPoint)centerOffset:(CGPoint)thePoint;
-(CGPoint)pointRelativeToCenter:(CGPoint)thePoint;
-(CGPoint)newPointInView:(CGPoint)thePoint;
-(CGPoint)newTopLeft;
-(CGPoint)newTopRight;
-(CGPoint)newBottomLeft;
-(CGPoint)newBottomRight;

@end
