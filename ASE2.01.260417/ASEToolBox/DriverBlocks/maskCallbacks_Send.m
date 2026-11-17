classdef maskCallbacks_Send

    methods(Static)

        % Use the code browser on the left to add the callbacks.


        function g_input_datatype(callbackContext)
            dt = get_param(gcbh, 'g_input_datatype');
            if ~strcmp(dt, 'double') && ~strcmp(dt, 'uint8')
                msgbox('暂不支持所选数据类型，仅支持double和uint8.', '提示');
                set_param(gcbh, 'g_input_datatype', 'double');
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
    end
end