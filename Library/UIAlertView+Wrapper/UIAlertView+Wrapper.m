//
//  UIAlertView+Wrapper.m
//
//  Created by upikjason on 7/23/14.
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertView+Wrapper.h"
#import "NSObject+Wrapper.h"

@implementation UIAlertView (Wrapper)

#pragma mark STATIC

+ (void) showWithTitle:(NSString*)title andMsg:(NSString*)msg
{
    [[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

+ (void) showWithTitle:(NSString*)title andMsg:(NSString*)msg andOnYes:(void(^)(void))onYes andOnNo:(void(^)(void))onNo
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    if (onYes) [d setObject:[onYes copy] forKey:@"onAccept"];
    if (onNo) [d setObject:[onNo copy] forKey:@"onCancel"];

    [alert setDetail:d forKey:@"Blocks"];
    [alert show];
}

+ (void) showWithTitle:(NSString*)title andMsg:(NSString*)msg andOnOK:(void(^)(void))onOK andOnCancel:(void(^)(void))onCancel
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    if (onOK) [d setObject:[onOK copy] forKey:@"onAccept"];
    if (onCancel) [d setObject:[onCancel copy] forKey:@"onCancel"];
    
    [alert setDetail:d forKey:@"Blocks"];
    [alert show];
}

#pragma mark STATIC SELECTORS
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary* d = [alertView getDetailOfKey:@"Blocks"];
    if (buttonIndex == 0)
    {
        void(^func)(void) = [d objectForKey:@"onCancel"];
        if (func) func();
    }
    else
    {
        void(^func)(void) = [d objectForKey:@"onAccept"];
        if (func) func();
    }
}
@end
