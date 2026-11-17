classdef maskCallbacks_DIORead

    methods(Static)

        % Use the code browser on the left to add the callbacks.


        function g_ext_trigger(callbackContext)
            ext_trigger = get_param(gcbh, 'g_ext_trigger');
            if strcmp(ext_trigger, 'on')
                set_param(gcbh, 'MaskVisibilityString', 'on,on,on');
            else
                set_param(gcbh, 'MaskVisibilityString', 'on,on,off');
            end
        end
    end
end