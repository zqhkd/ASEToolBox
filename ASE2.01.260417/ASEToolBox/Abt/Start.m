function runningStatus = Start(remoteBinDirUnix, userName, targetIP, passWordFileUnix,remotePassWord)

%% 运行生成的可执行程序
   % 构造运行进程的命令
    fullCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "cd %s/build/bin; chmod +x asebin; /usr/bin/echo "%s" | sudo -S ./asebin >/dev/null 2>&1 &"\n', ...
                           userName, targetIP, passWordFileUnix, remoteBinDirUnix,remotePassWord);
    % batfile = fullfile(prjPath, 'WorkShop\runASE.bat');
    % fid = fopen(batfile, 'w');
    % fprintf(fid,fullCommand);
    % fclose(fid);
        % 执行命令
    disp('运行目标程序...');
    [status, ~] = system(fullCommand);
    
    if status ~= 0
        error('RunASE: SSH传输asebin到下位机目标路径时发生错误!');
    end
    
    runningStatus = 0;
    errorCount = 0;

    while ~runningStatus
        fullCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "ps -ef | grep asebin"\n', userName, targetIP, passWordFileUnix);
        [status,cmdOut] = system(fullCommand);
        if status ~= 0
            error('RunASE: SSH查找进程asebin是否启动时发生错误!');
        end
        tmp = string(cmdOut);
        if contains(tmp, "sudo -S ./asebin") 
            runningStatus = 1;
        else
            runningStatus = 0;
            errorCount = errorCount + 1;
            if errorCount > 20
                break;
            end
        end
    end

    %% 显示运行状态
    if runningStatus
        aseUpdateStatusBar('       ASETarget系统已启动 | 正在运行...', [0.9 0 0], true); % 红色
    else
        aseUpdateStatusBar('       ASETarget系统程序存在错误！ | 错误状态', [0.9 0 0], false); % 红色
    end


%% 运行上位机模型求解
    % [~, modelname , ~] = fileparts(modelpath);
    % set_param(modelname,SimulationCommand="start");
end