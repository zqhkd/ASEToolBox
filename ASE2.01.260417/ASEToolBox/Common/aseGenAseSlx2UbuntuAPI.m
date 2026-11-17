function aseGenAseSlx2UbuntuAPI(prjPath,modelSrcFolder,modelIncFolder, modelName)
    % model step size
    rtStepsize = str2double(get_param(gcs, "FixedStep"));

    %% generate Ase2SlxAPI h file
    fid = fopen(fullfile(modelIncFolder, 'AseSlx2UbuntuSysAPI.h'),'w');
    fprintf(fid, ['#include "' modelName '.h"\n']);
    fprintf(fid, '#include "AseSysCommon.h"\n\n');

    fprintf(fid, ['#define STEP_SIZE ' num2str(rtStepsize) '\n']);
    fprintf(fid, ['#define ModelObj ' modelName '_M\n']);
    fprintf(fid, ['#define rtDoStep() ' modelName '_step()\n']);
    fprintf(fid, ['#define rtInitialize() ' modelName '_initialize()\n']);
        % 添加查找MainBoard板卡驱动模块的程序，分开编写是为了保持程序兼容性
    res = find_system(gcs, 'FunctionName','initXComAPI');     % 模型中是否存在initXComAPI模块
    if ~isempty(res)   % 若存在则生成对应宏，否则不生成
        fprintf(fid, '#define __SYS_COM_LIB__\n');
    end

    fprintf(fid,'\nextern char g_sAseToolBoxVersion[8],g_sModelName[120],g_sModelVersion[8];\n');
    fprintf(fid,'extern float ASE_SYSTEM_MAIN_VER,ASE_SYSTEM_DATE_VER,g_iSimulinkStepByms;\n');
    fprintf(fid,'extern uint32_t ASE_SYSTEM_SN_ID;\n');

    fclose(fid);
   %% generate Ase2SlxAPI c file
    rtStepsizeByms = rtStepsize * 1000;   % sec to msec
    strModelName = fullfile(pwd,modelName);
    strModelName = [strModelName,'.slx'];
    strModelName = strrep(strModelName,'\','\\');
    sModelVersion = get_param(gcs, 'ModelVersion');
    sAseToolboxVersion = Simulink.MDLInfo('ASEToolBox').ModelVersion;

    infTempFile =  fullfile(prjPath,'\ASEToolBox\ASEHostSystem.inf');      % 获取ASEHostSystem.inf系统配置文件
    fid = fopen(infTempFile,'r');
    infCont = fread(fid,'*char')';   % 最后的'为转置符号，它将列变量变成行变量
    fclose(fid);

    initStr = ['    strcpy(g_sAseToolBoxVersion,"' sAseToolboxVersion '");'...
           newline '    strcpy(g_sModelName,"' strModelName '");'...
           newline '    strcpy(g_sModelVersion,"' sModelVersion '");'...
           newline ...
           newline ' ' infCont ...
           newline ...
           newline '    g_iSimulinkStepByms = ' num2str(rtStepsizeByms) ';'];

    fid = fopen(fullfile(modelSrcFolder, 'AseSlx2UbuntuSysAPI.c'),'w');
    fprintf(fid, '#include "AseSlx2UbuntuSysAPI.h"\n\n');
    fprintf(fid,'char g_sAseToolBoxVersion[8],g_sModelName[120],g_sModelVersion[8];\n');
    fprintf(fid,'float ASE_SYSTEM_MAIN_VER,ASE_SYSTEM_DATE_VER,g_iSimulinkStepByms;\n');
    fprintf(fid,'uint32_t ASE_SYSTEM_SN_ID;\n');
    fprintf(fid,'\nvoid initializeMode()\n{\n');
    fprintf(fid, '%s\n}\n', initStr);
    fclose(fid);
end
