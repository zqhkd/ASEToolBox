classdef VerifyInSignalNameButton

    methods(Static)

        % Use the code browser on the left to add the callbacks.
        function Control1(callbackContext)
            MsgUDPInSignal
        end

        function g_iVarNum(callbackContext)
            % 获取当前模块句柄
            hBlock = gcb;

            % 获取子模块句柄
            udp_receive_block = [hBlock '/MonitorReceive'];

            % 从模块参数中获取g_iVarNum的值
            iVarNum = str2double(get_param(hBlock, 'g_iVarNum'));

            g_buffersize = iVarNum * 4 + 12;

            set_param(udp_receive_block, 'g_buffersize', num2str(g_buffersize));
        end

        function g_ip(callbackContext)
            % 获取当前模块句柄
            hBlock = gcb;

            % 获取子模块句柄
            udp_receive_block = [hBlock '/MonitorReceive'];

            % 从模块参数中获取g_iVarNum的值
            ipAddress = get_param(hBlock, 'g_ip');

            set_param(udp_receive_block, 'g_ip', ipAddress);
            
        end
    end
end