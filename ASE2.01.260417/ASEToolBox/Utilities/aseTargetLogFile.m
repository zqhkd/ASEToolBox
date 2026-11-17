%% 程序说明
%  读取仿真下位机ubuntu实时系统ASETarget在logfile调试模式下生成的testComFrame.txt文件
%  将testComFrame.txt文件内容转换为xls文件，主要是把帧内四字节浮点数转换为方便观察的浮点数
%% 程序实现

% 读取txt文件
filename = 'testComFrame.txt'; % 请替换为实际文件名

data = fileread(filename);

% 按行分割数据
lines = strsplit(data, '\n');

% 初始化结果数组
converted_lines = cell(1, length(lines));

% 遍历每一行进行处理
for i = 1:length(lines)
    line = strtrim(lines{i});
    
    % 按逗号分割当前行
    elements = strsplit(line, ',');
    elements = strtrim(elements);
    
    % 检查该行是否包含a5,da模式
    has_pattern = false;
    a5_position = 0;
    
    for j = 1:length(elements)-1
        if strcmp(elements{j}, 'a5') && strcmp(elements{j+1}, 'da')
            has_pattern = true;
            a5_position = j;
            break;
        end
    end
    
    if has_pattern && a5_position > 0 && (length(elements) - a5_position + 1) >= 12
        % 包含a5,da的数据帧，进行解析
        try
            % 提取从a5开始的所有字节
            frame_bytes = elements(a5_position:end);
            
            % 1) 第1字节到da保持不变
            before_da = elements(1:a5_position+1);
            
            % 2) 第3-4字节：帧长度（uint16，小端序）
            byte3 = hex2dec(frame_bytes{3});
            byte4 = hex2dec(frame_bytes{4});
            frame_length = byte4 * 256 + byte3; % 小端序：低位在前
            
            % 3) 第5-8字节：帧序号（uint32，小端序）
            byte5 = hex2dec(frame_bytes{5});
            byte6 = hex2dec(frame_bytes{6});
            byte7 = hex2dec(frame_bytes{7});
            byte8 = hex2dec(frame_bytes{8});
            frame_sequence = byte8 * 16777216 + byte7 * 65536 + byte6 * 256 + byte5; % 小端序
            
            % 4) 第9-11字节：保持不变
            bytes_9_11 = frame_bytes(9:11);
            
            % 5) 第12字节到倒数第2字节：按单精度float解析（小端序）
            float_data = [];
            data_start = 12;
            data_end = length(frame_bytes) - 1;
            data_length = data_end - data_start + 1;
            
            if mod(data_length, 4) == 0
                % 每4个字节解析为一个float（小端序）
                for k = 1:4:data_length
                    if (data_start + k + 3 - 1) <= length(frame_bytes)
                        byte1 = hex2dec(frame_bytes{data_start + k - 1});
                        byte2 = hex2dec(frame_bytes{data_start + k});
                        byte3 = hex2dec(frame_bytes{data_start + k + 1});
                        byte4 = hex2dec(frame_bytes{data_start + k + 2});
                        
                        % 将十六进制转换为单精度float（小端序）
                        hex_str = [byte1, byte2, byte3, byte4];
                        float_val = typecast(uint8(hex_str),'single');%解析参数
                        % float_val = hex2float(hex_str);
                        float_data = [float_data, float_val];                        
                    end
                end
            end
            
            % 6) 最后1个字节：校验和保持不变
            checksum = frame_bytes{end};
            
            % 构建转换后的数据行
            converted_elements = before_da; % 第1字节到da保持不变
            
            % 添加帧长度（转换为十进制）
            converted_elements = [converted_elements, {num2str(frame_length)}];
            
            % 添加帧序号（转换为十进制）
            converted_elements = [converted_elements, {num2str(frame_sequence)}];
            
            % 添加第9-11字节（保持不变）
            converted_elements = [converted_elements, bytes_9_11];
            
            % 添加解析后的float数据
            for k = 1:length(float_data)
                converted_elements = [converted_elements, {num2str(float_data(k), '%.6f')}];
            end
            
            % 添加校验和（保持不变）
            converted_elements = [converted_elements, {checksum}];
            
            % 重新组合转换后的行
            converted_line = strjoin(converted_elements, ',');
            converted_lines{i} = converted_line;
            
        catch
            % 解析失败，保持原样
            converted_lines{i} = line;
        end
    else
        % 不含a5,da的行，内容不变
        converted_lines{i} = line;
    end
end

% % 十六进制转单精度float的函数
% function float_val = hex2float(hex_str)
%     if length(hex_str) == 8
%         hex_val = uint32(hex2dec(hex_str));
%         float_val = typecast(swapbytes(typecast(hex_val, 'uint32')), 'single');
%     else
%         float_val = 0;
%     end
% end

% 保存转换后的数据到CSV文件
[filepath, name, ~] = fileparts(filename);
output_filename = fullfile(filepath, [name '_converted.csv']);

% 写入CSV文件
fid = fopen(output_filename, 'w');
for i = 1:length(converted_lines)
    if ~isempty(strtrim(converted_lines{i}))
        fprintf(fid, '%s\n', converted_lines{i});
    end
end
fclose(fid);
