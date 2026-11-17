function aseOnlyRtwC
% /******************** (C) COPYRIGHT 2025 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： aseOnlyRtwC.m
%  * 描    述 ： 仅生成代码程序
%  * 版    本 ： V1.01.250412   初版基本功能程序
%  * 输入参数：发布方式，分别为
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：飞行控制与仿真
% **********************(C) COPYRIGHT 2025 ACG Tech Group.**********************************************/
    [prjPath,~,~,~,~, ~]  = getAseEnvPath; 
    [modelSrcFolder, modelIncFolder,modelName,~] = aseAbtProcess;
    aseGenAseSlx2UbuntuAPI(prjPath,modelSrcFolder,modelIncFolder, modelName);  

   %% 调用监测信号名收集的功能模块
    aseUDPOutSignal(modelName,prjPath);
    aseUDPInSignal(modelName,prjPath);
    aseUpdateStatusBar('       ASETarget代码已生成！ | 待机运行状态', [0 0.7 0], false);  %  绿色

end
