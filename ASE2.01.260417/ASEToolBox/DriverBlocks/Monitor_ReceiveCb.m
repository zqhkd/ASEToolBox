classdef Monitor_ReceiveCb

    methods(Static)

        % Use the code browser on the left to add the callbacks.


        function g_reusePort(callbackContext)
            top_model = bdroot(gcs);
            % 模糊匹配ASEToolBox中的ASEMonitorOut
            all_blocks = find_system(top_model, 'Type', 'block');
            UDP_SendBlks = {};
            for i = 1:length(all_blocks)
                try
                    ref = get_param(all_blocks{i}, 'ReferenceBlock');
                    if contains(ref, 'ASEToolBox') && contains(ref, 'ASEMonitorOut')
                        UDP_SendBlks = [UDP_SendBlks; all_blocks{i}];
                    end
                catch
                    continue;
                end
            end
            %% 以下语句无法穿透底层封装的UDPSend模块
            % UDP_SendBlks = find_system(top_model, ...
            %     'BlockType', 'S-Function', ... % 限定S函数类型
            %     'FunctionName', 'UDPSend_sfcn', ...% 匹配目标S函数标识
            %     'Recursive', 'on', ...      % 递归搜索所有层级
            %     'LookUnderMasks', 'all'...  % 穿透所有封装
            %     );
            sendLocalPort = {};
            for ii = 1:numel(UDP_SendBlks)
                sendLocalPort{end + 1} = get_param([UDP_SendBlks{ii} '/MonitorSend'], 'g_localPort'); %#ok
            end
            localPortNum = get_param(gcbh, 'g_localPort');   
            if contains(localPortNum, sendLocalPort)
                set_param(gcbh, 'g_reusePort', '1');
            else
                set_param(gcbh, 'g_reusePort', '0');
            end
        end

    end
end