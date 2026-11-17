classdef maskSysComCallbacks_Receive

    methods(Static)

        % Use the code browser on the left to add the callbacks.


        function g_sample_time(~)
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

        function g_serial_select(~)
            serialInBlks = find_system(bdroot(gcs), 'ReferenceBlock', 'ASEToolBox/COMModule/XComIn');
            idx = strcmp(serialInBlks, gcb); 
            serialInBlks(idx) = [];
            if ~isempty(serialInBlks)
                serialDevices = cell(1, numel(serialInBlks));
                for ii = 1:numel(serialInBlks)
                    serialDevices(ii) = get_param(serialInBlks(ii), 'g_serial_select');
                end
                currentSerialDevices = get_param(gcbh, 'g_serial_select');
                if contains(currentSerialDevices, serialDevices)
                    msgbox('当前所选的串口设备已被使用，需要重新设定!','提示');
                end
            end
%% 检查，设置不可修改
            % serialOutBlks = find_system(bdroot(gcs), 'ReferenceBlock', 'ASEToolBox/COMModule/XComOut');
            % if ~isempty(serialOutBlks)
            %     currentDevice=get_param(gcb, 'g_serial_select');
            %     for i=1:length(serialOutBlks)
            %         serialDevice=get_param(serialOutBlks(i), 'g_serial_select');
            %         if serialDevice{1}==currentDevice
            %             set_param(gcb, 'LinkStatus', 'inactive');%禁用链接但保留引用
            %             maskObj = Simulink.Mask.get(gcb);
            %             % tabgroup = maskObj.addDialogControl('tabcontainer','tabgroup');
            %             for i = 1:length(maskObj.Parameters)
            %                 parameters = maskObj.Parameters(i);
            %                 parameters.set('ReadOnly','on');
            %             end
            %         end
            %     end
            % end
%% 修改自定义选项


            currentBlock = gcb;
            selectedOption = get_param(currentBlock, 'g_serial_select');
            
            %获取当前的掩码选项列表
            maskObj = get_param(currentBlock, 'MaskObject');
            paramObj = maskObj.Parameters(strcmp({maskObj.Parameters.Name}, 'g_serial_select'));
            currentOptions = paramObj.TypeOptions; % 获取选项列表，例如 {'Option1', 'Option2', 'Custom'}

            if strcmp(selectedOption, currentOptions{end})
                prompt = '请输入自定义设备:';
                dlgtitle = '自定义选项';
                dims = [1 35];
                definput = {'0'};
                customValue = inputdlg(prompt, dlgtitle, dims, definput);

                % if ~isempty(customValue)
                %     set_param(currentBlock, 'LinkStatus', 'inactive');%禁用链接但保留引用
                %     % 更新选项列表，只修改最后一个选项
                %     newOptions = currentOptions;
                %     newOptions{end} = customValue{1}; % 将最后一个选项改为用户输入的值
                %     paramObj.TypeOptions = newOptions; % 更新掩码选项
                % 
                %     % 将参数值设置为新输入的值
                %     set_param(currentBlock, 'g_serial_select', customValue{1});
                % end
            end
        end

        function g_output_datatype(~)
            dt = get_param(gcbh, 'g_output_datatype');
            if ~strcmp(dt, 'double') && ~strcmp(dt, 'uint8')
                msgbox('暂不支持所选数据类型，仅支持double和uint8.', '提示');
                set_param(gcbh, 'g_output_datatype', 'double');
            end
        end
        end
end