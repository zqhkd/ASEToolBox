#include "AseSysCommon.h"
#include "AseSlx2UbuntuSysAPI.h"

#include "SysComLib.h"
#include "RingBuff.h"
#include "TComTask.h"
#include <sys/io.h>

pthread_mutex_t fileMutex;
FILE *logFile;

bool g_bSimuDataIsUpdated = false;

uint32_t g_iSimuStepCount = 0;

void *SlxRtSolveTask(void *arg)
{  
    int num = * (int *)arg;
    //    printf("num = %d\n", num);
    struct timespec  solveStep;
    unsigned char sendbuf[2048];

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(SlxSolveTaskCPUNo, &cpuset);  // 绑定到CPU核心0
   
    syncWaitStartFlag(SlxSolveThreadNo);

    int iCount = 0;
    long period =(long) (STEP_SIZE * 1e9); // 仿真周期，转换为ns单位;
    // printf("period = %ld, step size = %6.3f ms...\n",period, STEP_SIZE*1000);
    // debugWaitKeyPressed();    // 等待按键按下，开始仿真

    clock_gettime(CLOCK_MONOTONIC, &solveStep); // 初始时间点
    g_startTime = solveStep;     // 获取仿真起始时间

    while (1) {
        // 等待到下一个周期的绝对时间点
        clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &solveStep, NULL);

     // 启动仿真同步信号条件
        startSimuSyncCondition();
        
        rtDoStep();
        g_iSimuStepCount++;

        #ifdef __LOCAL_DEBUG_MODE__
            struct timespec now = GetTime();
//            printf(" *** Simu: %ld,%ld,%5.2f, %d \n",now.tv_sec,now.tv_nsec,diffDeltTimeNs(g_startTime,now) * 1e-6, g_iSimuStepCount);
            aseDbgPrint("Simu: %ld,%ld,%5.2f(s), %d \n",now.tv_sec,now.tv_nsec,diffDeltTimeNs(g_startTime,now) * 1e-3, g_iSimuStepCount);
        #endif

        #ifdef __LOCAL_DEBUG_LOGFILE_MODE__
        // 记录仿真线程的数据
            if(logFile!=NULL){
                pthread_mutex_lock(&fileMutex);
                // fprintf(logFile, "%ld,%ld,%5.2f,%d,-1,%d\n",now.tv_sec,now.tv_nsec,diffDeltTimeNs(g_startTime,now) * 1e-6,SlxSolveThreadNo,g_iSimuStepCount);
                fprintf(logFile, "%d, %d,-1\n",g_iSimuStepCount, SlxSolveThreadNo);
                pthread_mutex_unlock(&fileMutex);
            }
        #endif

        g_bSimuDataIsUpdated = false;
        
        //waitForIoCompletion();   // 等待I/O操作完成, 
        // 计算下一个周期的时间点
        solveStep.tv_nsec += period;
        // 处理纳秒溢出
        if (solveStep.tv_nsec >= 1000000000L) {
            solveStep.tv_nsec -= 1000000000L;
            solveStep.tv_sec += 1;
        }
    }
}

/* 用于检测并口外部时钟上升沿的信号中断 */
#ifdef EXTERN_TRIGGER
void *ExternSyncPulseTask(void *arg) {
    int cnt = 0;
    int last_state = 0;

    // 以 root 权限打开并行端口
    int fd0 = open("/dev/parport0", O_RDWR);
    if (fd0 == -1) {
        perror("打开并行端口失败");
        exit(EXIT_FAILURE);
    }

    //确保并行端口被成功占用
    if(ioctl(fd0, PPCLAIM)==-1){
        perror("占用并行端口失败");
        close(fd0);
        exit(EXIT_FAILURE);
    }

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(SlxSolveTaskCPUNo, &cpuset);  // 绑定到CPU核心0
   
    syncWaitStartFlag(SlxSolveThreadNo);   
    clock_gettime(CLOCK_MONOTONIC, &g_startTime); // 初始时间点

    while (1) {
        // 读取数据寄存器
        // unsigned char data_reg = inb(PARPORT_BASE);
        unsigned char data_reg;
        ioctl(fd0, PPRSTATUS, &data_reg);
        
        int current_state = (data_reg >> TRIGGER_BIT) & 0x01;  // 读取外部时钟源的PIN脚的值
        
        #ifdef __LOCAL_DEBUG_MODE__
            printf("T%d,寄存器[%0x]值：%d, 第%d位状态：%d\n",g_iSimuStepCount++, PARPORT_BASE,data_reg,TRIGGER_BIT,current_state);
        #endif
        // 检测上升沿(从0→1)
        if (current_state && !last_state) {
            // printf("Rising edge detected on BIT%d (PIN%d)\n",
            //       TRIGGER_BIT, TRIGGER_BIT + 2);

        // 启动仿真同步信号条件
            startSimuSyncCondition();
            rtDoStep();

            #ifdef __LOCAL_DEBUG_MODE__
                now = GetTime();
                printf(" *** Simu: %ld,%5.2f, %d \n",now.tv_nsec,diffDeltTimeNs(g_startTime,now) * 1e-6, g_iSimuStepCount++);
            #endif

            g_bSimuDataIsUpdated = false;
        }
        last_state = current_state;

        // 设置轮询间隔（需小于信号周期的一半）
        // rt_task_sleep(100000); // 100 μs间隔
        precise_sleep(100000L); // 0.1ms休眠
    }
    // 释放I/O权限
    ioperm(PARPORT_BASE, 3, 0);
}
#endif

