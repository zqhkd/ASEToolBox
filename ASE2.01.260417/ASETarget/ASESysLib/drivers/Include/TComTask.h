/******************** (C) COPYRIGHT 2025 ACE Tech Co.*************************
 * 作    者 ： 曾庆华
 * 文 件 名 ： TComTask.h
 * 描    述 ： Ubuntu下串口线程任务调度管理函数库
 * 官    网 ：www.acecreator.com
 * 淘    宝 ：acecreator.taobao.com
 * 公 众 号 ：飞行控制与仿真
*****************************************************************************/
#ifndef __TCom_Task_H__
#define __TCom_Task_H__
#include  <stdio.h>
#include  <stdlib.h>
#include  <stdbool.h>
#include  "SysComLib.h"
#include  "RingBuff.h"

// 串口底层线程任务调度函数
void *ThreadSendTask(void *arg);
void *ThreadRecvTask(void *arg);

// 用户模型串口任务调度函数
void *SlxSendTask(void *);
void *SlxHiTimerSendTask(void *arg);
void *SlxRecvTask(void *);

// 处理slx中的实时串口接收任务
void *SlxRtRecvTask(void *arg);
// 处理slx中的实时串口发送任务
void *SlxRtSendTask(void *arg);

void *TTimerErrorByNSleepTask(void *arg);
void *TTimerErrorByTimerFdTask(void *arg);

// 启动仿真同步信号条件
void startSimuSyncCondition();
// 销毁互斥锁和条件变量（这里实际上程序不会运行到这里，仅为了代码完整性）
void destroySimuMutex();

// 测试验证函数
void TTimerValid(int iFun, int iDelayTime);
void TTimerErrorByNanosleep(int iDelayTime, int iDelayCount);
void TTimerErrorByTimerfd(int iDelayTime, int iDelayCount);

int  TThreadCom(const char* ttyName, unsigned long baudrate, int iSendIntervalMs, int iRcvLen);
int  TSlx2Com(int iFunNo, const char* ttyName, unsigned long baudrate, int iSendIntervalMs, int iRcvLen);

// 等待启动标志，实现线程同步
void syncWaitStartFlag(int idThread);
// 启动多线程任务
void startMultiThreadTask();

// 启动仿真同步信号条件
void startSimuSyncCondition();
 // 等待I/O操作完成
void waitForIoCompletion();  
// 销毁互斥锁和条件变量（这里实际上程序不会运行到这里，仅为了代码完整性）
void destroySimuMutex();

// 阻塞式串口发送任务
void *SlxBlockSendTask(void *arg);

// 阻塞式串口接收任务
void *SlxBlockRecvTask(void *arg);

// 任务函数指针类型
typedef void *(*task_function_t)(void *);
// 创建线程任务并启动运行函数
int create_and_start_task(task_function_t task_func, const char *task_name, int stacksize, int priority, int schedpolicy, void *arg);

extern volatile bool g_bRecvHandled, g_bSendHandled;
#endif