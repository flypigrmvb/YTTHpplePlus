//
//  XPathQuery.h
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

typedef NS_ENUM(NSUInteger, XPathActionType) {
    XPathActionQuery,
    XPathActionSetOrUpdateAttr,
    XPathActionSetOrUpdateContent,
    XPathActionDelete,
    XPathActionReplace,
};


/**
 进行xPath查找
 
 @param document xml/html文档的二进制NSData对象
 @param query xPath条件
 */
NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query);
NSArray *PerformHTMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding);
NSArray *PerformXMLXPathQuery(NSData *document, NSString *query);
NSArray *PerformXMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding);


/**
 xPath查找
 
 @param doc xmlDocPtr文档对象
 @param query xPath条件
 */
NSArray *PerformXPathQuery(xmlDocPtr doc, NSString *query);


/**
 xPath设置或者更新属性
 
 @param doc xmlDocPtr文档对象
 @param query xPath条件
 @param attr 需要更新的节点的属性
 */
int PerformXPathUpdateAttr(xmlDocPtr doc, NSString *query, NSDictionary* attr);


/**
 xPath设置或者更新节点内容
 
 @param doc xmlDocPtr文档对象
 @param query xPath条件
 @param content 需要更新的节点的内容
 */
int PerformXPathUpdateContent(xmlDocPtr doc, NSString *query, NSString* content);


/**
 xPath删除查找到的节点
 
 @param doc xmlDocPtr文档对象
 @param query xPath条件
 */
int PerformXPathDeleteNode(xmlDocPtr doc, NSString *query);

/**
 替换节点
 
 @param doc xmlDocPtr文档对象
 @param query xPath条件
 @param attr 新节点内容
 */
int PerformXPathReplaceNode(xmlDocPtr doc, NSString *query, NSDictionary* attr);
