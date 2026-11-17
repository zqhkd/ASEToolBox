/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: uartDemo.c
 *
 * Code generated for Simulink model 'uartDemo'.
 *
 * Model version                  : 6.4
 * Simulink Coder version         : 25.2 (R2025b) 28-Jul-2025
 * C/C++ source code generated on : Fri Apr 17 22:07:55 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Intel->x86-64 (Linux 64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "uartDemo.h"
#include "rtwtypes.h"
#include "uartDemo_capi.h"
#define SEND_PORT0                     9090
#define BUFFER_SIZE0                   12
#define LOCAL_IP0                      "192.168.0.7"
#define LOCAL_PORT0                    8080

/* Exported data definition */

/* Data with Exported storage */
uint8_T uartDemo_UDXComIn[12];         /* '<Root>/UDXComIn' */

/* Real-time model */
static RT_MODEL_uartDemo_T uartDemo_M_;
RT_MODEL_uartDemo_T *const uartDemo_M = &uartDemo_M_;
int sockfd_sd0;
char buffer_sd0[BUFFER_SIZE0];
struct sockaddr_in sendaddr0, local_addr0;
int reuse_permission = 1;
int opt = 1;
ssize_t bytes_read;                    // 接收到数据的字节数前一半

/* Model step function */
void uartDemo_step(void)
{
  /* S-Function (UDPSend_sfcn): '<Root>/UDP_Send' */
  memcpy(buffer_sd0, &uartDemo_UDXComIn[0], BUFFER_SIZE0);
  if (sendto(sockfd_sd0, buffer_sd0, BUFFER_SIZE0, 0, (const struct sockaddr *)
             &sendaddr0, sizeof(sendaddr0)) < 0) {
    perror("sendto failed");
    exit(EXIT_FAILURE);
  }

  /* S-Function (readUDXComAPI): '<Root>/UDXComIn' */
  read_data_from_tty("/dev/ttyUSB0", &uartDemo_UDXComIn[0], 12);
}

/* Model initialize function */
void uartDemo_initialize(void)
{
  /* Registration code */

  /* Initialize DataMapInfo substructure containing ModelMap for C API */
  uartDemo_InitializeDataMapInfo();

  /* Start for S-Function (UDPSend_sfcn): '<Root>/UDP_Send' */

  // 开始生成UDPSend相关程序....,  Modified by ZQingHua 20250915

  // 定点单播
  sockfd_sd0 = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd_sd0 < 0) {
    perror("socket creation failed");
    exit(EXIT_FAILURE);
  }

  setsockopt(sockfd_sd0, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt));// 允许不同socket绑定到相同的端口上

  // 设置本机地址信息
  memset(&local_addr0, 0, sizeof(local_addr0));
  local_addr0.sin_family = AF_INET;
  local_addr0.sin_addr.s_addr = inet_addr(LOCAL_IP0);
  local_addr0.sin_port = htons(LOCAL_PORT0);

  // 单播模式，必须绑定本地IP地址和端口。UDPSend_sfcn生成
  if (bind(sockfd_sd0, (struct sockaddr *)&local_addr0, sizeof(local_addr0)) < 0)
  {
    printf("unicast send local socked bind error!\n");
    perror("bind failed");
    close(sockfd_sd0);
    exit(EXIT_FAILURE);
  }

  // 获取套接字的当前状态，UDPSend_sfcn生成
  int flags_0 = fcntl(sockfd_sd0, F_GETFL, 0);
  if (flags_0 == -1) {
    perror("fcntl get send flags_0 failed");
    exit(EXIT_FAILURE);
  }

  // 将套接字设置为非阻塞模式，UDPSend_sfcn生成
  if (fcntl(sockfd_sd0, F_SETFL, flags_0 | O_NONBLOCK) == -1) {
    perror("fcntl set flags_0 failed");
    exit(EXIT_FAILURE);
  }

  // 设置远程机地址信息
  memset(&sendaddr0, 0, sizeof(sendaddr0));
  sendaddr0.sin_family = AF_INET;
  sendaddr0.sin_port = htons(9090);    // 设置端口号
  sendaddr0.sin_addr.s_addr = inet_addr("192.168.0.2");// 设置单播目的IP地址

  // 结束UDPRecv代码生成....,  Modified by ZQingHua 20250915

  /* Start for S-Function (readUDXComAPI): '<Root>/UDXComIn' */
  init_serial_tty_frameHead("/dev/ttyUSB0",460800,8,1,1, 1, 12, 43605U);
}

/* Model terminate function */
void uartDemo_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