void  printttySInf()
{
    printf("数据帧长度指接收串口的帧长度，为-1时表示该串口仅仅为输出串口，不用启动接收线程！\n");
    for (int i = 0; i < g_iPortsNum; i++) {
        printf("   已初始化串口%d, 设备为%s, 接收数据帧长度%ld字节\n",i, g_sPortInf[i].ttyName, g_sPortInf[i].iRecvFrameLen);       
    }
    printf("\n");
}

int ASEModelRun()
{
    int   i = 0;
    char  tmps[100];

#ifdef __LOCAL_DEBUG_LOGFILE_MODE__
    printf("ASEModelRun任务已经启动!\n");

    logFile = fopen("testComFrame.txt","w+");
    if (logFile == NULL) {
        fprintf(stderr, "Error: File pointer is NULL at line %d\n", __LINE__);
        exit(EXIT_FAILURE);
    }
    
    fprintf(logFile, "T_s,T_ns,dTim,idThread,iPortNo,frameNo,deltNo,frameLen,calChk,rwCounter\n");
    // 初始化互斥锁
    if(pthread_mutex_init(&fileMutex,NULL) != 0) {
        perror("Mutex initialization failed");
        fclose(logFile);
    }
#endif

	// printf("sendflg = %d, recvflg = %d\n", SendNewFd, RecvNewFd);
    rtInitialize();

    // 打印已打开串口的信息
    #ifdef __LOCAL_DEBUG_MODE__
        printttySInf();
    #endif

    printInfAndWaitKey("用户模型初始化工作完成！\n");  // 单步调试时观察串口信息是否正常。
    
    int iPortsNum = (int)g_iPortsNum;
    if (create_and_start_task(SlxRtRecvTask, "RT_Recv_Task", 65536, 48, SCHED_FIFO, &iPortsNum) < 0) {   // 由原来堆栈空间32768扩大至65536, V2.01.250425 by zqh
        sprintf(tmps, "✘ 创建实时串口接收任务失败");
        printErrorInf(tmps,__FILE__,__LINE__,__DATE__,__TIME__);    // 打印错误所在的文件、行号、日期和时间
        return EXIT_FAILURE;
    }
    
    if (create_and_start_task(SlxRtSendTask, "RT_Send_Task", 65536, 49, SCHED_FIFO, &iPortsNum) < 0) {  // 由原来堆栈空间32768扩大至65536, V2.01.250425 by zqh
        sprintf(tmps, "✘ 创建实时串口发送任务失败");
        printErrorInf(tmps,__FILE__,__LINE__,__DATE__,__TIME__);
        return EXIT_FAILURE;
    }

#ifdef EXTERN_TRIGGER
    //外部时钟源PIN上升沿检测的任务
    if (create_and_start_task(ExternSyncPulseTask, "Extern_Sync_Task", 0, 55, SCHED_FIFO, &iPortsNum) < 0) {
        sprintf(tmps, "✘ 创建实时串口接收任务失败");
        printErrorInf(tmps,__FILE__,__LINE__,__DATE__,__TIME__);
        return EXIT_FAILURE;
    } 
    printf("外同步模型解算任务已启动！\n");
#else
    // 创建并启动用户模型解算任务线程
    if (create_and_start_task(SlxRtSolveTask,"Model_Solve_Task", 98304, 60, SCHED_FIFO, &i) < 0) {  // 由原来堆栈空间32768扩大至98304, V2.01.250523 by zqh
        perror("✘ 创建用户模型解算任务失败\n");
        return EXIT_FAILURE;
    }   
    printf("内时钟模型解算任务已启动！\n");
#endif

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(SlxSendTaskCPUNo, &cpuset);  // 绑定到CPU核心3
    startMultiThreadTask();
    
    while (!g_bExitFlg) {
        // 主循环逻辑
        // SlxLoopSendTask();
    }

    closeAllOpenComPort();   // 关闭所有串口

    // 销毁互斥锁和条件变量（这里实际上程序不会运行到这里，仅为了代码完整性）
    destroySimuMutex();

#ifdef __LOCAL_DEBUG_LOGFILE_MODE__
    fclose(logFile);   // 关闭测试记录文件
#endif
}

