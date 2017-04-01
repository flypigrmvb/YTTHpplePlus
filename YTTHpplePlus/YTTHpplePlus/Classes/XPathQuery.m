//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "XPathQuery.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#import "NSString+XMLLibUtil.h"

#pragma mark - ......::::::: 方法声明 :::::::......
NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult,BOOL parentContent);
NSArray *PerformXPathQuery(TFDoc* doc, NSString *query);
id PerformXPathActionTemplate(TFDoc* doc, NSString *query, XPathActionType type, id params);
xmlNodePtr createNode(NSDictionary* params);


#pragma mark - ......::::::: 方法实现 :::::::......


NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult,BOOL parentContent)
{
    NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
    if (currentNode->name) {
        NSString *currentNodeContent = [NSString stringWithCString:(const char *)currentNode->name
                                                          encoding:NSUTF8StringEncoding];
        resultForNode[@"nodeName"] = currentNodeContent;
    }
    
    
    xmlChar *nodeContent = xmlNodeGetContent(currentNode);
    if (nodeContent != NULL) {
        NSString *currentNodeContent = [NSString stringWithCString:(const char *)nodeContent
                                                          encoding:NSUTF8StringEncoding];
        if ([resultForNode[@"nodeName"] isEqual:@"text"] && parentResult) {
            if (parentContent) {
                NSCharacterSet *charactersToTrim = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                parentResult[@"nodeContent"] = [currentNodeContent stringByTrimmingCharactersInSet:charactersToTrim];
                /** Memory leak point release, Prevent memory leak */
                xmlFree(nodeContent);
                /** Memory leak point release, Prevent memory leak */
                return nil;
            }
            if (currentNodeContent != nil) {
                resultForNode[@"nodeContent"] = currentNodeContent;
            }
            /** Memory leak point release, Prevent memory leak */
            xmlFree(nodeContent);
            /** Memory leak point release, Prevent memory leak */
            return resultForNode;
        } else {
            resultForNode[@"nodeContent"] = currentNodeContent;
        }
        xmlFree(nodeContent);
    }
    
    xmlAttr *attribute = currentNode->properties;
    if (attribute) {
        NSMutableArray *attributeArray = [NSMutableArray array];
        while (attribute) {
            NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
            NSString *attributeName = [NSString stringWithCString:(const char *)attribute->name
                                                         encoding:NSUTF8StringEncoding];
            if (attributeName) {
                attributeDictionary[@"attributeName"] = attributeName;
            }
            
            if (attribute->children) {
                NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary, true);
                if (childDictionary) {
                    attributeDictionary[@"attributeContent"] = childDictionary;
                }
            }
            
            if ([attributeDictionary count] > 0) {
                [attributeArray addObject:attributeDictionary];
            }
            attribute = attribute->next;
        }
        
        if ([attributeArray count] > 0) {
            resultForNode[@"nodeAttributeArray"] = attributeArray;
        }
    }
    
    xmlNodePtr childNode = currentNode->children;
    if (childNode) {
        NSMutableArray *childContentArray = [NSMutableArray array];
        while (childNode) {
            NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode,false);
            if (childDictionary) {
                [childContentArray addObject:childDictionary];
            }
            childNode = childNode->next;
        }
        if ([childContentArray count] > 0) {
            resultForNode[@"nodeChildArray"] = childContentArray;
        }
    }
    
    xmlBufferPtr buffer = xmlBufferCreate();
    xmlNodeDump(buffer, currentNode->doc, currentNode, 0, 0);
    NSString *rawContent = [NSString stringWithCString:(const char *)buffer->content encoding:NSUTF8StringEncoding];
    if (rawContent != nil) {
        resultForNode[@"raw"] = rawContent;
    }
    xmlBufferFree(buffer);
    return resultForNode;
}


/**
 返回数据结构：NSArray<NSDictionary<NSString* NSString*>>*
 */
NSArray *PerformXPathQuery(TFDoc* doc, NSString *query)
{
    return PerformXPathActionTemplate(doc, query, XPathActionQuery, nil);
}

int PerformXPathUpdateAttr(TFDoc* doc, NSString *query, NSDictionary* attr)
{
    PerformXPathActionTemplate(doc, query, XPathActionSetOrUpdateAttr, attr);
    return 0;
}

int PerformXPathUpdateContent(TFDoc* doc, NSString *query, NSString* content)
{
    PerformXPathActionTemplate(doc, query, XPathActionSetOrUpdateContent, content);
    return 0;
}

int PerformXPathDeleteNode(TFDoc* doc, NSString *query)
{
    PerformXPathActionTemplate(doc, query, XPathActionDelete, nil);
    return 0;
}

int PerformXPathReplaceNode(TFDoc* doc, NSString *query, NSDictionary* attr)
{
    PerformXPathActionTemplate(doc, query, XPathActionReplace, attr);
    return 0;
}

