//
//  ViewController.m
//  01-Socket编程
//
//  Created by shadandan on 2016/11/20.
//  Copyright © 2016年 SDD. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //1.创建socket
    //第一个参数domain 协议族 指定IPv4
    //第二个参数 type Socket的类型 流式socket 数据报socket
    //第三个参数 protocol 协议 TCP
    //返回值 创建成功返回的是socket的描述符，失败-1
    int clientSocket=socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    //2.连接服务器
    //第一个参数 socket的描述符
    //第二个参数 结构体 ip地址和端口
    //第三个参数 结构体的长度 sizeof
    //返回值 成功0 失败 非0
    
    struct sockaddr_in addr;
    addr.sin_family=AF_INET;
    addr.sin_addr.s_addr=inet_addr("127.0.0.1");
    addr.sin_port=htons(12345);//存储数据的时候存储方式可能不太一样，网络中传输的都是大尾数据（地址的低位存储值的高位），htons 的用处就是把实际主机内存中的整数存放方式调整成网络字节顺序
     int result=connect(clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
    if(result!=0){
        NSLog(@"失败");//必须打开netcat模拟服务器和对应的端口才能成功
        return;
    }
    //3.向服务器发送数据
    //第一个参数是socket的描述符
    //第二个参数是要发送的数据内容
    //第三个参数是发送数据的字符数
    //第四个参数一般传0，表示调用执行的方式
    //返回的是实际发送的字节个数
    const char *msg="hello world";
    ssize_t sendCount=send(clientSocket,msg,strlen(msg) , 0);//打开netcat的终端就会收到并显示hello world
    NSLog(@"发送的字节数%zd",sendCount);
    //4.接收服务器返回的数据
    //返回的是实际接收的字节个数
    uint8_t buffer[1024];//字符缓冲池
    ssize_t recvCount=recv(clientSocket,buffer,sizeof(buffer),0);//直接在终端输入并回车就是服务器给客户端发送数据
    NSLog(@"接收的字节数%zd",recvCount);
    //把字节数组转换成字符串
    NSData *data=[NSData dataWithBytes:buffer length:recvCount];
    NSString *recvMsg=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到%@",recvMsg);
    //关闭连接
    close(clientSocket);
}



@end
