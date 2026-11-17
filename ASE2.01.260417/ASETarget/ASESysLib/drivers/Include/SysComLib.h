/******************** (C) COPYRIGHT 2025 ACE Tech Co.*************************
 * 作    者 ： 曾庆华
 * 文 件 名 ： SysComLib.h
 * 描    述 ： Ubuntu下串口通讯库文件
 * 官    网 ：www.acecreator.com
 * 淘    宝 ：acecreator.taobao.com
 * 公 众 号 ：飞行控制与仿真
*****************************************************************************/
#ifndef __SYS_COM_LIB_H__
#define __SYS_COM_LIB_H__

#include "AseSysCommon.h"
#include "RingBuff.h"

#define MAX_COM_PORT_NUM            8     // 最多使用8个串口
#define MAX_SEND_FRAME_BUFFER_LEN   255
#define MAX_RECV_FRAME_BUFFER_LEN   255

#define NS_PER_MS                   1000000    // 纳秒到毫秒的转换因子1000000
#define OVER_TIME_SAFE_FACTOR       1.2       // 串口通讯超时安全系数

// 每一个串口初始化时的配置信息
struct SerialInfStru {
    // unsigned char      port;
    char     ttyS[TTY_S_N_CHAR_LEN];
    unsigned long   baudrate;
    unsigned char   databit;
    unsigned char   flowcontrol;
    unsigned char   parity;
    unsigned char   stopbit;
};

// 各个串口应用时的配置信息
struct PortInfStru{
    int      fd;          // 串口
    char     ttyName[TTY_S_N_CHAR_LEN];
    size_t   iRecvFrameLen;   // 接收帧长度
    size_t   iSendFrameLen;   // 发送帧长度
    unsigned long   baudrate;  // 波特率，用于计算超时时间
    bool     bSendCompleted;   // 发送完成标志
    bool     bRecvCompleted;   // 接收完成标志
    pthread_mutex_t mutex;       // 互斥锁
};

// 每路串口的接收状态
typedef struct {
    char   buffer[MAX_RECV_FRAME_BUFFER_LEN * 2];    // 接收缓冲区
    size_t total_received;          // 已接收字节数
    bool  is_receiving;              // 是否正在接收帧数据
    struct timespec deadline;        // 终止时间戳
    RingBuffer ring_buffer;         // 无锁环形缓冲区
} RecvSerialPortState;

typedef struct {
    // pthread_mutex_t mutex;    // 互斥锁
    // pthread_cond_t  cond;      // 条件变量
    bool   data_ready;              // 发送帧数据准备好

    char   buffer[MAX_SEND_FRAME_BUFFER_LEN * 2];    // 发送缓冲区
    RingBuffer ring_buffer;         // 无锁环形缓冲区
} SendSerialPortState;

// 串口初始化函数
int init_serial_tty(const char *ttyName, unsigned long int baudrate, int data_bits, char parity, int stop_bits,bool bRecvFlg, size_t iRecvFrameLen);
int init_serial_tty_frameHead(const char *ttyName, unsigned long baudrate, int data_bits, char parity, int stop_bits,bool bRecvFlg, size_t iFrameLen, uint16_t frameHead);
// 串口发送函数: 阻塞发送（确保完整发送）
size_t write_data_to_tty(const char *ttyName, const uint8_t *data, size_t iFrameLen);
/* 串口接收函数：非阻塞式接收(中断式响应) */
size_t read_data_from_tty(const char *ttyName, uint8_t *data, size_t iFrameLen);

void printComSts(int fd);

// 以下两个函数rta_main.c程序会调用
// 串口非阻塞接收（返回实际接收字节数）
size_t SysCom_NonBlockingRecv(int fd, char *buffer, size_t len);
// 帧完整性检查（基于时间戳）：返回有效帧长度，0表示不完整
int16_t SysCom_CheckFrameIntegrity(size_t total_received, size_t frame_size);

// 关闭所有打开串口
void closeAllOpenComPort();
// 清空所有串口的输入输出缓冲区
void emptyBuffAllComPort(int ioMode);   // ioMode = 0 表示清空输入缓冲区； ioMode = 1 表示清空输出缓冲区

// 全局变量定义
extern struct PortInfStru g_sPortInf[MAX_COM_PORT_NUM];
// 全局串口状态数组
extern RecvSerialPortState g_recvSerialPorts[MAX_COM_PORT_NUM];
extern SendSerialPortState g_sendSerialPorts[MAX_COM_PORT_NUM];

extern uint8_t g_iFrameHead[MAX_COM_PORT_NUM][2];  // 每个串口的帧头

extern uint8_t g_iPortsNum;
#endif
