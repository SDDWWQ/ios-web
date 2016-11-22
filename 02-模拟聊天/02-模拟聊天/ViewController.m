//
//  ViewController.m
//  02-模拟聊天
//
//  Created by shadandan on 2016/11/22.
//  Copyright © 2016年 SDD. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ipView;
@property (weak, nonatomic) IBOutlet UITextField *portView;
@property (weak, nonatomic) IBOutlet UITextField *sendView;
@property (weak, nonatomic) IBOutlet UILabel *recvMsgView;
@property(nonatomic,assign)int clientSocket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)connectClick:(id)sender {
    [self connect:self.ipView.text andport:[self.portView.text intValue]];
}
- (IBAction)sendClick:(id)sender {
    self.recvMsgView.text=[self sendAndRecv:self.sendView.text];
}
- (IBAction)closeClick:(id)sender {
    close(self.clientSocket);
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
    addr.sin_port=htons(12345);//存储数据的时候存储方式可能不太一样，网络中传输的都是大尾数据（地址的低位存储值的高位），htons 的用处就是把实际主机内存中的整数存放方式调整成网络字节顺序
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
    //返回的是实际接收的字节个数
    uint8_t buffer[1024];//字符缓冲池
    ssize_t recvCount=recv(self.clientSocket,buffer,sizeof(buffer),0);//直接在终端输入并回车就是服务器给客户端发送数据
    NSData *data=[NSData dataWithBytes:buffer length:recvCount];
    NSString *recvMsg=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return recvMsg;

}



@end
