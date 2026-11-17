function aseDownDeploy
% /******************** (C) COPYRIGHT 2025 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： aseDownDeploy.m
%  * 描    述 ： 下载生成代码到下位机并运行
%  * 版    本 ： V1.01.250413   初版基本功能程序
%  * 输入参数： 
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：飞行控制与仿真
% **********************(C) COPYRIGHT 2025 ACG Tech Group.**********************************************/
    [prjPath,modelPath,remoteBinDirUnix,username,passWord, ip]  = getAseEnvPath(); 

    % 先连接下位机
    [connectStatus,passWordFileUnix] = Connect(prjPath, remoteBinDirUnix, username, passWord, ip);

    if(connectStatus)
        % 自动下载与部署
        aseUpdateStatusBar('     可在命令窗口观察部署过程..... | 正在下载代码及编译', [0 0.7 0], false); % 绿色
        deployStatus = RemoteBuildByPutty(modelPath, prjPath, remoteBinDirUnix,username, ip, passWordFileUnix);

        % 运行目标代码
        if(deployStatus) 
            Start(remoteBinDirUnix, username, ip, passWordFileUnix,passWord);
        end
    end
end
