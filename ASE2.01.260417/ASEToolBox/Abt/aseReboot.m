function aseReboot
    [prjPath,~,remoteBinDirUnix,userName,passWord, ip]  = getAseEnvPath; 
        % 先连接下位机
    [connectStatus,passWordFileUnix] = Connect(prjPath, remoteBinDirUnix, userName, passWord, ip);

    if connectStatus
        % 构造终止进程的命令
        fullCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "/usr/bin/echo "%s" | sudo -S reboot"',userName, ip, passWordFileUnix,passWord);
        % 执行命令
        system(fullCommand);

        aseUpdateStatusBar('             ASETarget计算机正在重启，请等待3分钟....', [0 0.7 0], false); % 绿色
    end

end