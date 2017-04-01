//
//  TFDoc.m
//  Pods
//
//  Created by aron on 2017/3/31.
//
//

#import "TFDoc.h"
#import <libxml/tree.h>

@interface TFDoc() {
    xmlDocPtr _doc;
}

@end

@implementation TFDoc

- (void)setXmlDoc:(void*)xmlDoc {
    _doc = xmlDoc;
}

- (void*)xmlDoc {
    return _doc;
}

@end
