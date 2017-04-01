//
//  NewPageTest.m
//  HppleDemo
//
//  Created by aron on 2017/3/21.
//
//

#import <XCTest/XCTest.h>
#import "TFHpple.h"


#define TEST_DOCUMENT_NAME          @"newspage.html"
#define TEST_DOCUMENT_EXTENSION     @""


@interface NewPageTest : XCTestCase

@property (nonatomic, strong) TFHpple *doc;

@end

@implementation NewPageTest

- (void)setUp {
    [super setUp];

    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *testFileUrl = [testBundle URLForResource:TEST_DOCUMENT_NAME withExtension:TEST_DOCUMENT_EXTENSION];
    NSData * data = [NSData dataWithContentsOfURL:testFileUrl];
    self.doc = [[TFHpple alloc] initWithHTMLData:data];
    
    NSLog(@"=");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testParseImg {
    NSArray *imgs = [self.doc searchWithXPathQuery:@"//img"];
    
    for (TFHppleElement* element in imgs) {
        NSString* raw = element.raw;
        NSString* tagName = element.tagName;
        NSString* content = element.content;
        NSDictionary* attributes = element.attributes;
        
        NSString* src = [element objectForKey:@"src"];
        
    }
    
    [self.doc exportToFile];
    
    NSLog(@"=");
}

- (void)testParseSpecificImage {
    
    // 查找img标签，并且src为制定的值
    NSArray *imgs = [self.doc searchWithXPathQuery:@"//img[@src='http://p1.ifengimg.com/a/2017_06/5c5a53fe4ecdbe8_size16_w371_h274.jpg']"];
    
    for (TFHppleElement* element in imgs) {
        NSString* raw = element.raw;
        NSString* tagName = element.tagName;
        NSString* content = element.content;
        NSDictionary* attributes = element.attributes;
        
        NSString* src = [element objectForKey:@"src"];
        
    }
    
    NSLog(@"=");
}


- (void)testSaveDoc {
    // 使用and连接多个条件查找
    NSArray *imgs = [self.doc searchWithXPathQuery:@"//img[@width='640' and @alt='tripod']"];
    
    for (TFHppleElement* element in imgs) {
        NSString* raw = element.raw;
        NSString* tagName = element.tagName;
        NSString* content = element.content;
        NSDictionary* attributes = element.attributes;
        
        NSString* src = [element objectForKey:@"src"];
        
    }
    
    [self.doc exportToFile];
    
    NSLog(@"=");
}

- (void)testSetAttr {
    NSArray *imgs = [self.doc searchWithXPathQuery:@"//img"];
    
    for (TFHppleElement* element in imgs) {
        NSString* raw = element.raw;
        NSString* tagName = element.tagName;
        NSString* content = element.content;
        NSDictionary* attributes = element.attributes;
        
        NSString* src = [element objectForKey:@"src"];
        
        NSLog(@"==");
    }
    
    // 设置第一个元素的属性
    if (imgs.count > 0) {
        TFHppleElement* element = imgs.firstObject;
        [self.doc setOrUpdateAttribute:@{@"width": @"13131"} inElement:element];
    }
    
    NSString* generatedDoc = [self.doc exportXmlDoc];
    
    NSLog(@"=");
}

- (void)testSetContent {
    NSArray *paragraphes = [self.doc searchWithXPathQuery:@"//p"];
    if (paragraphes.count) {
        TFHppleElement* element = paragraphes.firstObject;
        [self.doc setOrUpdateContent:@"这个是更新替换后的内容" inElement:element];
    }
    
    [self.doc exportXmlDoc];
}

- (void)testRemoveNode {
    NSArray *paragraphes = [self.doc searchWithXPathQuery:@"//p"];
    if (paragraphes.count) {
        TFHppleElement* element = paragraphes.firstObject;
        [self.doc deleteElement:element];
    }
    
    [self.doc exportXmlDoc];
}

@end