id PerformXPathActionTemplate(TFDoc* doc, NSString *query, XPathActionType type, id params) {
    
    id resultObj = nil;
    
    xmlDocPtr docPtr = doc.xmlDoc;
    
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
    /* Make sure that passed query is non-nil and is NSString object */
    if (query == nil || ![query isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(docPtr);
    if(xpathCtx == NULL) {
        NSLog(@"Unable to create XPath context.");
        return nil;
    }
    
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if(xpathObj == NULL) {
        NSLog(@"Unable to evaluate XPath.");
        xmlXPathFreeContext(xpathCtx);
        return nil;
    }
    
    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    if (!nodes) {
        NSLog(@"Nodes was nil.");
        xmlXPathFreeObject(xpathObj);
        xmlXPathFreeContext(xpathCtx);
        return nil;
    }
    
    // 这边是具体处理的逻辑
    if (type == XPathActionQuery) {
        // 查询
        NSMutableArray *resultNodes = [NSMutableArray array];
        for (NSInteger i = 0; i < nodes->nodeNr; i++) {
            NSDictionary *tmpNodeDictionary = DictionaryForNode(nodes->nodeTab[i], nil,false);
            if (tmpNodeDictionary) {
                NSMutableDictionary* nodeDictionary = [tmpNodeDictionary mutableCopy];
                // 添加自定义的属性值，用户后面对Node的修改
                if (!tmpNodeDictionary[@"p_ytt_id"]) {
                    CFAbsoluteTime t1 = CFAbsoluteTimeGetCurrent();
                    NSString* timeBaseStr = [NSString stringWithFormat:@"%@", @(t1)];
                    xmlSetProp(nodes->nodeTab[i], (const xmlChar *)"p_ytt_id", [timeBaseStr xmlString]);
                    nodeDictionary[@"p_ytt_id"] = timeBaseStr;
                }
                [resultNodes addObject:nodeDictionary];
            }
        }
        resultObj = resultNodes;
    } else if (type == XPathActionSetOrUpdateAttr) {
        // 更新设置属性
        for (NSInteger i = 0; i < nodes->nodeNr; i++) {
            xmlNodePtr currentNode = nodes->nodeTab[i];
            if ([params isKindOfClass:[NSDictionary class]]) {
                [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
                        xmlSetProp(currentNode, [(NSString*)key xmlString], [(NSString*)obj xmlString]);
                    }
                }];
                
            }
        }
    } else if (type == XPathActionSetOrUpdateContent) {
        // 更新设置内容
        for (NSInteger i = 0; i < nodes->nodeNr; i++) {
            xmlNodePtr currentNode = nodes->nodeTab[i];
            if ([params isKindOfClass:[NSString class]]) {
                xmlNodeSetContent(currentNode, [(NSString*)params xmlString]);
            }
        }
    } else if (type == XPathActionDelete) {
        // 删除查找到的节点
        for (NSInteger i = 0; i < nodes->nodeNr; i++) {
            xmlNodePtr currentNode = nodes->nodeTab[i];
            xmlReplaceNode(currentNode, NULL);
        }
    } else if (type == XPathActionReplace) {
        // 替换节点
        if ([params isKindOfClass:[NSDictionary class]]) {
            for (NSInteger i = 0; i < nodes->nodeNr; i++) {
                xmlNodePtr currentNode = nodes->nodeTab[i];
                xmlNodePtr newNode = createNode(params);
                xmlReplaceNode(currentNode, newNode);
                // xmlFreeNode(newNode);
            }
        }
    }
    
    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    
    return resultObj;
}


xmlNodePtr createNode(NSDictionary* params) {
    NSString* tagName = params[@"tagName"];
    NSDictionary* props = params[@"props"];
    NSArray* childs = params[@"childs"];
    
    // 新建节点
    xmlNodePtr parentNode = xmlNewNode(NULL, [(NSString*)tagName xmlString]);
    // 设置属性
    if ([props isKindOfClass:[NSDictionary class]]) {
        [props enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            xmlSetProp(parentNode, [(NSString*)key xmlString], [(NSString*)obj xmlString]);
        }];
    }
    for (NSDictionary* nodeParams in childs) {
        xmlNodePtr childNode = createNode(nodeParams);
        xmlAddChild(parentNode, childNode);
        // xmlFreeNode(childNode);
    }
    return parentNode;
}

#pragma mark - ......::::::: public :::::::......

NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query) {
    return PerformHTMLXPathQueryWithEncoding(document, query, nil);
}

NSArray *PerformHTMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding)
{
    xmlDocPtr docPtr;
    
    /* Load XML document */
    const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    
    docPtr = htmlReadMemory([document bytes], (int)[document length], "", encoded, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    if (docPtr == NULL) {
        NSLog(@"Unable to parse.");
        return nil;
    }
    
    TFDoc* doc = [TFDoc new];
    doc.xmlDoc = docPtr;
    
    NSArray *result = PerformXPathQuery(doc, query);
    xmlFreeDoc(docPtr);
    
    return result;
}

NSArray *PerformXMLXPathQuery(NSData *document, NSString *query) {
    return PerformXMLXPathQueryWithEncoding(document, query, nil);
}

NSArray *PerformXMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding)
{
    xmlDocPtr docPtr;
    
    /* Load XML document */
    const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    
    docPtr = xmlReadMemory([document bytes], (int)[document length], "", encoded, XML_PARSE_RECOVER);
    
    if (docPtr == NULL) {
        NSLog(@"Unable to parse.");
        return nil;
    }
    
    TFDoc* doc = [TFDoc new];
    doc.xmlDoc = docPtr;

    NSArray *result = PerformXPathQuery(doc, query);
    xmlFreeDoc(docPtr);
    
    return result;
}
