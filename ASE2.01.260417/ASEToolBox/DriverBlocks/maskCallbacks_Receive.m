classdef maskCallbacks_Receive

    methods(Static)

        % Use the code browser on the left to add the callbacks.


        function g_sample_time(callbackContext)
            % 尝试将字符串转换为数值
            str = get_param(gcbh,  'g_sample_time');
            num = str2double(str);
            
            % 检查转换结果是否为 NaN
            if isnan(num)
                isValid = false;
            else
                isValid = true;
            end            
        end

        function g_serial_select(callbackContext)
            serialInitBlks = find_system(bdroot(gcs), 'ReferenceBlock', 'RTlib/MOXA CP-116E-A/SerialInit');
            if isempty(serialInitBlks)
                msgbox('当前模型尚未创建串口初始化模块，请先配置串口初始化模块!', '提示');
                return;
            end
            serialDevices = cell(1, numel(serialInitBlks));
            for ii = 1:numel(serialInitBlks)
                serialDevices(ii) = get_param(serialInitBlks(ii), 'g_serial_select');
            end
            currentSerialDevices = get_param(gcbh, 'g_serial_select');
            if ~contains(currentSerialDevices, serialDevices)
                msgbox('当前所选的串口设备尚未被模型初始化，需要重新设定!','提示');
                set_param(gcbh, 'g_serial_select', serialDevices{1});
            end
        end

        function g_output_datatype(callbackContext)
            dt = get_param(gcbh, 'g_output_datatype');
            if ~strcmp(dt, 'double') && ~strcmp(dt, 'uint8')
                msgbox('暂不支持所选数据类型，仅支持double和uint8.', '提示');
                set_param(gcbh, 'g_output_datatype', 'double');
            end
        end
        end
end