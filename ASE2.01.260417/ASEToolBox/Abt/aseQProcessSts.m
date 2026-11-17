function aseQProcessSts
% /******************** (C) COPYRIGHT 2025 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： aseQProcessSts.m
%  * 描    述 ： 查询下位机aseTarget的运行进程
%  * 版    本 ： V1.01.250415   初版基本功能程序
%  * 输入参数：
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：飞行控制与仿真
% **********************(C) COPYRIGHT 2025 ACG Tech Group.**********************************************/
    [prjPath,~,remoteBinDirUnix,userName,passWord, ip]  = getAseEnvPath(); 
        % 先连接下位机
    [connectStatus,passWordFileUnix] = Connect(prjPath, remoteBinDirUnix, userName, passWord, ip);

    if(connectStatus)
        QProcessSts(userName, ip, passWordFileUnix);
    else
        aseUpdateStatusBar('       请检查网线或检查下位机是否启动！ | 下位机未联通', [0 0.7 0], false); % 绿色
    end
end
