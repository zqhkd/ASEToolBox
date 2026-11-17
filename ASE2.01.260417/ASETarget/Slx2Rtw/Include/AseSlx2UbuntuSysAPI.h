#include "uartDemo.h"
#include "AseSysCommon.h"

#define STEP_SIZE 1
#define ModelObj uartDemo_M
#define rtDoStep() uartDemo_step()
#define rtInitialize() uartDemo_initialize()

extern char g_sAseToolBoxVersion[8],g_sModelName[120],g_sModelVersion[8];
extern float ASE_SYSTEM_MAIN_VER,ASE_SYSTEM_DATE_VER,g_iSimulinkStepByms;
extern uint32_t ASE_SYSTEM_SN_ID;