// 在终端上用户运行程序时，可带2~5个参数（如果包括缺省的主程序名称，实际为3~6个）
//    第1个参数为功能选择项，缺省为0；
//          0  -- 正常运行（或不带参数）
//          1  –- 串口收发线程任务测试，ttyS2发送，ttyS3转发测试
//          2~4-- 基于ASEToolBox接口的底层功能函数测试
//          11 -- 连续运行测试，后续延时时间间隔单位以秒为单位
//          12 -- 连续运行测试，后续延时时间间隔单位以微秒为单位（注意：1ms = 1000us）
//          13 -- nanosleep任务调度周期测试
//          14 -- timerfd任务调度周期测试
//          15 -- 基于时间差的
//    当功能为0、1、2时，
//        第2个参数为设备名称，是字符串变量，缺省为/dev/ttyS0。典型值包括/dev/ttyUSB0、/dev/ttyMUE0
//        第3个变量为串口波特率，是一个unsigned long int类型变量，缺省为115200bps，典型值包括9600、19200、38400、57600、115200、230400、460800、921600。
//        第4个变量为发送帧间隔, int类型变量，缺省为1000，单位为毫秒。
//        第5个参数为串口接收帧长度，int类型变量，缺省为10，表示接收帧长度为10字节。
//    当功能为11、12时，
//        第2个参数为延迟时间间隔，int类型变量，缺省为1000，单位为秒或微秒。
//
// 示例1：进行usb串口0收发线程任务测试，向上位机发送字符串“Tn, has been sent char: Hello,Serial!”，并可实时接收长度为20字节的字符串；
//          $ sudo ./asebin 1 /dev/ttyUSB0 921600 1000 20
//
// 示例2：进行基于ASEToolBox接口的底层功能函数测试，ttyS2向上位机发送字符串“Tn, dd char has been sent!”，n,dd为变化数据，分别表示帧序号和字符串长度；
//       并可实时接收长度为10字节的字符串；
//          $ sudo ./asebin 2 /dev/ttyUSB0 460800 1000 10
//
// 示例3：以2秒时间间隔的计时器精度测试；
//        $ sudo ./asebin 11 2  
// 
// 示例4：以1100微秒（即1.1ms）时间间隔的计时器精度测试。
//       $ sudo ./asebin 12 1100
//

int main(int argc,char *argv[])
{
    bool bFaultMode = true;

    // int iScanned, iPara[5] = {0};
    // const char* ttyName = "/dev/ttyUSB0";

    // 调用函数解析参数，并返回结构体变量
    UserParams sPara = sProInputUserPara(argc, argv);
    // 打印参数值，用于验证
    printUsage(sPara);

    debugWaitKeyPressed();

    initSystemSignal();
    
    switch(sPara.function){
        case 1:
            bFaultMode = false;
            if(argc > 2){
                printf("%s串口底层读写线程任务功能测试!\n",sPara.device);
                TThreadCom(sPara.device,sPara.baudrate,sPara.interval,sPara.recvlength);
            } else {
                perror("错误信息: 缺少串口设备名称参数!\n");
                return EXIT_FAILURE;
            }
            break;
        case 2:
        case 3:
        case 4:
            bFaultMode = false;
            if(argc > 2){
                printf("基于ASEToolBox工具箱的%s串口接口函数测试!\n\n",sPara.device);     // 取消注释正常，否则报段错误，停在串口接收任务线程RecvTask进入while循环处
                // printf("Send buff time gap by ms: %d, Recevied Buffer Length:%d!\n",iPara[1],iPara[2]);
                TSlx2Com(sPara.function,sPara.device,sPara.baudrate,sPara.interval,sPara.recvlength);
            } else {
                perror("错误信息: 缺少串口设备名称参数!\n");
                return EXIT_FAILURE;
            }
            break;
        case 11:
        case 12:
            bFaultMode = false;
            if(argc > 2){
                printf("Xenomai实时任务定时器接口函数性能测试!\n\n");
                printf("延迟时间为：%d  %s \n\n", sPara.interval, ((sPara.function == 11) ? "s (Second) " : "us (MicroSecond)"));
                TTimerValid(sPara.function,sPara.interval);
            } 
            break;
        case 13:
            bFaultMode = false;
            if(argc > 2){
                printf("ubuntu22.04.05实时任务nanosleep定时器接口函数性能测试!\n\n");
                printf("调度周期为：%d ms， 循环次数为：%d 次\n\n", sPara.interval,sPara.recvlength);
                TTimerErrorByNanosleep(sPara.interval,sPara.recvlength);
            }
            break;
        case 14:
            bFaultMode = false;
            if(argc > 2){
                printf("ubuntu22.04.05实时任务Timerfd定时器接口函数性能测试!\n\n");
                printf("调度周期为：%d ms， 循环次数为：%d 次\n\n", sPara.interval,sPara.recvlength);
                TTimerErrorByTimerfd(sPara.interval,sPara.recvlength);
            }
            break;
        case 15:
            bFaultMode = false;
            if(argc > 2){
                if(create_and_start_task(TTimerErrorByNSleepTask,"TTimerErrorByNSleepTask",0, 50 , SCHED_FIFO, &sPara) < 0){
                    perror("✘ 创建SlxStepSendTask任务失败\n");
                    return EXIT_FAILURE;   
                }
                printf("ubuntu22.04.05实时nanosleep定时器任务线程性能测试!\n\n");
                printf("调度周期为：%d ms， 循环次数为：%d 次\n\n", sPara.interval,sPara.recvlength);

                pause;
            }
            break;
        case 16:
            bFaultMode = false;
            if(argc > 2){
                if(create_and_start_task(TTimerErrorByTimerFdTask,"TTimerErrorByTFdTask",0, 50 , SCHED_FIFO, &sPara) < 0){
                    perror("✘ 创建SlxStepSendTask任务失败\n");
                    return EXIT_FAILURE;   
                }
                printf("ubuntu22.04.05实时nanosleep定时器任务线程性能测试!\n\n");
                printf("调度周期为：%d ms， 循环次数为：%d 次\n\n", sPara.interval,sPara.recvlength);
                
                pause;
            }
            break;

        default:
            break;
    }
 // 缺省运行用户模型方式
    if(bFaultMode)  ASEModelRun();

    return EXIT_SUCCESS;
}

