classdef UDP_ReceiveCb

    methods(Static)

        % Use the code browser on the left to add the callbacks.


        function g_reusePort(callbackContext)
            UDP_SendBlks = find_system(bdroot(gcs), 'FunctionName', 'UDPSend_sfcn');
            sendLocalPort = {};
            for ii = 1:numel(UDP_SendBlks)
                sendLocalPort{end + 1} = get_param(UDP_SendBlks{ii}, 'g_localPort'); %#ok
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