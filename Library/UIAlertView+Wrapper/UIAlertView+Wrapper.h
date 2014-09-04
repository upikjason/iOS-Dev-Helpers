//
//  UIAlertView+Wrapper.h
//
//  Created by upikjason on 7/23/14.
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertView (Wrapper)

#pragma mark STATIC
+ (void) showWithTitle:(NSString*)title andMsg:(NSString*)msg; //OK only
+ (void) showWithTitle:(NSString*)title andMsg:(NSString*)msg andOnYes:(void(^)(void))onYes andOnNo:(void(^)(void))onNo;
+ (void) showWithTitle:(NSString*)title andMsg:(NSString*)msg andOnOK:(void(^)(void))onOK andOnCancel:(void(^)(void))onCancel;

@end