// /* 用于检测并口外部时钟上升沿的信号中断 */
// #ifdef EXTERN_TRIGGER
// void *ExternSyncPulseTask(void *arg) {
//     int cnt = 0;
//     int last_state = 0;

//     printf("T1\n");
//     // 获取并口I/O端口访问权限
//     if (ioperm(PARPORT_BASE, 3, 1)) {
//         perror("ioperm");
//         return NULL;
//     }

//     printf("T2\n");
//     // 设置外部数据源PIN数据端口为输入模式
//     outb(0x01 << TRIGGER_BIT, PARPORT_BASE + 2);  // 控制寄存器BITX=1


//     cpu_set_t cpuset;
//     CPU_ZERO(&cpuset);
//     CPU_SET(SlxSolveTaskCPUNo, &cpuset);  // 绑定到CPU核心0
   
//     printf("T3\n");
//     syncWaitStartFlag(SlxSolveThreadNo);   
//     clock_gettime(CLOCK_MONOTONIC, &g_startTime); // 初始时间点

//     while (1) {
        
//         // cnt ++;
//         // outb(0x00 << TRIGGER_BIT, PARPORT_BASE); // 调试用数据寄存器的数值设置低电平
//         // if (cnt > 9999)
//         // {
//         //     cnt = 0;
//         //     outb(0x01 << TRIGGER_BIT, PARPORT_BASE); // 调试用数据寄存器的数值设置高电平
//         // }

//         // 读取数据寄存器
//         unsigned char data_reg = inb(PARPORT_BASE);
//         int current_state = (data_reg >> TRIGGER_BIT) & 0x01;  // 读取外部时钟源的PIN脚的值
        
//         printf("T%d,寄存器[%0x]值：%d, 第%d位状态：%d\n",g_iSimuStepCount++, PARPORT_BASE,data_reg,TRIGGER_BIT,current_state);
//         // 检测上升沿(从0→1)
//         if (current_state && !last_state) {
//             // printf("Rising edge detected on BIT%d (PIN%d)\n",
//             //       TRIGGER_BIT, TRIGGER_BIT + 2);

//         // 启动仿真同步信号条件
//             startSimuSyncCondition();
//             rtDoStep();

//             #ifdef __LOCAL_DEBUG_MODE__
//                 struct timespec now = GetTime();
//                 printf(" *** Simu: %ld,%5.2f, %d \n",now.tv_nsec,diffDeltTimeNs(g_startTime,now) * 1e-6, g_iSimuStepCount++);
//             #endif

//             g_bSimuDataIsUpdated = false;
//         }
//         last_state = current_state;

//         // 设置轮询间隔（需小于信号周期的一半）
//         // rt_task_sleep(100000); // 100 μs间隔
//         precise_sleep(100000L); // 0.1ms休眠
//     }
//     // 释放I/O权限
//     ioperm(PARPORT_BASE, 3, 0);
// }
// #endif
