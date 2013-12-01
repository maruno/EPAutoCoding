/*
 * Copyright 2013 Michel Bouwmans
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "EPAutoCoding.h"

#import <objc/runtime.h>

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation EPAutoCoding

#pragma mark - Public autocoding init/encode

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        for (NSString* propertyName in [self propertyInformationForClass:self.class]) {
            id object = [aDecoder decodeObjectForKey:propertyName];
            [self setValue:object forKey:propertyName];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString* propertyName in [self propertyInformationForClass:self.class]) {
        id value = [self performSelector:NSSelectorFromString(propertyName)];
        [aCoder encodeObject:value forKey:propertyName];
    }
}

#pragma mark - Utility methods
- (NSArray*) propertyInformationForClass:(Class) class {
    unsigned int propertyCount;
    objc_property_t* properties = class_copyPropertyList(class, &propertyCount);

    NSMutableArray* encodableProperties = [[NSMutableArray alloc] initWithCapacity:propertyCount];
    for (NSUInteger i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];

        //Only supporting NSObjects right now
        char* typeIdentifier = property_copyAttributeValue(property, "T");
        if (*typeIdentifier != '@') continue;
        [encodableProperties addObject:[NSString stringWithUTF8String:property_getName(property)]];
    }

    free(properties);

    return encodableProperties;
}

@end