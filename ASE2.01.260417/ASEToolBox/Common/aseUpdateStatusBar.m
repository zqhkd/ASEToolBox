function aseUpdateStatusBar(msg, color, enableFlash)
     persistent isAnimationRunning;  % 使用 persistent 替代 global
    
    % 获取模型名称
    modelName = bdroot;
    
    % % 设置状态栏颜色
    % set_param(modelName, 'StatusBarColor', color);
    
    % 旋转动画字符
    spinChars = {'-', '\', '|', '/'};
    
    if enableFlash
        % 启动动画循环
        isAnimationRunning = true;
        i = 0;
        
        while isAnimationRunning
            % 更新状态栏文本
            set_param(modelName, 'StatusString', [msg ' ' spinChars{mod(i, 4) + 1}]);
            pause(0.1);
            i = i + 1;
        end
    else
        % 停止动画并设置最终状态
        isAnimationRunning = false;
        set_param(modelName, 'StatusString', msg);
    end
end