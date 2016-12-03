//
//  ViewController.m
//  04-请求的两种方法对比
//
//  Created by shadandan on 2016/12/3.
//  Copyright © 2016年 SDD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 第一种方式 获取网络数据 无法设置请求头 无法设置超时时长
    NSURL *url=[NSURL URLWithString:@"http://127.0.0.1/demo.json"];
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    
    //第二种方式 获取网络数据
    NSURL *url2=[NSURL URLWithString:@"http://127.0.0.1/demo.json"];
    //NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url2];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url2 cachePolicy:0 timeoutInterval:15];//可以设置缓存策略(枚举类型)和超时间隔
    /*
     NSURLRequestUseProtocolCachePolicy = 0,//使用http的缓存策略
     NSURLRequestReloadIgnoringLocalCacheData = 1,//忽略本地缓存，永远获取最新数据
     NSURLRequestReturnCacheDataElseLoad = 2,//如果有缓存，返回缓存数据，否则重新加载
     NSURLRequestReturnCacheDataDontLoad = 3,//返回缓存数据，没有缓存也不加载
     */
    //设置请求头
    [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601." forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection sendAsynchronousRequest: request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (!connectionError) {//判断连接是否成功
            //判断是否正常接收到服务器返回的数据
            NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
            if (httpResponse.statusCode==200||httpResponse.statusCode==304) {//请求成功
                //获取服务的响应体
                NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",str);
            }else{
                NSLog(@"服务器内部错误");
            }
        }else{
            NSLog(@"erro:%@",connectionError);
        }
        //获取服务的响应体
        NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);

    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
