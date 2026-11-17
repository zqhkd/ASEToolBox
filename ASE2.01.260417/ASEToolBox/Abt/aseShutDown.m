function aseShutDown
% 获取RTEngine所在路径
% fullpath = mfilename('fullpath'); 
% [rtEnginePath,name]=fileparts(fullpath);
    [prjPath,~,remoteBinDirUnix,userName,passWord, ip]  = getAseEnvPath; 
        % 先连接下位机
    [connectStatus,passWordFileUnix] = Connect(prjPath, remoteBinDirUnix, userName, passWord, ip);

    if connectStatus
        % 构造终止进程的命令
        fullCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "/usr/bin/echo "%s" | sudo -S shutdown now"',userName, ip, passWordFileUnix,passWord);
        % 执行命令
        system(fullCommand);

        aseUpdateStatusBar('             ASETarget计算机正在关机，请等待3分钟....', [0 0.7 0], false); % 绿色
    end

end