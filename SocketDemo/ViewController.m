//
//  ViewController.m
//  SocketDemo
//
//  Created by wangxiaodong on 05/05/2019.
//  Copyright © 2019 WXD. All rights reserved.
//
/**
 socket演示：（配合mac终端进行演示）
 1.导入头文件
 2.mac终端执行如下命令
 nc -lk 12345 ,12345为端口号
 */

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self socketDemo];
   
}

-(void)socketDemo
{
    //1.创建socket
    /**
     参数：
     domain: 协议域，AF_INET -->IPV4
     type:   socket 类型，SOCK_STREAM(TCP)/SOCK_DGRAM(报文 UDP)
     protocol： IPPROTO_TCP,如果传入0，会自动根据第二个参数，选中合适的协议
     返回值
     socket > 0 就是成功
     */
    int clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    
    //2.连接到服务器
    /**
     参数：
     1.客户端socket
     2.指向数据结构socketaddr的指针，其中包括目的端口和IP地址
     3.结构体数据长度
     0 成功，其他 错误代号
     */
    struct sockaddr_in serverAddr;
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(12345);//端口
    serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");//IP地址
    int connResult = connect(clientSocket, (const struct sockaddr *)&serverAddr, sizeof(serverAddr));
    if (connResult == 0) {
        NSLog(@"连接成功");
    } else {
        NSLog(@"失败 %d",connResult);
        return;
    }
    
    //3.发送数据到服务器
    /**
     参数
     1.客户端socket
     2.发送内容地址
     3.发送内容长度
     4.发送方法标志，一般为0
     返回值
     如果成功，则返回发送的字节数，失败则返回SOCKET_ERROR
     */
    NSString *sendMsg = @"Hello";
    ssize_t sendLen = send(clientSocket, sendMsg.UTF8String, strlen(sendMsg.UTF8String), 0);
    NSLog(@"发送了%ld个字节",sendLen);
    //4.从服务器接受数据
    /**
     参数
     1.客户端socket
     2.接受内容缓冲区地址，需要提前准备
     3.接受内容缓冲区长度
     4.接收方式，0表示阻塞，必须等待服务器返回数据
     返回值
     如果成功，则返回读入的字节数，失败则返回SOCKET_ERROR
     */
    uint8_t buffer[1024];//把控件先准备好
    ssize_t recvLen = recv(clientSocket, buffer, sizeof(buffer), 0);
    NSLog(@"接受了%ld个字节",recvLen);
    
    //获取服务器返回的数据，从缓冲区中读取recvLen 个字节！
    NSData *data = [NSData dataWithBytes:buffer length:recvLen];
    //转换成字符串
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"服务器返回的字符串：%@",str);
    //5.断开连接
    close(clientSocket);
}


@end
