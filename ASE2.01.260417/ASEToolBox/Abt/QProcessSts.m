function aseProcessSts = QProcessSts(username, ip, passWordFileUnix)
% QProcessSts - 查询下位机中 asebin 进程是否在运行
%
% 输入参数:
%   prjPath - 项目路径(未在本函数中使用，保留供未来扩展)
%   username - 下位机的用户名
%   ip - 下位机的IP地址
%   passWordFileUnix - 包含密码的文件路径(用于plink的自动登录)
%
% 输出参数:
%   aseProcessSts - 进程状态:
%                   1: asebin 正在运行
%                   0: asebin 未运行
%                   -1: 连接或执行命令失败

    % 构造 plink 命令
    plinkPath = 'plink'; % 假设 plink 已在系统路径中，否则需要完整路径
    command = 'ps -ef | grep asebin | grep -v grep';
    
    % 构造完整的 plink 命令
    fullCommand = sprintf('%s -ssh %s@%s -pwfile %s "%s"', ...
                         plinkPath, username, ip, passWordFileUnix, command);
    
    % 执行命令并获取输出
    [status, cmdout] = system(fullCommand);
    
    modelName = bdroot(gcs);
    % 处理不同情况
    if status == 0
        % 命令成功执行且找到了 asebin 进程
        aseProcessSts = 1;
         % 更新状态栏文本
        aseUpdateStatusBar('       ASETarget 正在运行.....| 运行状态', [0.9 0 0], false); % 红色
    elseif status == 1
        % 命令成功执行但未找到 asebin 进程
        aseProcessSts = 0;
        aseUpdateStatusBar('       ASETarget任务已停止！ | 待机运行状态', [0 0.7 0], false); % 绿色
    else
        % 其他错误情况（连接失败等）
        aseProcessSts = -1;
        warning('连接下位机或执行命令失败。状态码: %d', status);
    end
end

