//
//  NSString+XMLLibUtil.h
//  mmosite
//
//  Created by aron on 2017/3/31.
//  Copyright © 2017年 qingot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@interface NSString (XMLLibUtil)

- (const xmlChar *)xmlString;

@end
