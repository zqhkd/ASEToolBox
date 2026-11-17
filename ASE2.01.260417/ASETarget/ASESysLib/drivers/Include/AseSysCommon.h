/******************** (C) COPYRIGHT 2025 ACE Tech Co.*************************
 * 作    者 ： 曾庆华
 * 文 件 名 ： AseSysCommon.h
 * 描    述 ： Ubuntu下仿真系统公用函数库
 * 官    网 ：www.acecreator.com
 * 淘    宝 ：acecreator.taobao.com
 * 公 众 号 ：飞行控制与仿真
*****************************************************************************/
#ifndef __Ase_Sys_Common_H__
#define __Ase_Sys_Common_H__
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <termios.h>
#include <poll.h>
#include <sys/ioctl.h>

#include <sys/mman.h>
#include <time.h>
#include <pthread.h>

//#define __LOCAL_DEBUG_MODE__
#define __LOCAL_DEBUG_LOGFILE_MODE__

#define TTY_S_N_CHAR_LEN    30

#define SlxSolveTaskCPUNo        0    // 解算任务模块
#define RemoteMonitorTaskCPUNo   1
#define SlxRecvTaskCPUNo         2    // slx串口接收任务绑定到2#cpu上， cpu核心编号从0开始
#define SlxSendTaskCPUNo         3    // slx串口发送任务绑定到3#cpu上

#define SlxSolveThreadNo        1    // 解算任务线程序号
#define RemoteMonitorThreadNo   2    // 监测任务线程序号
#define SlxRecvThreadNo         3    // slx串口接收任务线程序号
#define SlxSendThreadNo         4    // slx串口发送任务线程序号

#define PARPORT_BASE    0x378         // 并口基地址

// 获取当前精确时间（单调时钟）
#define GET_TIME(ts) clock_gettime(CLOCK_MONOTONIC, &ts)

// 获取当前精确时间（单调时钟）
// 调用示例：struct timespec ts = GetTime()    
#define GetTime() ({ \
    struct timespec ts; \
    clock_gettime(CLOCK_MONOTONIC, &ts); \
    ts; \
})

#define DEBUG_PRINT(fmt, ...) \
    printf("[%s:%d] " fmt, __FILE__, __LINE__, ##__VA_ARGS__)

#ifdef __LOCAL_DEBUG_MODE__
    #define aseDbgPrint(fmt, ...) \
        printf("[%s:%d] " fmt, __FILE__, __LINE__, ##__VA_ARGS__)
#else
    #define aseDbgPrint(fmt, ...)  // 定义为空，不执行任何操作
#endif

// 定义一个结构体来存储用户参数
typedef struct {
    int function;             // 功能选择项
    char device[TTY_S_N_CHAR_LEN];         // 设备名称
    unsigned long baudrate;   // 串口波特率
    int interval;             // 发送帧间隔
    int recvlength;           // 串口接收帧长度
} UserParams;

typedef struct __attribute__((packed)) {
    uint16_t iHead;    // 帧头
    uint16_t iLen;     // 帧长度
    uint32_t iCount;   // 帧计数值
    uint8_t  idSource; // 源地址
    uint8_t  idTar;    // 目的地址
    uint8_t  idFrame;  // 帧类型码，即帧ID号
    float    fSinPara; // 4个字节的浮点数，用于测试的正弦数据：振幅1.5, 偏值0， 频率1rad/s
    float    fCharPara[19];   // 19个4字节的浮点数，共156个uint8测试数据，19个浮点数分别为：1 -- 19
    uint8_t  iChk;     // 8位累加和校验
} TestFrameParams;

typedef union {
    TestFrameParams structData;
    uint8_t  streamBinData[sizeof(TestFrameParams)];
} TestFrameData ;

// 实现参数解析函数
UserParams sProInputUserPara(int argc, char* argv[]);

// 累加和校验操作
uint8_t iCalChkSum(uint8_t *str,uint16_t len);

// 调试等待按键按下
void debugWaitKeyPressed();
void printInfAndWaitKey(char *info);
void printErrorInf(char *info, char *file, int len,char *sdate,char *stime);
// 打印用户配置参数信息
void printUsage(UserParams params);

// 计算时间间隔
long diffDeltTimeNs(struct timespec startTime,struct timespec nowTime);

// 线程安全的纳秒级休眠
void precise_sleep(long ns);

// 系统初始化处理
int initSystemSignal();

// 获取当前仿真时间值，即距离仿真起始点的时间差，单位为秒
double getAseTimerVal();

extern struct timespec g_startTime,g_tmpStartTime;    // 系统仿真开始时间, 当前时刻。测量用临时使用的起始时间
extern uint32_t g_iSimuStepCount;

// 全局退出标志
extern volatile sig_atomic_t g_bExitFlg;
#endif
