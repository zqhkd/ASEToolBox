#include "AseSlx2UbuntuSysAPI.h"

char g_sAseToolBoxVersion[8],g_sModelName[120],g_sModelVersion[8];
float ASE_SYSTEM_MAIN_VER,ASE_SYSTEM_DATE_VER,g_iSimulinkStepByms;
uint32_t ASE_SYSTEM_SN_ID;

void initializeMode()
{
    strcpy(g_sAseToolBoxVersion,"23.21");
    strcpy(g_sModelName,"D:\\ASE\\ASE-2\\ASEProject\\Demo\\uartDemo.slx");
    strcpy(g_sModelVersion,"6.5");

 // 请不要改动左边变量名称，以下字符均为英文方式录入，不要使用中文录入方式; 录入时尽量保持现有缩进格式
    ASE_SYSTEM_MAIN_VER  =  2.01;
    ASE_SYSTEM_DATE_VER  =  260417;   
    ASE_SYSTEM_SN_ID     =  342890;   

    g_iSimulinkStepByms = 1000;
}
