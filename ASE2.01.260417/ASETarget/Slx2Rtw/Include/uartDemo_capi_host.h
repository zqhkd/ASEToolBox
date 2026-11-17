#ifndef uartDemo_cap_host_h__
#define uartDemo_cap_host_h__
#ifdef HOST_CAPI_BUILD
#include "rtw_capi.h"
#include "rtw_modelmap.h"

typedef struct {
  rtwCAPI_ModelMappingInfo mmi;
} uartDemo_host_DataMapInfo_T;

#ifdef __cplusplus

extern "C"
{

#endif

  void uartDemo_host_InitializeDataMapInfo(uartDemo_host_DataMapInfo_T *dataMap,
    const char *path);

#ifdef __cplusplus

}

#endif
#endif                                 /* HOST_CAPI_BUILD */
#endif                                 /* uartDemo_cap_host_h__ */

/* EOF: uartDemo_capi_host.h */
