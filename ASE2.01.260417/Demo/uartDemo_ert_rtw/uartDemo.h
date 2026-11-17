/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: uartDemo.h
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

#ifndef uartDemo_h_
#define uartDemo_h_
#ifndef uartDemo_COMMON_INCLUDES_
#define uartDemo_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "unistd.h"
#include "sys/socket.h"
#include "netinet/in.h"
#include "arpa/inet.h"
#include "fcntl.h"
#include "SysComLib.h"
#endif                                 /* uartDemo_COMMON_INCLUDES_ */

#include "uartDemo_types.h"
#include "rtw_modelmap.h"
#define BUFFER_SIZE                    12

/* Macros for accessing real-time model data structure */
#ifndef rtmGetDataMapInfo
#define rtmGetDataMapInfo(rtm)         ((rtm)->DataMapInfo)
#endif

#ifndef rtmSetDataMapInfo
#define rtmSetDataMapInfo(rtm, val)    ((rtm)->DataMapInfo = (val))
#endif

#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Real-time Model Data Structure */
struct tag_RTM_uartDemo_T {
  const char_T * volatile errorStatus;

  /*
   * DataMapInfo:
   * The following substructure contains information regarding
   * structures generated in the model's C API.
   */
  struct {
    rtwCAPI_ModelMappingInfo mmi;
  } DataMapInfo;
};

/* Model entry point functions */
extern void uartDemo_initialize(void);
extern void uartDemo_step(void);
extern void uartDemo_terminate(void);

/* Function to get C API Model Mapping Static Info */
extern const rtwCAPI_ModelMappingStaticInfo*
  uartDemo_GetCAPIStaticMap(void);

/* Exported data declaration */

/* Data with Exported storage */
extern uint8_T uartDemo_UDXComIn[12];  /* '<Root>/UDXComIn' */

/* Real-time Model object */
extern RT_MODEL_uartDemo_T *const uartDemo_M;

/*-
 * These blocks were eliminated from the model due to optimizations:
 *
 * Block '<Root>/Reshape' : Reshape block reduction
 */

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'uartDemo'
 */
#endif                                 /* uartDemo_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
