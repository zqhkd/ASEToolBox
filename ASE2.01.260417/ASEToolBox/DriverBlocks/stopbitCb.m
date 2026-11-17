function stopbitCb
stopbitStr = get_param(gcbh, 'g_stopbit');
if ~strcmp(stopbitStr, '1') && ~strcmp(stopbitStr, '2')
    msgbox('停止位只能填入1或者2!');
    set_param(gcbh, 'g_stopbit', '1');
end
end