//
//  TrueToneTerminal.m
//
//  AGPLv3 License
//  Created by github.com/aerobounce on 2019/11/18.
//  Copyright © 2019 aerobounce. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <objc/runtime.h>

// MARK: - Helper

static void swizzle(Class class, SEL selector, SEL swizzledSelector) {
    Class selfClass = [NSObject class];
    Method  _Nullable ttViewMethod = class_getInstanceMethod(class, selector);
    Method  _Nullable swizzledMethod = class_getInstanceMethod(selfClass, swizzledSelector);
    method_exchangeImplementations(ttViewMethod, swizzledMethod);
}

@interface NSObject (TrueToneTerminal)
@end

@implementation NSObject (TrueToneTerminal)

// MARK: - Swizzle on +load

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

       // NSLog(@"TrueToneTerminal has been successfully loaded.");
       // NSLog(@"StackTrace: %@", [NSThread callStackSymbols]);

        Class ttViewClass = NSClassFromString(@"TTView");

        swizzle(ttViewClass,
                @selector(adjustedColorWithColor:withBackgroundColor:force:),
                @selector(__adjustedColorWithColor:withBackgroundColor:force:)
                );

        swizzle(ttViewClass,
                @selector(adjustedColorWithRed:green:blue:alpha:withBackgroundColor:force:),
                @selector(__adjustedColorWithRed:green:blue:alpha:withBackgroundColor:force:)
                );
    });
}

// MARK: - Swizzled methods

/// Returns NSColor as it is
- (id)__adjustedColorWithColor:(id)color
           withBackgroundColor:(id)backgroundColor
                         force:(BOOL)force; {
    return color;
}

/// Returns NSColor from RGBA
- (id)__adjustedColorWithRed:(double)r
                       green:(double)g
                        blue:(double)b
                       alpha:(double)a
         withBackgroundColor:(id)backgroundColor
                       force:(BOOL)force; {
    return [NSColor colorWithRed:r green:g blue:b alpha:a];
}

@end
