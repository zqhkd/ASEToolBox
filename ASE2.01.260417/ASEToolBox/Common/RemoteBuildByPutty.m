function buildStatus = RemoteBuildByPutty(modelPath, prjPath, remoteBinDirUnix, userName, targetIP, passWordFileUnix)
    % 输入参数：
    % modelPath: 用户模型路径（如 'D:\ASEHost\Demo\TXComC.slx'）
    % prjPath: 工具所在的路径（如 'D:\ASEHost\Tools'）
    % sshKeyPath: 为ssh服务保存私钥id_rsa和公钥id_rsa.pub的路径, 缺省情况为"~\.ssh"
    %  passWordFile = 'passWordFile';
    % 示例测试：RemoteBuildBySSH('D:\ASE\ASEHost\Demo\TXComC.slx','D:\ASE\ASEHost','~\.ssh');

    batfile = [prjPath, '\WorkShop\remoteBuild.bat'];
    fid = fopen(batfile, 'w');

    % 1. 获取模型路径并生成 modelRtwDir
    [modelDir, modelName, ~] = fileparts(modelPath);
    modelRtwDir = [fullfile(modelDir, modelName), '_ert_rtw'];
    buildStatus = 1;

    % 检查 modelRtwDir 是否存在
    if ~exist(modelRtwDir, 'dir')
        buildStatus = 0;
        error('RTW目录不存在: %s', modelRtwDir);
    end

    % 2. 远程清空下位机子目录
    disp('清空下位机子目录...');
    % remoteTargetDir = '/home/administrator/projects/ASETarget/Slx2Rtw';
    % 获取 plink 和 pscp 的完整路径
    % plinkPath = fullfile(prjPath, 'plink.exe');
    % pscpPath = fullfile(prjPath, 'pscp.exe');
    % passWordFileUnix = strrep(fullfile(prjPath,passWord),'\', '/');

    % 使用 plink 远程执行清空目录命令
    % 删除远程Include目录
    % D:\ASE\ASEHost\plink -ssh %USER%@%HOST% -pwfile %PWFILE% -batch "rm -r %REMOTE_DIR%%INCLUDE_FOLDER%"
    disp('*** 删除已生成的源文件目录Include、Src！');
    plinkCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "rm -r %s/Slx2Rtw/Include"', userName, targetIP, passWordFileUnix, remoteBinDirUnix);
    fprintf(fid,"%s\n",plinkCommand);

    % 删除远程Src目录
    % D:\ASE\ASEHost\plink -ssh %USER%@%HOST% -pwfile %PWFILE% -batch "rm -r %REMOTE_DIR%%SRC_FOLDER%"
    plinkCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "rm -r %s/Slx2Rtw/Src"', userName, targetIP, passWordFileUnix, remoteBinDirUnix);
    fprintf(fid,"%s\n",plinkCommand);

    % 删除远程目录build目录下所有内容，关键是清空asebin运行程序
    disp('*** 删除已生成的目标运行文件asebin！');
    plinkCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "rm -r %s/build"', userName, targetIP, passWordFileUnix, remoteBinDirUnix);
    fprintf(fid,"%s\n",plinkCommand);

    % 3. 使用 pscp 同步传输文件
    disp('传输文件到下位机...');
    srcDir = fullfile(modelRtwDir, 'Src');
    includeDir = fullfile(modelRtwDir, 'Include');
    
    % 复制Include到远程
    if exist(includeDir, 'dir')
        % 将 Windows 路径中的反斜杠替换为正斜杠
        includeDirUnix = strrep(includeDir, '\', '/');
        % D:\ASE\ASEHost\pscp -pwfile %PWFILE% -r %LOCAL_DIR%%INCLUDE_FOLDER% %USER%@%HOST%:%REMOTE_DIR%
        pscpCommand = sprintf('pscp -pwfile %s -r %s %s@%s:%s/Slx2Rtw', passWordFileUnix, includeDirUnix, userName, targetIP, remoteBinDirUnix);
        fprintf(fid,"%s\n",pscpCommand);
    else
        warning('Include 目录不存在: %s', includeDir);
        buildStatus = 0;
    end

    % 复制Src到远程
    if exist(srcDir, 'dir')
        % 将 Windows 路径中的反斜杠替换为正斜杠
        srcDirUnix = strrep(srcDir, '\', '/');
        % D:\ASE\ASEHost\pscp -pwfile %PWFILE% -r %LOCAL_DIR%%INCLUDE_FOLDER% %USER%@%HOST%:%REMOTE_DIR%
        pscpCommand = sprintf('pscp -pwfile %s -r %s %s@%s:%s/Slx2Rtw', passWordFileUnix, srcDirUnix, userName, targetIP, remoteBinDirUnix);
        fprintf(fid,"%s\n",pscpCommand);
    else
        warning('Src 目录不存在: %s', srcDir);
        buildStatus = 0;
    end
    
    % 4. 进入远程目录，编译
    disp('在下位机编译代码...');
    remoteBuildDir = '/home/administrator/projects/ASETarget/build';
    % D:\ASE\ASEHost\plink -ssh %USER%@%HOST% -pwfile %PWFILE% -batch "mkdir -p %REMOTE_BUILD_DIR%; cd %REMOTE_BUILD_DIR%; cmake ..; make"
    compileCommand = sprintf('plink -ssh %s@%s -pwfile %s -batch "mkdir -p %s; cd %s; rm -r *; cmake ..; make"', userName, targetIP, passWordFileUnix, remoteBuildDir,remoteBuildDir);
    fprintf(fid,"%s\n",compileCommand);

    % 5. 远程运行目标程序
    % disp('运行目标程序...');
    % % "cd %REMOTE_BUILD_DIR%; sudo ./%EXE_NAME%"
    % % D:\ASE\ASEHost\plink.exe -ssh administrator@192.168.0.7 -pwfile passWordFile -batch "cd /home/administrator/projects/ASETarget/build/bin; /usr/bin/echo 'admin123' | sudo -S ./asebin"
    % runCommand = sprintf('%s -ssh %s@%s -pwfile %s -batch "cd %s/bin; /usr/bin/echo "%s" | sudo -S ./asebin"', plinkPath, USER, HOST, passWordFile, remoteBuildDir,remotePassWord);
    % fprintf(fid,"%s\n",runCommand);

    fclose(fid);
    system(batfile);     %运行启动脚本, 编译目标代码
    disp('部署完成！');

end