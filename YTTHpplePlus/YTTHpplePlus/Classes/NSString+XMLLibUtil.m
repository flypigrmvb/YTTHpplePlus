//
//  NSString+XMLLibUtil.m
//  mmosite
//
//  Created by aron on 2017/3/31.
//  Copyright © 2017年 qingot. All rights reserved.
//

#import "NSString+XMLLibUtil.h"

@implementation NSString (XMLLibUtil)

- (NSString *)stringByEscapingXML {
    NSMutableString *escapedString = [self mutableCopy];
    
    [escapedString replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:0 range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"'"  withString:@"&apos;" options:0 range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:0 range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:0 range:NSMakeRange(0, [escapedString length])];
    
    return escapedString;
}

- (NSString *)stringByUnescapingXML {
    NSMutableString *unescapedString = [self mutableCopy];
    
    [unescapedString replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&apos;" withString:@"'"  options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:0 range:NSMakeRange(0, [unescapedString length])];
    
    return unescapedString;
}

- (const xmlChar *)xmlString {
    return (const xmlChar *)[[self stringByEscapingXML] UTF8String];
}

@end
