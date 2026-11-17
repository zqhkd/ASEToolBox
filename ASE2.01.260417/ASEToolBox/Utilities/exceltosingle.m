%% 导入电子表格中的数据
% 用于从以下电子表格导入数据，并将其中的4字节表示的原始single类型解析成single数据并进行存储。
%    工作簿: C:\Users\yudu\Downloads\T250411183105ase.xlsx
%    工作表: 串口接收

clc
clear

%% 设置导入选项并生成目标文件路径
sourceFile = 'C:\Users\yudu\Downloads\T250411183105ase.xlsx';

% 查找最后一个 '.' 的位置
dotIndex = find(sourceFile == '.', 1, 'last');
% 如果找到 '.'，则替换其后缀为 'xlsx'
if ~isempty(dotIndex)
    targetExcelFile = sprintf('%s_解析后.xlsx',sourceFile(1:dotIndex-1));
else
    % 如果没有找到 '.'，则直接在路径末尾添加 '.xlsx'
    targetExcelFile = sprintf('%s.xlsx',sourceFile);
end

%% 接收数据：设置导入选项并导入表头
opts = spreadsheetImportOptions("NumVariables", 109);

% 指定工作表和范围
opts.Sheet = "串口接收";
opts.DataRange = "A1:DE1";

% 指定列名称和类型
opts.VariableNames = ["T_s", "T_ns", "dTim", "idThread", "frameNo", "deltNo", "frameLen", "calChk", "rwCounter", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "send31", "VarName22", "VarName23", "VarName24", "d1", "VarName26", "VarName27", "VarName28", "d2", "VarName30", "VarName31", "VarName32", "d3", "VarName34", "VarName35", "VarName36", "d4", "VarName38", "VarName39", "VarName40", "P0", "VarName42", "VarName43", "VarName44", "P010", "VarName46", "VarName47", "VarName48", "P010_1", "VarName50", "VarName51", "VarName52", "gyroX1", "VarName54", "VarName55", "VarName56", "gyroY1", "VarName58", "VarName59", "VarName60", "gyroZ1", "VarName62", "VarName63", "VarName64", "accX01", "VarName66", "VarName67", "VarName68", "accY01", "VarName70", "VarName71", "VarName72", "accZ01", "VarName74", "VarName75", "VarName76", "Velx1020", "VarName78", "VarName79", "VarName80", "Vely2020", "VarName82", "VarName83", "VarName84", "VelZd1", "VarName86", "VarName87", "VarName88", "attX", "VarName90", "VarName91", "VarName92", "attY", "VarName94", "VarName95", "VarName96", "attZ", "VarName98", "VarName99", "VarName100", "AFCCounterAFC", "VarName102", "VarName103", "VarName104", "SimComF90", "VarName106", "VarName107", "VarName108", "VarName109"];
opts.VariableTypes = ["char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char"];

