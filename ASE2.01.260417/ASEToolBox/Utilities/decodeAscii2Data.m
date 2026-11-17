%用于解析txt文本数据(A5 DA AC 00...)【可通过txt编辑的数据文件】
%版本V1.01
%By zhuxh
%%
clc;
clear;
sourceDatFile = 'T250416.txt';
targetExcelFile = strrep(sourceDatFile,".txt","txt.xlsx");%待存储的文件路径;

fileID = fopen(sourceDatFile,'r');

A = fscanf(fileID,'%c');

fclose(fileID);

% 将十六进制字符串转换为数值
hexValues = split(A); % 按空格分割
hexValues = hexValues(~cellfun('isempty', hexValues)); % 移除空值
A = hex2dec(hexValues); % 将十六进制字符串转换为十进制数值

data = [];
Len = size(A,1);
p = 1;%帧索引
n = 1;%字节索引

FRAME_LENGTH = 92;
PARA_NUM = 20;

while(n<=Len-FRAME_LENGTH)
    if((A(n,1) == 165) && (A(n+1,1) == 218) && (A(n+2,1) == FRAME_LENGTH) && (A(n+3,1) == 0)) %判帧头和帧长度，如果正确则存储并把帧数目加一、索引增加28（28为帧长度）
        data(p,1:FRAME_LENGTH) = A(n:n+FRAME_LENGTH-1,1);
        p=p+1;
        n=n+FRAME_LENGTH;
    else %否则索引加1再判帧头、帧长度
        n=n+1;
    end
end
% B = dec2hex(A);
%%
dataDecode = zeros(p-1,PARA_NUM+2);%第一列counter,第二列校验和，后面40个为解析后参数

for i = 1:p-1

    dataDecode(i,1) = typecast(uint8(data(i,5:8)),'uint32');  %解析帧计数

    % 计算校验和（172 字节累加和取低 8 位）
    checksum = mod(sum(data(i,:)), 256);
    if checksum == 0
        dataDecode(i,2) = 0;%计算累加和
    else
        dataDecode(i,2) = 1;%计算累加和
    end

    dataDecode(i,3:end) = typecast(uint8(data(i,12:FRAME_LENGTH-1)),'single');%解析参数

end

%%
dataname = {'01帧计数','02帧校验','P0x','P0y','P0z','gyroX','gyroY','gyroz','accX','accY','accZ',...
    'GpsPosX','GpsPosY','GpsPosZ','GpsVelX','GpsVelY','GpsVelZ','gam','psi','phi','AfcCounter','SyncSim'};
xlswrite(targetExcelFile,dataname,'sheet1','A1');%写入表头
xlswrite(targetExcelFile,dataDecode,'sheet1','A2');%写入数据，从A2开始