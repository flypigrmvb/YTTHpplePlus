//
//  YTTViewController.m
//  YTTHpplePlus
//
//  Created by flypigrmvb on 03/31/2017.
//  Copyright (c) 2017 flypigrmvb. All rights reserved.
//

#import "YTTViewController.h"
#import "TFHpple.h"

@interface YTTViewController ()

@end

@implementation YTTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    NSString *htmlString = @"String with a link <a href=\"http://www.google.com\">This is a link</a> and the end";
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple* doc = [[TFHpple alloc] initWithHTMLData:data];

    TFHppleElement *e = [doc peekAtSearchWithXPathQuery:@"//a"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
