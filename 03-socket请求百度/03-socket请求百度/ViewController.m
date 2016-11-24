//
//  ViewController.m
//  03-socket请求百度
//
//  Created by shadandan on 2016/11/22.
//  Copyright © 2016年 SDD. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic,assign)int clientSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //连接百度的服务器
    BOOL result=[self connect:@"119.75.218.70" andport:80];//此处不能写域名，必须写ip地址，在终端中ping www.baidu.com获得ip地址
    if (!result) {
        NSLog(@"连接失败");
        return;
    }
    NSLog(@"连接成功");
    //构造http请求头
    NSString *request=@"GET / HTTP/1.1\r\n"//必须要加换行
                    "Host: www.baidu.com\r\n"
    "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1\r\n"//用户使用的设备，会根据设备展示不同的网页
    "Connection: close\r\n\r\n";//最后一项要加两个\r\n
    //服务器返回的响应头和响应体
    NSString *response=[self sendAndRecv:request];
    //关闭连接 http协议要求，请求结束后要关闭连接
    close(self.clientSocket);
    NSLog(@"%@",response);
    //截取响应体，响应头结束的标志“\r\n\r\n”
    NSRange range=[response rangeOfString:@"\r\n\r\n"];
    NSString *html=[response substringFromIndex:range.location+range.length];
    
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.baidu.com"]];//同时下载www.baidu.com网页相关联的css文件内容和javascript内容，以便于按照格式显示网页内容，并可点击链接进行相应
    
}


//连接
-(BOOL)connect:(NSString *)ip andport:(int)port{
    int clientSocket=socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    self.clientSocket=clientSocket;
    //2.连接服务器
    //第一个参数 socket的描述符
    //第二个参数 结构体 ip地址和端口
    //第三个参数 结构体的长度 sizeof
    //返回值 成功0 失败 非0
    
    struct sockaddr_in addr;
    addr.sin_family=AF_INET;
    addr.sin_addr.s_addr=inet_addr(ip.UTF8String);
    addr.sin_port=htons(port);//存储数据的时候存储方式可能不太一样，网络中传输的都是大尾数据（地址的低位存储值的高位），htons 的用处就是把实际主机内存中的整数存放方式调整成网络字节顺序
    int result=connect(clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
    if(result==0){
        
        return YES;
    }else{
        return NO;
    }
    
}
//发送和接收
-(NSString *)sendAndRecv:(NSString *)str{
    const char *msg=str.UTF8String;
    ssize_t sendCount=send(self.clientSocket,msg,strlen(msg) , 0);//打开netcat的终端就会收到并显示hello world
    NSLog(@"发送的字节数%zd",sendCount);
    //4.接收服务器返回的数据
    
    uint8_t buffer[1024];//字符缓冲池
    
    //服务器返回的数据较大，需要多次循环接收
    NSMutableData *mData=[NSMutableData data];//用于存储接收到的数据
    
    //返回的是实际接收的字节个数
    ssize_t recvCount=recv(self.clientSocket,buffer,sizeof(buffer),0);//直接在终端输入并回车就是服务器给客户端发送数据
    [mData appendBytes:buffer length:recvCount];
    while(recvCount!=0){//当接收到的数据大小是0时表示接收完毕
        recvCount=recv(self.clientSocket,buffer,sizeof(buffer),0);
        [mData appendBytes:buffer length:recvCount];
    }
    
    NSString *recvMsg=[[NSString alloc]initWithData:mData encoding:NSUTF8StringEncoding];
    return recvMsg;
    
}



@end
