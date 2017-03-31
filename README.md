#YTTHpplePlus

####[YTTHpplePlus](http://git.oschina.net/dhar/YTTHpplePlus/) 是Hpple的扩展，在Hpple的基础上添加了节点的操作功能，原始的Hpple库可以从 [Hpple在GitHub上的链接](https://github.com/topfunky/hpple) 中查看，感谢作者原始的贡献

#####对应功能的使用方法参考单元测试类`NewPageTest`中找到，支持的功能如下：  

- 更新或者添加属性  

```objc
- (void)testSetAttr {
    NSArray *imgs = [self.doc searchWithXPathQuery:@"//img"];
    
    for (TFHppleElement* element in imgs) {
        NSString* raw = element.raw;
        NSString* tagName = element.tagName;
        NSString* content = element.content;
        NSDictionary* attributes = element.attributes;
        
        NSString* src = [element objectForKey:@"src"];
        
    }
    
    // 设置第一个元素的属性
    if (imgs.count > 0) {
        TFHppleElement* element = imgs.firstObject;
        [self.doc setOrUpdateAttribute:@{@"width": @"13131"} inElement:element];
    }
    
    [self.doc exportXmlDoc];
    
    NSLog(@"=");
}
```

- 更新节点的内容，比如`<p>`,`<a>`,`<div>`等标签中的内容  

```objc
- (void)testSetContent {
    NSArray *paragraphes = [self.doc searchWithXPathQuery:@"//p"];
    if (paragraphes.count) {
        TFHppleElement* element = paragraphes.firstObject;
        [self.doc setOrUpdateContent:@"这个是更新替换后的内容" inElement:element];
    }
    
    [self.doc exportXmlDoc];
}
```

- 删除节点，直接点也会对应的从文档中删除  

```objc
- (void)testRemoveNode {
    NSArray *paragraphes = [self.doc searchWithXPathQuery:@"//p"];
    if (paragraphes.count) {
        TFHppleElement* element = paragraphes.firstObject;
        [self.doc deleteElement:element];
    }
    
    [self.doc exportXmlDoc];
}
```