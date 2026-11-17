function [prjPath,modelPath,remoteBinDirUnix,userName,passWord, ip] = getAseEnvPath
% /******************** (C) COPYRIGHT 2023 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： setAseEnvPath.m
%  * 描    述 ： 自动部署工具主程序
%  * 版    本 ： V1.01.250205   初版基本功能程序, 根据ACG团队需求，对初版程序进行更改，包括：
%                  (1) 使用前在主函数里先配置好工作路径；
%                  (2) 与StripToolTab挂接作为其Callback来启动自动编译过程；
%                  (3) 增加了Ctrl+B启动自动编译功能；
%                  (4) 考虑三种不同发布模式；
%  * 输入参数：发布方式，分别为
%      0--普通用户发布（需运行安装程序，指定ASE5ProjectPath等环境变量）
%      1--内部测试版，已固定    等环境变量，而ASEProjectPath为D:\ASE\ASEPRJ路径
%      2--内部开发版，已固定    等环境变量，而ASEProjectPath为D:\ASE\ASEFULL路径
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：无人飞行控制
% **********************(C) COPYRIGHT 2023 ACG Tech Group.**********************************************/

% 发布方式iPulishSel选择包括：
    %     0 -- 正常发布，环境变量已在用户安装过程中进行了定义，此处不用强行定义
    %     1 -- ASEPRJ工程发布版，也称内部版。主要是ASE工程文件路径在D:\ASE\ASEPRJ
    %     2 -- ASEFULL源工程版，也称开发版。主要是ASE工程文件路径在D:\ASE\ASEFULL
    % 正式开始进行处理
    iPublishSel = 2;

    if(iPublishSel==1)
        setenv('ASEProjectPath','D:\ASE\ASEProject');    %设置Keil工程的安装路径。这是曾庆华联想电脑T490发布版本的工程路径
    end
    if(iPublishSel==2)
        setenv('ASEProjectPath','D:\ASE\ASE-2\ASEProject');  %设置Keil工程的安装路径。这是曾庆华联想电脑ThinkBook16P源工程版本路径
    end

    prjPath = getenv('ASEProjectPath');   % 需要用户配置安装路径

    %  modelPath是包含带后缀slx模型名称的全路径，如: D:\ASE\ASE-1\Demo\TXComC.slx
    modelName =  bdroot(gcs);
    modelPath = fullfile(pwd, [modelName,'.slx']); % 代码生成路径

    [remoteBinDirUnix, userName, passWord, ip] = getAseTargetInf(prjPath);

    % 检查文件是否存在
    curModelSlx = [modelName,'.slx'];
    if ~exist(fullfile(pwd, curModelSlx), 'file')
        % 构建错误消息
        errMsg = sprintf(['%s 文件不存在于当前目录:\n%s\n\n' ...
                         '请切换到包含 %s 的目录后重新运行此脚本。'], ...
                         curModelSlx,pwd,curModelSlx);
        
        % 弹出错误对话框（模态对话框，带错误图标）
        uiwait(errordlg(errMsg, '文件未找到', 'modal'));
        
        % 抛出错误终止执行
        error("在当前目录下未找到你运行的模型文件");
    end
    
    currentTLC = get_param(modelName, 'SystemTargetFile');
    if ~contains(currentTLC, "ert.tlc")
        % 构建错误消息
        errMsg = sprintf(['%s 文件不是ASE目标系统的模型文件！\n\n' ...
                         '请打开ASE模型文件或切换到其它目标（如AFC)系统的部署菜单进行部署。'], ...
                         curModelSlx);
        
        % 弹出错误对话框（模态对话框，带错误图标）
        uiwait(errordlg(errMsg, '部署菜单错误窗口', 'modal'));
        
        % 抛出错误终止执行
        error("当前模型文件不是ASE目标系统文件，不能正常部署");
    end

    % 由于研发人员升级matlab2025a后，matlab自动代码生成的c语言编译器默认采用vs2022, 因此必须调用如下配置指令
    % 在matlab命令行下执行： >> mex -setup c
    %   可查看到：mex配置的C语言编译器，视情可以更改'Microsoft Visual C++ 2022 v17.0 | nmake (64-bit Windows)'相关内容
    if(iPublishSel==2)
         % 使用正确的Visual C++ 2022工具链名称（需要包含版本号v17.0）
        set_param(modelName, 'Toolchain', 'Microsoft Visual C++ 2022 v17.0 | nmake (64-bit Windows)');
    end

    % 初始化全局变量
    % initWorkSpaceVariables(ModelName);

    % 启动代码生成
    % activeConfigObj = getActiveConfigSet(ModelName);
    % set_param(activeConfigObj,'t_BuildCPrj2Hex','on');
    % set_param(activeConfigObj,'t_DownLoad2Target','on');
end

function [remoteBinDirUnix, userName, passWord, ip] = getAseTargetInf(prjPath)
%GETASEENVPATH 从 ASETarget.inf 文件中读取ASE环境配置信息
%   输入参数:
%       infFilePath - ASETarget.inf 文件路径(可选)
%   输出参数:
%       remoteBinDirUnix - 远程Unix二进制目录
%       userName - 用户名
%       passWord - 密码
%       ip - IP地址

% 如果没有提供文件路径，使用默认路径
    infFilePath = fullfile(prjPath,'ASEToolBox\ASETargetSystem.inf');
    
    % 初始化默认值
    remoteBinDirUnix = '';
    userName = '';
    passWord = '';
    ip = '';
    
    % 检查文件是否存在
    if ~exist(infFilePath, 'file')
        error('ASETarget.inf 文件不存在: %s', infFilePath);
    end
    
    % 打开文件
    fid = fopen(infFilePath, 'r');
    if fid == -1
        error('无法打开文件: %s', infFilePath);
    end
    
    % 逐行读取文件内容
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        
        % 跳过空行和注释行
        if isempty(line) || line(1) == '#' || line(1) == '%'
            continue;
        end
        
        % 分割变量名和值
        tokens = regexp(line, '^\s*([a-zA-Z]\w*)\s*=\s*''([^'']*)''\s*;?\s*$', 'tokens');
        
        if ~isempty(tokens)
            varName = tokens{1}{1};
            varValue = tokens{1}{2};
            
            % 根据变量名赋值
            switch lower(varName)
                case 'remotebindirunix'
                    remoteBinDirUnix = varValue;
                case 'username'
                    userName = varValue;
                case 'password'
                    passWord = varValue;
                case 'ip'
                    ip = varValue;
            end
        end
    end
    
    % 关闭文件
    fclose(fid);
    
    % 检查必要参数是否已设置
    if isempty(remoteBinDirUnix)
        warning('remoteBinDirUnix 未在配置文件中设置');
    end
    if isempty(userName)
        warning('userName 未在配置文件中设置');
    end
    if isempty(passWord)
        warning('passWord 未在配置文件中设置');
    end
    if isempty(ip)
        warning('ip 未在配置文件中设置');
    end
end