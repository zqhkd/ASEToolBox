function aseSts = Stop(userName, ip, passWordFileUnix,remotePassWord)
% KillAllAsebin - 关闭下位机中所有 asebin 进程
%
% 输入参数:
%   prjPath - 项目路径(未在本函数中使用，保留供未来扩展)
%   username - 下位机的用户名
%   ip - 下位机的IP地址
%   passWordFileUnix - 包含密码的文件路径(用于plink的自动登录)
%
% 输出参数:
%   aseSts - 操作状态:
%            1: 成功终止所有 asebin 进程
%            0: 没有找到 asebin 进程
%           -1: 连接或执行命令失败
    % 构造终止进程的命令
    fullCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "/usr/bin/echo ''%s'' | sudo -S pkill -9 -f ./asebin"',userName, ip, passWordFileUnix,remotePassWord);

    % 执行命令
    system(fullCommand);
    
    % 处理不同情况
    aseSts = QProcessSts(userName, ip, passWordFileUnix);

    % 清除动画运行标志
    if aseSts==1
        aseUpdateStatusBar('       ASETarget任务已停止 | 待机运行状态', [0 0.7 0], false); % 绿色
    end
end

