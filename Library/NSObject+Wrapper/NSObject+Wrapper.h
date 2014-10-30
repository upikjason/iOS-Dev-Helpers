//
//  NSObject+Wrapper.h
//
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Wrapper)

- (void) fillPropertiesWithDictionary:(NSDictionary*)dict;
- (NSDictionary*) getPropertiesDictionary;

- (void) setDetail:(id)value forKey:(NSString*)key;
- (id) getDetailOfKey:(NSString*)key;

- (void) removeDetailOfKey:(NSString*)key;
- (void) clearAllDetails;

@end