% 指定变量属性
opts = setvaropts(opts, ["T_s", "T_ns", "dTim", "idThread", "frameNo", "deltNo", "frameLen", "calChk", "rwCounter", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "send31", "VarName22", "VarName23", "VarName24", "d1", "VarName26", "VarName27", "VarName28", "d2", "VarName30", "VarName31", "VarName32", "d3", "VarName34", "VarName35", "VarName36", "d4", "VarName38", "VarName39", "VarName40", "P0", "VarName42", "VarName43", "VarName44", "P010", "VarName46", "VarName47", "VarName48", "P010_1", "VarName50", "VarName51", "VarName52", "gyroX1", "VarName54", "VarName55", "VarName56", "gyroY1", "VarName58", "VarName59", "VarName60", "gyroZ1", "VarName62", "VarName63", "VarName64", "accX01", "VarName66", "VarName67", "VarName68", "accY01", "VarName70", "VarName71", "VarName72", "accZ01", "VarName74", "VarName75", "VarName76", "Velx1020", "VarName78", "VarName79", "VarName80", "Vely2020", "VarName82", "VarName83", "VarName84", "VelZd1", "VarName86", "VarName87", "VarName88", "attX", "VarName90", "VarName91", "VarName92", "attY", "VarName94", "VarName95", "VarName96", "attZ", "VarName98", "VarName99", "VarName100", "AFCCounterAFC", "VarName102", "VarName103", "VarName104", "SimComF90", "VarName106", "VarName107", "VarName108", "VarName109"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["T_s", "T_ns", "dTim", "idThread", "frameNo", "deltNo", "frameLen", "calChk", "rwCounter", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "send31", "VarName22", "VarName23", "VarName24", "d1", "VarName26", "VarName27", "VarName28", "d2", "VarName30", "VarName31", "VarName32", "d3", "VarName34", "VarName35", "VarName36", "d4", "VarName38", "VarName39", "VarName40", "P0", "VarName42", "VarName43", "VarName44", "P010", "VarName46", "VarName47", "VarName48", "P010_1", "VarName50", "VarName51", "VarName52", "gyroX1", "VarName54", "VarName55", "VarName56", "gyroY1", "VarName58", "VarName59", "VarName60", "gyroZ1", "VarName62", "VarName63", "VarName64", "accX01", "VarName66", "VarName67", "VarName68", "accY01", "VarName70", "VarName71", "VarName72", "accZ01", "VarName74", "VarName75", "VarName76", "Velx1020", "VarName78", "VarName79", "VarName80", "Vely2020", "VarName82", "VarName83", "VarName84", "VelZd1", "VarName86", "VarName87", "VarName88", "attX", "VarName90", "VarName91", "VarName92", "attY", "VarName94", "VarName95", "VarName96", "attZ", "VarName98", "VarName99", "VarName100", "AFCCounterAFC", "VarName102", "VarName103", "VarName104", "SimComF90", "VarName106", "VarName107", "VarName108", "VarName109"], "EmptyFieldRule", "auto");

% 导入表头数据
rawName = readtable(sourceFile, opts, "UseExcel", false);

rawName = table2cell(rawName);
numIdx = cellfun(@(x) ~isnan(str2double(x)), rawName);
rawName(numIdx) = cellfun(@(x) {str2double(x)}, rawName(numIdx));

PARA_NUMBER =  (109-21)/4;

for i=1:PARA_NUMBER+20
    if i<=20
        dataname{1,i} = rawName{1,i};
    else
        dataname{1,i} = sprintf("indx%02d_%s",i-20,rawName{1,(i-21)*4+1+20});
    end
end

% 清除临时变量
clear numIdx opts numIdx
%% %接收数据：设置导入选项并生成目标文件路径
opts = detectImportOptions(sourceFile);

% 指定工作表和范围
opts.Sheet = "串口接收";

% % 指定列名称和类型
opts.VariableNames = ["T_s", "T_ns", "dTim", "idThread", "frameNo", "deltNo", "frameLen", "calChk", "rwCounter", "head0", "head1", "len0", "len1", "counter0", "counter1", "counter2", "counter3", "sendID", "receiveID", "frameID", "send31", "VarName22", "VarName23", "VarName24", "d1", "VarName26", "VarName27", "VarName28", "d2", "VarName30", "VarName31", "VarName32", "d3", "VarName34", "VarName35", "VarName36", "d4", "VarName38", "VarName39", "VarName40", "P0", "VarName42", "VarName43", "VarName44", "P010", "VarName46", "VarName47", "VarName48", "P010_1", "VarName50", "VarName51", "VarName52", "gyroX1", "VarName54", "VarName55", "VarName56", "gyroY1", "VarName58", "VarName59", "VarName60", "gyroZ1", "VarName62", "VarName63", "VarName64", "accX01", "VarName66", "VarName67", "VarName68", "accY01", "VarName70", "VarName71", "VarName72", "accZ01", "VarName74", "VarName75", "VarName76", "Velx1020", "VarName78", "VarName79", "VarName80", "Vely2020", "VarName82", "VarName83", "VarName84", "VelZd1", "VarName86", "VarName87", "VarName88", "attX", "VarName90", "VarName91", "VarName92", "attY", "VarName94", "VarName95", "VarName96", "attZ", "VarName98", "VarName99", "VarName100", "AFCCounterAFC", "VarName102", "VarName103", "VarName104", "SimComF90", "VarName106", "VarName107", "VarName108", "VarName109"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% 导入数据
rawDatReceive = readtable("C:\Users\yudu\Downloads\T250411183105ase.xlsx", opts, "UseExcel", false);

%%
rawDatReceive = table2cell(rawDatReceive);
[rowNum, ~] = size(rawDatReceive);

paraDecode = zeros(rowNum, PARA_NUMBER);
byteTemp = zeros(1, PARA_NUMBER*4);
for i=1:rowNum

    for j=1:PARA_NUMBER*4
        byteTemp(j) = hex2dec(rawDatReceive{i,20+j});%字符串转换为十进制
    end

    paraDecode(i,:) = typecast(uint8(byteTemp),'single');%解析参数
end

%%
xlswrite(targetExcelFile,dataname,'解析后接收','A1');%写入表头
xlswrite(targetExcelFile,rawDatReceive(:,1:20),'解析后接收','A2');%写入数据，从A2开始
xlswrite(targetExcelFile,paraDecode,'解析后接收','U2');%写入数据，从U2开始
fprintf('step 01/02，已生成解析后接收文件%s。\n',targetExcelFile);
%% 清除临时变量
clear opts opts rowNum byteTemp paraDecode dataname rawDatReceive


%% 发送数据：设置导入选项并导入表头
opts = spreadsheetImportOptions("NumVariables", 101);

% 指定工作表和范围
opts.Sheet = "串口发送";
opts.DataRange = "A1:CW1";

% 指定列名称和类型
opts.VariableNames = ["T_s", "T_ns", "dTim", "idThread", "frameNo", "deltNo", "frameLen", "calChk", "rwCounter", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "RcvID", "VarName20", "P0", "VarName22", "VarName23", "VarName24", "P010", "VarName26", "VarName27", "VarName28", "P010_1", "VarName30", "VarName31", "VarName32", "gyroX1", "VarName34", "VarName35", "VarName36", "gyroY1", "VarName38", "VarName39", "VarName40", "gyroZ1", "VarName42", "VarName43", "VarName44", "accX01", "VarName46", "VarName47", "VarName48", "accY01", "VarName50", "VarName51", "VarName52", "accZ01", "VarName54", "VarName55", "VarName56", "LLAX", "VarName58", "VarName59", "VarName60", "LLAY", "VarName62", "VarName63", "VarName64", "LLAZ", "VarName66", "VarName67", "VarName68", "Velx1020", "VarName70", "VarName71", "VarName72", "Vely2020", "VarName74", "VarName75", "VarName76", "VelZd1", "VarName78", "VarName79", "VarName80", "d2", "VarName82", "VarName83", "VarName84", "d3", "VarName86", "VarName87", "VarName88", "attX", "VarName90", "VarName91", "VarName92", "attY", "VarName94", "VarName95", "VarName96", "attZ", "VarName98", "VarName99", "VarName100", "VarName101"];
opts.VariableTypes = ["char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char"];

% 指定变量属性
opts = setvaropts(opts, ["T_s", "T_ns", "dTim", "idThread", "frameNo", "deltNo", "frameLen", "calChk", "rwCounter", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "RcvID", "VarName20", "P0", "VarName22", "VarName23", "VarName24", "P010", "VarName26", "VarName27", "VarName28", "P010_1", "VarName30", "VarName31", "VarName32", "gyroX1", "VarName34", "VarName35", "VarName36", "gyroY1", "VarName38", "VarName39", "VarName40", "gyroZ1", "VarName42", "VarName43", "VarName44", "accX01", "VarName46", "VarName47", "VarName48", "accY01", "VarName50", "VarName51", "VarName52", "accZ01", "VarName54", "VarName55", "VarName56", "LLAX", "VarName58", "VarName59", "VarName60", "LLAY", "VarName62", "VarName63", "VarName64", "LLAZ", "VarName66", "VarName67", "VarName68", "Velx1020", "VarName70", "VarName71", "VarName72", "Vely2020", "VarName74", "VarName75", "VarName76", "VelZd1", "VarName78", "VarName79", "VarName80", "d2", "VarName82", "VarName83", "VarName84", "d3", "VarName86", "VarName87", "VarName88", "attX", "VarName90", "VarName91", "VarName92", "attY", "VarName94", "VarName95", "VarName96", "attZ", "VarName98", "VarName99", "VarName100", "VarName101"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["T_s", "T_ns", "dTim", "idThread", "frameNo", "deltNo", "frameLen", "calChk", "rwCounter", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "RcvID", "VarName20", "P0", "VarName22", "VarName23", "VarName24", "P010", "VarName26", "VarName27", "VarName28", "P010_1", "VarName30", "VarName31", "VarName32", "gyroX1", "VarName34", "VarName35", "VarName36", "gyroY1", "VarName38", "VarName39", "VarName40", "gyroZ1", "VarName42", "VarName43", "VarName44", "accX01", "VarName46", "VarName47", "VarName48", "accY01", "VarName50", "VarName51", "VarName52", "accZ01", "VarName54", "VarName55", "VarName56", "LLAX", "VarName58", "VarName59", "VarName60", "LLAY", "VarName62", "VarName63", "VarName64", "LLAZ", "VarName66", "VarName67", "VarName68", "Velx1020", "VarName70", "VarName71", "VarName72", "Vely2020", "VarName74", "VarName75", "VarName76", "VelZd1", "VarName78", "VarName79", "VarName80", "d2", "VarName82", "VarName83", "VarName84", "d3", "VarName86", "VarName87", "VarName88", "attX", "VarName90", "VarName91", "VarName92", "attY", "VarName94", "VarName95", "VarName96", "attZ", "VarName98", "VarName99", "VarName100", "VarName101"], "EmptyFieldRule", "auto");

% 导入表头数据
rawName = readtable(sourceFile, opts, "UseExcel", false);

rawName = table2cell(rawName);
numIdx = cellfun(@(x) ~isnan(str2double(x)), rawName);
rawName(numIdx) = cellfun(@(x) {str2double(x)}, rawName(numIdx));

PARA_NUMBER = (101-21)/4;

for i=1:PARA_NUMBER+20
    if i<=20
        dataname{1,i} = rawName{1,i};
    else
        dataname{1,i} = sprintf("indx%02d_%s",i-20,rawName{1,(i-21)*4+1+20});
    end
end

% 清除临时变量
clear numIdx opts numIdx
%% %发送数据：设置导入选项并生成目标文件路径
opts = detectImportOptions(sourceFile);

% 指定工作表和范围
opts.Sheet = "串口发送";

% % 指定列名称和类型
opts.VariableNames = ["T_s", "T_ns", "dTim", "idThread", "frameNo", "deltNo", "frameLen", "calChk", "rwCounter", "head0", "head1", "len0", "len1", "counter0", "counter1", "counter2", "counter3", "sendID", "receiveID", "frameID", "send31", "VarName22", "VarName23", "VarName24", "d1", "VarName26", "VarName27", "VarName28", "d2", "VarName30", "VarName31", "VarName32", "d3", "VarName34", "VarName35", "VarName36", "d4", "VarName38", "VarName39", "VarName40", "P0", "VarName42", "VarName43", "VarName44", "P010", "VarName46", "VarName47", "VarName48", "P010_1", "VarName50", "VarName51", "VarName52", "gyroX1", "VarName54", "VarName55", "VarName56", "gyroY1", "VarName58", "VarName59", "VarName60", "gyroZ1", "VarName62", "VarName63", "VarName64", "accX01", "VarName66", "VarName67", "VarName68", "accY01", "VarName70", "VarName71", "VarName72", "accZ01", "VarName74", "VarName75", "VarName76", "Velx1020", "VarName78", "VarName79", "VarName80", "Vely2020", "VarName82", "VarName83", "VarName84", "VelZd1", "VarName86", "VarName87", "VarName88", "attX", "VarName90", "VarName91", "VarName92", "attY", "VarName94", "VarName95", "VarName96", "attZ", "VarName98", "VarName99", "VarName100", "AFCCounterAFC", "VarName102", "VarName103", "VarName104", "SimComF90", "VarName106", "VarName107", "VarName108", "VarName109"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% 导入数据
rawDatReceive = readtable("C:\Users\yudu\Downloads\T250411183105ase.xlsx", opts, "UseExcel", false);

%%
rawDatReceive = table2cell(rawDatReceive);
[rowNum, ~] = size(rawDatReceive);

paraDecode = zeros(rowNum, PARA_NUMBER);
byteTemp = zeros(1, PARA_NUMBER*4);
for i=1:rowNum

    for j=1:PARA_NUMBER*4
        byteTemp(j) = hex2dec(rawDatReceive{i,20+j});%字符串转换为十进制
    end

    paraDecode(i,:) = typecast(uint8(byteTemp),'single');%解析参数
end

%%
xlswrite(targetExcelFile,dataname,'解析后发送','A1');%写入表头
xlswrite(targetExcelFile,rawDatReceive(:,1:20),'解析后发送','A2');%写入数据，从A2开始
xlswrite(targetExcelFile,paraDecode,'解析后发送','U2');%写入数据，从U2开始
fprintf('step 02/02，已生成解析后发送数据文件%s\n',targetExcelFile);
%% 清除临时变量
clear opts opts rowNum byteTemp paraDecode dataname rawDatReceive