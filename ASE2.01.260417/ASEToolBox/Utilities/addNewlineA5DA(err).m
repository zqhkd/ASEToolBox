function addNewlineA5DA()
    [datFile,filePath] = uigetfile('*.txt');
    fileName = [filePath datFile];
   % 读取文本文件内容
    file_content = fileread(fileName);  % 
    
    % 将文本内容按十六进制数分割
    hex_numbers = textscan(file_content, '%s', 'Delimiter', ' ');
    hex_numbers = hex_numbers{1};
    
    % 转换为小写
    hex_numbers = lower(hex_numbers);
    
    % 找到以 'a5' 开头的位置
    is_a5 = strncmp(hex_numbers, 'a5', 2);
    
    % 找到以 'da' 开头的位置
    is_da = strncmp(hex_numbers, 'da', 2);
    
   % 向右移位一位，使得 is_da 与 is_a5 错位对比
    shifted_is_da = false(size(is_a5));
    shifted_is_da(1:end-1) = is_da(2:end);
   
    % 找到 'a5' 后面紧跟着 'da' 的位置
    marker_index = find(is_a5 & shifted_is_da, 1);

    if ~isempty(marker_index)
        % 在标识前添加回车换行符
        hex_numbers = [hex_numbers(1:marker_index-1); sprintf('\r\n'); hex_numbers(marker_index:end)];
        
        % 将处理后的十六进制数重新拼接成字符串
        new_content = sprintf('%s ', hex_numbers{:});
        new_content(end) = [];  % 去除最后一个空格
        
        % 将处理后的内容写回文件
        fileID = fopen('testA5DA.txt', 'w');
        fprintf(fileID, '%s', new_content);
        fclose(fileID);
    else
        disp('未找到标识 A5 DA');
    end
end