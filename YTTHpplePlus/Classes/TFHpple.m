//
//  TFHpple.m
//  Hpple
//
//  Created by Geoffrey Grosenbach on 1/31/09.
//
//  Copyright (c) 2009 Topfunky Corporation, http://topfunky.com
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TFHpple.h"
#import "XPathQuery.h"

#import <libxml2/libxml/parser.h>
#import <libxml2/libxml/HTMLparser.h>
#import <libxml2/libxml/tree.h>

@interface TFHpple ()
{
    NSData * data;
    NSString * encoding;
    BOOL isXML;
    
    // XML/HTML
    xmlDocPtr _doc;
    // xmlDocPtr wrapper
    TFDoc* _tfDoc;
}

@end


@implementation TFHpple

@synthesize data;
@synthesize encoding;

- (id)initWithData:(NSData *)theData encoding:(NSString *)theEncoding isXML:(BOOL)isDataXML {
    if (!(self = [super init])) {
        return nil;
    }
    
    data = theData;
    encoding = theEncoding;
    isXML = isDataXML;
    
    /* Load XML document */
    xmlDocPtr doc;
    const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    if (isXML) {
        doc = xmlReadMemory([data bytes], (int)[data length], "", encoded, XML_PARSE_RECOVER);
    } else {
        doc = htmlReadMemory([data bytes], (int)[data length], "", encoded, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    }
    if (doc == NULL) {
        NSLog(@"Unable to parse.");
        return nil;
    }
    _doc = doc;
    
    return self;
}

- (void)dealloc {
    // 销毁xmlDocPtr对象
    if (_doc) {
        xmlFreeDoc(_doc);
    }
    NSLog(@"===TFHpple dealloc===");
}

- (id)initWithData:(NSData *)theData isXML:(BOOL)isDataXML {
    return [self initWithData:theData encoding:nil isXML:isDataXML];
}

- (id)initWithXMLData:(NSData *)theData encoding:(NSString *)theEncoding {
    return [self initWithData:theData encoding:theEncoding isXML:YES];
}

- (id)initWithXMLData:(NSData *)theData {
    return [self initWithData:theData encoding:nil isXML:YES];
}

- (id)initWithHTMLData:(NSData *)theData encoding:(NSString *)theEncoding {
    return [self initWithData:theData encoding:theEncoding isXML:NO];
}

- (id)initWithHTMLData:(NSData *)theData {
    return [self initWithData:theData encoding:nil isXML:NO];
}

+ (TFHpple *) hppleWithData:(NSData *)theData encoding:(NSString *)theEncoding isXML:(BOOL)isDataXML {
    return [[[self class] alloc] initWithData:theData encoding:theEncoding isXML:isDataXML];
}

+ (TFHpple *) hppleWithData:(NSData *)theData isXML:(BOOL)isDataXML {
    return [[self class] hppleWithData:theData encoding:nil isXML:isDataXML];
}

+ (TFHpple *) hppleWithHTMLData:(NSData *)theData encoding:(NSString *)theEncoding {
    return [[self class] hppleWithData:theData encoding:theEncoding isXML:NO];
}

+ (TFHpple *) hppleWithHTMLData:(NSData *)theData {
    return [[self class] hppleWithData:theData encoding:nil isXML:NO];
}

+ (TFHpple *) hppleWithXMLData:(NSData *)theData encoding:(NSString *)theEncoding {
    return [[self class] hppleWithData:theData encoding:theEncoding isXML:YES];
}

+ (TFHpple *) hppleWithXMLData:(NSData *)theData {
    return [[self class] hppleWithData:theData encoding:nil isXML:YES];
}

#pragma mark - ......::::::: private :::::::......

- (TFDoc*)tfDoc {
    if (!_tfDoc) {
        _tfDoc = [TFDoc new];
        _tfDoc.xmlDoc = _doc;
    }
    return _tfDoc;
}

#pragma mark - public

// Returns all elements at xPath.
- (NSArray *)searchWithXPathQuery:(NSString *)xPathOrCSS
{
    NSArray * detailNodes = nil;
    detailNodes = PerformXPathQuery([self tfDoc], xPathOrCSS);
    
    NSMutableArray * hppleElements = [NSMutableArray array];
    for (id node in detailNodes) {
        [hppleElements addObject:[TFHppleElement hppleElementWithNode:node isXML:isXML withEncoding:encoding]];
    }
    return hppleElements;
}

// Returns first element at xPath
- (TFHppleElement *)peekAtSearchWithXPathQuery:(NSString *)xPathOrCSS
{
    NSArray * elements = [self searchWithXPathQuery:xPathOrCSS];
    if ([elements count] >= 1) {
        return [elements objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark - ......::::::: update support :::::::......

/**
 设置或者修改某个元素的属性
 
 @param attr 属性
 @param element 操作的的元素
 */
- (void)setOrUpdateAttribute:(NSDictionary*)attr inElement:(TFHppleElement*)element {
    NSString* query = [NSString stringWithFormat:@"//%@[@%@=%@]", element.tagName, @"p_ytt_id", element.privateId];
    PerformXPathUpdateAttr([self tfDoc], query, attr);
}

/**
 设置或者修改某个元素的内容
 
 @param content 元素内容
 @param element 操作的的元素
 */
- (void)setOrUpdateContent:(NSString*)content inElement:(TFHppleElement*)element{
    NSString* query = [NSString stringWithFormat:@"//%@[@%@=%@]", element.tagName, @"p_ytt_id", element.privateId];
    PerformXPathUpdateContent([self tfDoc], query, content);
}

/**
 删除文档中的某个元素
 
 @param element 操作的元素
 */
- (void)deleteElement:(TFHppleElement*)element {
    NSString* query = [NSString stringWithFormat:@"//%@[@%@=%@]", element.tagName, @"p_ytt_id", element.privateId];
    PerformXPathDeleteNode([self tfDoc], query);
}

/**
 替换文档中的某个元素
 
 @param element 操作的元素
 */
- (void)replaceElement:(TFHppleElement*)element withElement:(NSDictionary*)newElement {
    NSString* query = [NSString stringWithFormat:@"//%@[@%@=%@]", element.tagName, @"p_ytt_id", element.privateId];
    PerformXPathReplaceNode([self tfDoc], query, newElement);
}

#pragma mark - ......::::::: export support :::::::......

- (void)exportToFile {
    NSString* docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString* exportFileName = [docPath stringByAppendingPathComponent:@"export.html"];
    int result = xmlSaveFormatFileEnc(exportFileName.UTF8String, _doc, "UTF-8", 1);
    NSLog(@"save result = %d    exportFileName = %@", result, exportFileName);
}

- (NSString*)exportXmlDoc {
    xmlChar* mem;
    int size;
    xmlDocDumpMemoryEnc(_doc, &mem, &size, "UTF-8");
    NSString *currentNodeContent = [NSString stringWithCString:(const char *)mem                                                           encoding:NSUTF8StringEncoding];
    xmlFree(mem);
    mem = NULL;
    return currentNodeContent;
}

@end
