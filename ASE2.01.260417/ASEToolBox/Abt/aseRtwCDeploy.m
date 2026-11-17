function aseRtwCDeploy
% /******************** (C) COPYRIGHT 2025 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： aseRtwCDeploy.m
%  * 描    述 ： 自动部署主程序
%  * 版    本 ： V1.01.250412   初版基本功能程序
%  * 输入参数： 
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：飞行控制与仿真
% **********************(C) COPYRIGHT 2025 ACG Tech Group.**********************************************/
    [prjPath,modelPath,remoteBinDirUnix,userName,passWord, ip]  = getAseEnvPath; 

    [modelSrcFolder, modelIncFolder,modelName,~] = aseAbtProcess;
    aseUpdateStatusBar('     可在命令窗口观察代码生成过程..... | 正在生成代码', [0 0.7 0], false); % 绿色
    aseGenAseSlx2UbuntuAPI(prjPath,modelSrcFolder,modelIncFolder, modelName);

    %% 调用监测信号名收集的功能模块
    aseUDPOutSignal(modelName,prjPath);
    aseUDPInSignal(modelName,prjPath);

    %% 连接下位机并下载运行
    [connectStatus,passWordFileUnix] = Connect(prjPath, remoteBinDirUnix, userName, passWord, ip);

    if(connectStatus)
        % 自动下载与部署
        %更改为本地编译生成代码 RemoteBuildByPutty(modelPath, prjPath, passWordFile)
        aseUpdateStatusBar('     可在命令窗口观察部署过程..... | 正在下载代码及编译', [0 0.7 0], false); % 绿色
        deployStatus = RemoteBuildByPutty(modelPath, prjPath, remoteBinDirUnix,userName, ip, passWordFileUnix);
                      
        % 运行目标代码
        if(deployStatus) 
            Start(remoteBinDirUnix, userName, ip, passWordFileUnix,passWord);
        end
    end

end
