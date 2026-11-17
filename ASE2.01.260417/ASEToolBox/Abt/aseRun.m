function aseRun
% /******************** (C) COPYRIGHT 2025 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： aseRun.m
%  * 描    述 ： 运行目标代码
%  * 版    本 ： V1.01.250412   初版基本功能程序
%  * 输入参数：发布方式，分别为
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：飞行控制与仿真
% **********************(C) COPYRIGHT 2025 ACG Tech Group.**********************************************/
    [prjPath,~,remoteBinDirUnix,userName,passWord, ip]  = getAseEnvPath; 
        % 先连接下位机
    [connectStatus,passWordFileUnix] = Connect(prjPath, remoteBinDirUnix, userName, passWord, ip);

    if(connectStatus)
        Start(remoteBinDirUnix, userName, ip, passWordFileUnix,passWord);
        aseUpdateStatusBar('       ASETarget 正在运行.....| 运行状态', [0.9 0 0], true); % 红色
    end
end
