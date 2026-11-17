function [modelSrcFolder, modelIncFolder,modelName, drvBlks] = aseAbtProcess
% /******************** (C) COPYRIGHT 2025 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： abtProcess.m
%  * 描    述 ： 自动生成目标代码程序
%  * 版    本 ： V1.01.250412   初版基本功能程序
%    功    能 ： (1) 用户模型文件slx，生成C代码；
%                (2) 动态生成的IO_Buffer.h文件。
%  * 输入参数：发布方式，分别为
%        获取RTEngine所在路径，曾庆华更改为prjPath,其值类似为D:\ASE\ASE-1,
%        该值是ASEManager软件安装时保存在环境变量ASEProjectPath中的值，其下包括ASEToolBox、ASESysLib、ModelDemo、Compiler等目录，
%        和matlab/simulink相关的目录主要是ASEToolBox目录。其中prjPath目录是变化的，不同用户可能有所不同，而其下的相关目录是固定的。
%        modelPath是包含带后缀slx模型名称的全路径，如: D:\ASE\ASE-1\Demo\TXComC.slx
%          . modelSrcFolder 是模型名称_rtbak_ert_rtw\Src
%          . modelIncFolder 是模型名称_rtbak_ert_rtw\Include
%          . modelRtwDir   是模型代码生成目录，如：D:\ASE\ASE-1\Demo\TXComC_rtbak_ert_rtw
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：飞行控制与仿真
% **********************(C) COPYRIGHT 2025 ACG Tech Group.**********************************************/

    warning off;
    modelName =  bdroot(gcs);
    
    %% 调用slx用户模型自动代码生成功能
    % 检查输入串口是否存在
    drvBlks = struct;
    serialBlk = find_system(bdroot(gcs), 'ReferenceBlock', 'ASEToolBox/COMModule/XComIn');
    if ~isempty(serialBlk)
        drvBlks.XComIn = 1;
    else
        drvBlks.XComIn = 0;
    end
    % 检查输出串口是否存在
    serialBlk = find_system(bdroot(gcs), 'ReferenceBlock', 'ASEToolBox/COMModule/XComOut');
    if ~isempty(serialBlk)
        drvBlks.XComOut = 1;
    else
        drvBlks.XComOut = 0;
    end

    % GE5655 反射内存模块是否存在
    rfmBlk = find_system(bdroot(gcs), 'ReferenceBlock', 'ASEToolBox/RfmModule/RFM2gInit');
    if ~isempty(rfmBlk)
        drvBlks.rfm = 1;
    else
        drvBlks.rfm = 0;
    end
    
    % 用户模型文件所在路径
    srcFolder = [modelName, '_ert_rtw'];
    srcFolder = fullfile(pwd, srcFolder);%代码生成路径
    
    % C API配置
    set_param(modelName,RTWCAPISignals=true);
    set_param(modelName,RTWCAPIParams=true);
    set_param(modelName,RTWCAPIStates=true);
    set_param(modelName,RTWCAPIRootIO=true);
    set_param(modelName, "ProdHWDeviceType", "Intel->x86-64 (Linux 64)");
    set_param(modelName,GenerateSampleERTMain=false);
    
    %set_param(Modelname,PortableWordSizes=true);
    
    % 代码生成
    try % 为普通机器分支
        slbuild(modelName,GenerateCodeOnly=true);

        % 配置代码生成路径与模型同路径
        modelSrcFolder = fullfile(srcFolder, 'Src');
        modelIncFolder = fullfile(srcFolder, 'Include');
    
        mkdir(modelSrcFolder);
        mkdir(modelIncFolder);  % 重复创建会有警告，需要改进。
    
        CopyCodeToModelFolder(srcFolder, modelSrcFolder, modelIncFolder);   % 删除多余反馈变量, Modify by zqh, 20250303
    
        % cAPIfileName = fullfile(modelSrcFolder, strcat(modelName, '_capi.c'));
    catch  % 为特殊机器分支，代码生成时报错Dimension exceeds index 0.
        % 配置代码生成路径与模型同路径
        modelFolder = fullfile(pwd, [modelName, '_ert_rtw']);%和模型同路径的生成代码目录
    
        modelSrcFolder = fullfile(modelFolder, 'Src');
        modelIncFolder = fullfile(modelFolder, 'Include');
    
        % 改进: 2025/02/06 重复创建会有警告,解决此问题
        if ~exist(modelSrcFolder, 'dir')
            mkdir(modelSrcFolder);
        end
        if ~exist(modelIncFolder, 'dir')
            mkdir(modelIncFolder);  
        end
    
        CopyCodeToModelFolder(srcFolder, modelSrcFolder, modelIncFolder);
    
        % cAPIfileName = fullfile(modelSrcFolder, strcat(modelName, '_capi.c'));
    end
end

% 拷贝文件夹内容
function files = CopyCodeToModelFolder(srcFolder,destSrcFolder, destIncFolder)
    %COPYCODETOMODELFOLDER Summary of this function goes here
    %   Detailed explanation goes here
    assert(exist(srcFolder, 'dir'), ['srcFolder: ''' srcFolder '''does not exist!']);
    % check whether destFolder exists.
    assert(exist(destSrcFolder, 'dir'), ['destSrcFolder: ''' destSrcFolder ''' does not exist!']);
    assert(exist(destIncFolder, 'dir'), ['destIncFolder: ''' destIncFolder ''' does not exist!']);
    % collect source code files
    cFileList = dir(fullfile(srcFolder, '*.c'));
    % % Only check folder isempty when Normal Sim.
    % if ~contains(destSrcFolder, 'ConnectedIO')
    %     assert(~isempty(cFileList), 'Code generation problems occurs! Source code is empty!');
    % end
    hFileList ='';
    % file list combining
    fileNum = length(cFileList) + length(hFileList);
    fileList = cell(1, fileNum);
    % add full path of each file into fileList.
    for ii = 1:length(cFileList)
        fileList{ii} = fullfile(cFileList(ii).folder, cFileList(ii).name);
    end
    
    for ii = 1:length(fileList)
        copyfile(fileList{ii}, destSrcFolder);    % Source code put to src folder.
    end
    % collect header files
    cFileList = '';   %#ok 重新初始化
    hFileList = dir(fullfile(srcFolder, '*.h'));
    % add full path of each file into fileList.
    
    for ii = 1:length(hFileList)
        fileList{ii} = fullfile(hFileList(ii).folder, hFileList(ii).name);
    end
    for ii = 1:length(hFileList)
        copyfile(fileList{ii}, destIncFolder);    % Source code put to src folder.
    end
    % sum all files
    files = {};
    cFileList = dir(fullfile(srcFolder, '*.c'));
    for ii = 1:length(cFileList)
        files{ii} = fullfile(cFileList(ii).folder, cFileList(ii).name);  %#ok
    end
    hFileList = dir(fullfile(srcFolder, '*.h'));
    for ii = 1:length(hFileList)
        files{end + 1} = fullfile(hFileList(ii).folder, hFileList(ii).name); %#ok
    end
end
