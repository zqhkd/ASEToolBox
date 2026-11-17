function [connectStatus,passWordFileUnix] = Connect(prjPath, remoteBinDirUnix, userName, passWord , ip)

% 获取RTEngine所在路径
% fullpath = mfilename('fullpath');
% [rtEnginePath,name]=fileparts(fullpath);

% plinkPath = strcat(prjPath, '\plink.exe');
pingFlag = -1;  %ping结果标志位的初始化，1为ping通，0不通
connectStatus = 0;

try
    [~, result] = system(['ping -n 1 ', ip]); % 快速测试（仅1个包）

    if contains(result, 'TTL=') || contains(result, 'time=')
        pingFlag = 1;
        fprintf('IP地址为%s的仿真机网络已联通！\n', ip);        
    else
        pingFlag = 0;
        error('未收到仿真机有效响应，仿真机IP地址为%s。', ip);
    end
catch
    disp('下位机192.168.0.7网络未联通！请检查：1）下位机是否已正常启动；2）上位机与下位机网线是否已连接；3）上位机与下位机是否在同一个网段。');
end

passWordFile = fullfile(prjPath,'WorkShop\passWordFile');
passWordFileUnix = strrep(passWordFile,'\', '/');
fid = fopen(passWordFile,'w');
fprintf(fid,'%s',passWord);
fclose(fid);

fullCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "cat %s/rt.lic"\n', userName, ip, passWordFileUnix,remoteBinDirUnix);

if pingFlag>0.5     %表示上位机与下位机网络通信正常，可执行ssh指令
    [status, cmdOut] = system(fullCommand);%运行启动脚本
    if (status ~= 0)
        disp(cmdOut);

        [status, cmdOut] = system(fullCommand);%如果发生错误，则再运行一次，
        if (status ~= 0)
            error('RunASE: SSH查找许可证文件rt.lic时发生错误!');
        end
    end

    % 功能：检测下位机/usr/xenomai/RTModel/rt.lic里记录的用户名及密码是否与当前匹配，与原功能一样但进行优化
    if contains(cmdOut, userName) || contains(cmdOut, passWord)
        connectStatus = 1;
    else
        connectStatus = 0;
    end

    % 检测下位机/usr/xenomai/RTModel/rt.lic里记录的用户名及密码是否与当前匹配
    % tmp = strsplit(string(cmdOut), '"');
    % usrAndName = strip(tmp(3));
    % tmp = strsplit(usrAndName, ' ');
    % user = tmp(1);
    % passwd = tmp(2);
    % 
    % if strcmp(user, username) && strcmp(passwd, passWord)
    %     connectStatus = 1;
    % else
    %     connectStatus = 0;
    % end

end

end

