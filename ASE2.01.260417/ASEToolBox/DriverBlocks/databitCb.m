function databitCb()
databitStr = get_param(gcbh, 'g_databit');
if ~strcmp(databitStr, '7') && ~strcmp(databitStr, '8')
    msgbox('数据位只能填入7或者8!');
    set_param(gcbh, 'g_databit', '8');
end
end