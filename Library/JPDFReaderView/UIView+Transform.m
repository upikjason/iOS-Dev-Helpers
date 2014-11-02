//
//  UIView+Transform.m
//  ZoomTable_iPhone
//
//  Created by Nguyen on 11/2/14.
//
//

#import "UIView+Transform.h"

@implementation UIView(Transform)

-(CGRect)getOriginalFrame
{
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect originalFrame = self.frame;
    self.transform = currentTransform;
    
    return originalFrame;
}

// helper to get point offset from center
-(CGPoint)centerOffset:(CGPoint)thePoint
{
    return CGPointMake(thePoint.x - self.center.x, thePoint.y - self.center.y);
}

// helper to get point back relative to center
-(CGPoint)pointRelativeToCenter:(CGPoint)thePoint
{
    return CGPointMake(thePoint.x + self.center.x, thePoint.y + self.center.y);
}

// helper to get point relative to transformed coords
-(CGPoint)newPointInView:(CGPoint)thePoint
{
    // get offset from center
    CGPoint offset = [self centerOffset:thePoint];
    // get transformed point
    CGPoint transformedPoint = CGPointApplyAffineTransform(offset, self.transform);
    // make relative to center
    return  [self pointRelativeToCenter:transformedPoint];
}

// now get your corners
-(CGPoint)newTopLeft
{
    CGRect frame = [self getOriginalFrame];
    return [self newPointInView:frame.origin];
}

-(CGPoint)newTopRight
{
    CGRect frame = [self getOriginalFrame];
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    return [self newPointInView:point];
}

-(CGPoint)newBottomLeft
{
    CGRect frame = [self getOriginalFrame];
    CGPoint point = frame.origin;
    point.y += frame.size.height;
    return [self newPointInView:point];
}

-(CGPoint)newBottomRight
{
    CGRect frame = [self getOriginalFrame];
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    point.y += frame.size.height;
    return [self newPointInView:point];
}
@end
