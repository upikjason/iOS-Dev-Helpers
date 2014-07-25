//
//  NSObject+Wrapper.m
//
//  Created by upikjason
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Wrapper.h"

@interface NSObject (Private)

- (void) fillPropertiesWithDictionary:(NSDictionary*)dict forClass:(Class)cls;
- (NSDictionary*) getPropertiesDictionaryOfClass:(Class)cls;

@end

@implementation NSObject (Wrapper)
#pragma mark STATIC
static const char* detailPropertyName_ = "detailPropertyName_";

#pragma mark MAIN

- (void) fillPropertiesWithDictionary:(NSDictionary*)dict
{
    if (!dict || [dict isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    Class cls = [self class];
    [self fillPropertiesWithDictionary:dict forClass:cls];
    
    if ([[cls superclass] isSubclassOfClass:[NSObject class]])
    {
        [self fillPropertiesWithDictionary:dict forClass:[cls superclass]];
    }
}

- (NSDictionary*) getPropertiesDictionary
{
    return [self getPropertiesDictionaryOfClass:[self class]];
}

- (void) setDetail:(id)value forKey:(NSString*)key
{
    NSMutableDictionary* d = objc_getAssociatedObject(self, detailPropertyName_);
    if (!d)
    {
        d = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, detailPropertyName_, d, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [d setObject:value forKey:key];
}

- (id) getDetailOfKey:(NSString*)key;
{
    NSMutableDictionary* d = objc_getAssociatedObject(self, detailPropertyName_);
    if (!d)
    {
        d = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, detailPropertyName_, d, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return [d objectForKey:key];
}

#pragma mark PRIVATE
- (void) fillPropertiesWithDictionary:(NSDictionary*)dict forClass:(Class)cls
{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
//        const char *attr = property_getAttributes(property);
        
        NSString* propName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
//        NSString* propType = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
        
        id v = [dict objectForKey:propName];
        if (v)
        {
            //type-force
//            if ([propType rangeOfString:@"NSString"].location != NSNotFound && )
//                v = [NSString stringWithFormat:@"%@",v];
//            else if ([propType rangeOfString:@"NSNumber"].location != NSNotFound && ![v isKindOfClass:[NSNumber class]])
//                v = [NSNumber numberWithDouble:[v doubleValue]];
            
            //and assign
            [self setValue:v forKey:propName];
        }
    }
    free(properties);
}

- (NSDictionary*) getPropertiesDictionaryOfClass:(Class)cls
{
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString* propName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        id v = [self valueForKey:propName];
        [d setObject:v forKey:propName];
    }
    
    if ([[cls superclass] isSubclassOfClass:[NSObject class]])
    {
        [d addEntriesFromDictionary:[self getPropertiesDictionaryOfClass:[cls superclass]]];
    }
    return d;

}
@end
