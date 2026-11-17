function aseUDPInSignal(modelName,prjPath)

% 程序功能：双击DTComIN模块里面的"配置输出信号"按钮后弹出"确认信号"对话框；
% 若修改并点击按钮"确认（使用最新参数）"，则自动修改对应的信号线名称并生成DtComInSignalNames.xml文件
% 若修改并点击按钮"取消（使用原始参数）"，则信号线名称保持初始状态并使用初始状态信号名生成DtComInSignalNames.xml文件。

% 
% /******************** (C) COPYRIGHT 2024 ACG Tech Group.**********************************************
%  * 作    者 ： 朱小虎、曾庆华
%  * 文 件 名 ： MsgDTComInSignal.m
%  * 描    述 ： DtComIn模块的帧序号处理与参数名处理程序
%  * 版    本 ： V1.01.240403   初版基本功能程序
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：无人飞行控制
%  * 描    述 ： DtComOIn模块的参数名处理程序

%  V1.01.240403：
%  1）说明：可处理DTComIn连接Demux或其他模块；
% **********************(C) COPYRIGHT 2024 ACG Tech Group.***
SignalInfor = getDTComIn(modelName);
writeDtComInParaName2Xml(prjPath,SignalInfor);
end

function SignalInfor = getDTComIn(modelName)
% 获取模型中DTComOut的连接信号线
SignalInfor = {};
load_system(modelName);

allHandle = find_system(modelName,'FindAll','On','IncludeCommented','off','BlockType','SubSystem');

if ~isempty(allHandle)

    [rowN, ~] = size(allHandle);
    DTComInHandle = zeros(rowN,1);

    counter = 0;
    for i = 1:rowN
        if(contains(get_param(allHandle(i),'ReferenceBlock'),"ASEMonitorIn"))%判断当前打开模块是否为DTComIn
            counter = counter + 1;
            DTComInHandle(counter) = allHandle(i);
        end
    end

    if counter >= 1
        DTComInHandle = DTComInHandle(1:counter,1);
        SignalInfor = cell(counter,3);

        for i = 1:counter
            SignalInfor(i,1) = {getfullname(DTComInHandle(i))};%DTComOut路径

            tempDat = uint16(str2double(get_param(DTComInHandle(i),'g_iFrameType')));%DTComOut帧类型码
            SignalInfor(i,2) = {tempDat};

            SignalInfor(i,3) = {ProcessDTComInSignal(modelName,DTComInHandle(i))};%信号名

            SignalInfor(i,4) = {DTComInHandle(i)}; %DTComIn句柄
        end
    else
        warning('不存在UDPIn');
    end
end
end

function DTComInSignalNames = ProcessDTComInSignal(modelName,DTcomH)

flagDTcom = get_param(DTcomH,'Commented');%当前DTComIn状态，on表示注释，off表示未被注释

if strcmp(flagDTcom,'off')  %如果DTComIn模块未被注释即处于可用状态

    lineH = get_param(DTcomH,"LineHandles");%DTComIn信号线A的句柄

    if lineH.Outport(1,1) ~= -1  %判断DTComIn的输出端口2是否存在信号线A，若为-1则不存在

        SourceH = get_param(lineH.Outport(1,1),"DstBlockHandle");%与DTComIn输出端口2相连的目的模块B的句柄

        if SourceH ~= -1  %判断DTComIn输出端口2是否与模块B相连，若为-1则表示未连接

            SourceT = get_param(SourceH,"BlockType");%目的模块B的类型

            if strcmp(SourceT,'Demux')  %如果与DTComIn输入信号线相连源模块B的类型为Mux
                SignalLineH = get_param(SourceH,"LineHandles");%则获取Mux输入信号线C的句柄

                [~, colSignal] = size(SignalLineH.Outport);

                if colSignal > 0.5
                    NamesCell = strings(colSignal,1);
                    % NamesType = repmat("编辑框",colSignal,1);
                    % NamesType = categorical(NamesType,{'编辑框','两位开关','三位开关','脉冲按钮','旋钮'});%初始化标签
                    
                    for i = 1:colSignal
                        if SignalLineH.Outport(i) ~= -1  %则获取Mux输入信号线C的名称，默认为空
                            NamesCell(i,1) = get_param(SignalLineH.Outport(i),'Name');                            
                        else
                            warning("Mux的第%d个输入未连接信号线",i);
                            NamesCell(i,1) = "";                           
                        end
                    end

                    DTComInSignalNames= convertCharsToStrings(NamesCell);
                    
                    % vars = ["SignalName";"Type"];
                    % tableData = table(SignalName,NamesType,'VariableNames',vars);
                    % 
                    % figName = sprintf("信号及参数配置：%s",gcb);
                    % fig = uifigure('Name',figName,"Position",[300 200 460 460]);
                    % gl = uigridlayout(fig,[2 1]);
                    % 
                    % gl.RowHeight  = {380,'1x'};
                    % uit = uitable(gl,"Data",tableData,'ColumnEditable',true,"Position",[10 1000 560 560]);
                    % uit.RowName = "numbered";
                    % oriDataTable = uit.Data;
                    % 
                    % btnConfirm = uibutton(fig,"ButtonPushedFcn", @(src,event) ConfirmButtonPushed(uit,SignalLineH));
                    % btnX = 50;
                    % btnY = 15;
                    % btnWidth = 125;
                    % btnHeight = 42;
                    % btnConfirm.Position = [btnX btnY btnWidth btnHeight];
                    % btnConfirm.Text = sprintf('确    认\n[使用最新参数]');
                    % 
                    % btnCancel = uibutton(fig,"ButtonPushedFcn", @(src,event) CancelButtonPushed(uit,oriDataTable));
                    % btnX = 280;
                    % btnY = 15;
                    % btnWidth = 125;
                    % btnHeight = 42;
                    % btnCancel.Position = [btnX btnY btnWidth btnHeight];
                    % btnCancel.Text = sprintf('取    消\n[使用原始参数]');

                end

            else  %如果与DTComIn输入信号线相连源模块B不是Mux类型
                SignalLineH = -1;%不是Mux则标记为-1
                NamesCell = {get_param(lineH.Outport(1,1),"Name")};%则直接获取与DTComIn输入信号线A的名称

                if ~isempty(NamesCell)
                    [rowN, colN] = size(NamesCell);
                    if rowN > 0.5
                        labelName = strings(rowN,1);
                        for i = 1:rowN
                            labelName(i) = sprintf("Signal %d",i);
                        end
                        DTComInSignalNames= convertCharsToStrings(NamesCell);

                        % NamesType = repmat("编辑框",1,1);
                        % NamesType = categorical(NamesType,{'编辑框','两位开关','三位开关','脉冲按钮','旋钮'});%初始化标签
                        % vars = ["SignalName";"Type"];
                        % tableData = table(SignalName,NamesType,'VariableNames',vars);
                        % 
                        % figName = sprintf("信号及参数配置：%s",gcb);
                        % fig = uifigure('Name',figName,"Position",[300 200 460 460]);
                        % gl = uigridlayout(fig,[2 1]);
                        % 
                        % gl.RowHeight  = {380,'1x'};
                        % uit = uitable(gl,"Data",tableData,'ColumnEditable',true,"Position",[10 1000 560 560]);
                        % uit.RowName = "numbered";
                        % oriDataTable = uit.Data;
                        % 
                        % btnConfirm = uibutton(fig,"ButtonPushedFcn", @(src,event) ConfirmButtonPushed(uit,SignalLineH));
                        % btnX = 50;
                        % btnY = 15;
                        % btnWidth = 125;
                        % btnHeight = 42;
                        % btnConfirm.Position = [btnX btnY btnWidth btnHeight];
                        % btnConfirm.Text = sprintf('确    认\n[使用最新参数]');
                        % 
                        % btnCancel = uibutton(fig,"ButtonPushedFcn", @(src,event) CancelButtonPushed(uit,oriDataTable));
                        % btnX = 280;
                        % btnY = 15;
                        % btnWidth = 125;
                        % btnHeight = 42;
                        % btnCancel.Position = [btnX btnY btnWidth btnHeight];
                        % btnCancel.Text = sprintf('取    消\n[使用原始参数]');


                    end
                else
                    warning('存在DTComIn未与任何信号线连接');
                end
            end

        else
            warning('存在DTComIn输入信号线未与任何模块连接');
        end

    else
        warning('存在DTComIn未与任何信号线连接');
    end

else
    warning('存在DTComIn已被注释');
end

end

function writeDtComInParaName2Xml(prjPath,Signaldata)

counterDT = size(Signaldata,1);
xmlName = fullfile(prjPath, 'WorkShop\aseUDPInSignalNames.xml');

if counterDT >= 1
    docNode = com.mathworks.xml.XMLUtils.createDocument('obj');
    docRootNode = docNode.getDocumentElement;

    ModelInfNode = docNode.createElement('ModelInf'); %写入节点ModelInfNode

    info = Simulink.MDLInfo(bdroot);
    if ~isempty(info)
        modelPath = docNode.createElement('ModelName');   %写入当前模型名称，含绝对路径
        modelPath.appendChild(docNode.createTextNode(info.FileName));
        ModelInfNode.appendChild(modelPath);

        ModelVer = info.ModelVersion;
        modelVersion = docNode.createElement('ModelVersion');   %写入当前模型版本号
        modelVersion.appendChild(docNode.createTextNode(ModelVer));
        ModelInfNode.appendChild(modelVersion);
    end

    % info = Simulink.MDLInfo('ASEToolbox');
    % if ~isempty(info)
    %     AFC5ToolBoxVersion = docNode.createElement('ASEToolBoxVersion');   %写入当前工具箱版本号
    %     AFC5ToolBoxVersion.appendChild(docNode.createTextNode(info.ModelVersion));
    %     ModelInfNode.appendChild(AFC5ToolBoxVersion);
    % end
    % 
    % docRootNode.appendChild(ModelInfNode);

    for i = 1:counterDT    %counter为DTComIn个数

        GROUPNode = docNode.createElement('Group'); %写入GROUP

        IDNode = docNode.createElement('ID');   %写入当前DTComIn的路径名
        IDNode.appendChild(docNode.createTextNode(sprintf('%s',Signaldata{i,1})));
        GROUPNode.appendChild(IDNode);

        %FrameIDNode = docNode.createElement('Handle');   %写入当前DTComIn的帧序号
        FrameIDNode = docNode.createElement('FrameID');   %写入当前DTComIn的帧序号
        FrameIDNode.appendChild(docNode.createTextNode(sprintf('%d',Signaldata{i,2})));
        GROUPNode.appendChild(FrameIDNode);

        elementNum = length(Signaldata{i,3});%当前Mux所含的信号个数
        objNmNode = docNode.createElement('SignalNumber');  %写入当前DTComIn的信号数量
        if elementNum >= 1  %大于1个信号的，写入真实数量
            objNmNode.appendChild(docNode.createTextNode(sprintf('%d',elementNum)));
        else  %0个信号的（即用户未作标记的），写入1
            objNmNode.appendChild(docNode.createTextNode(sprintf('%d',elementNum+1)));
        end
        GROUPNode.appendChild(objNmNode);

        thisElement = docNode.createElement(sprintf('SignalName'));
        GROUPNode.appendChild(thisElement);

        if elementNum > 1 %判断当前DTComIn的信号数量,有2个及以上的信号
            for j = 1:elementNum
                dataNode = docNode.createElement(sprintf('Name_%d',j));

                if isempty(Signaldata{i,3}{j,1})
                    dataNode.appendChild(docNode.createTextNode(sprintf('S%d',j)));
                else
                    dataNode.appendChild(docNode.createTextNode(sprintf('%s',Signaldata{i,3}(j,1))));
                end

                thisElement.appendChild(dataNode);
                docRootNode.appendChild(GROUPNode);
            end

        elseif  elementNum==1  %否则只有1个信号
            dataNode = docNode.createElement(sprintf('Name_%d',1));

            if isempty(Signaldata{i,3}{1,1})  %直接使用标记的信号名
                dataNode.appendChild(docNode.createTextNode(sprintf(',%d',Signaldata{i,3}{1,1})));
            else  %否则为0，表示该DTComIn未与除信号线外的其他模块连接
                % dataNode.appendChild(docNode.createTextNode(sprintf('%s,%d',Signaldata{i,3}{1,1},Signaldata{1,4}{1,1})));
                dataNode.appendChild(docNode.createTextNode(sprintf('%s',Signaldata{i,3}(1,1))));
            end

            thisElement.appendChild(dataNode);
            docRootNode.appendChild(GROUPNode);
        else
            
        end
    end
else
    docNode = com.mathworks.xml.XMLUtils.createDocument('obj');
    docRootNode = docNode.getDocumentElement;

    ModelInfNode = docNode.createElement('ModelInf'); %写入节点ModelInfNode

    info = Simulink.MDLInfo(bdroot);
    if ~isempty(info)
        modelPath = docNode.createElement('ModelName');   %写入当前模型名称，含绝对路径
        modelPath.appendChild(docNode.createTextNode(info.FileName));
        ModelInfNode.appendChild(modelPath);

        ModelVer = info.ModelVersion;
        modelVersion = docNode.createElement('ModelVersion');   %写入当前模型版本号
        modelVersion.appendChild(docNode.createTextNode(ModelVer));
        ModelInfNode.appendChild(modelVersion);
    end

    % info = Simulink.MDLInfo('ASEToolbox');
    % if ~isempty(info)
    %     AFC5ToolBoxVersion = docNode.createElement('ASEToolBoxVersion');   %写入当前工具箱版本号
    %     AFC5ToolBoxVersion.appendChild(docNode.createTextNode(info.ModelVersion));
    %     ModelInfNode.appendChild(AFC5ToolBoxVersion);
    % end
    % docRootNode.appendChild(ModelInfNode);
end
if counterDT >= 1
docNode.appendChild(docNode.createComment('ASE_UDPIn_SignalNames'));    %添加注释
xmlwrite(xmlName,docNode);  %写入xml文件
fprintf('Success:The file %s has been created. And the UDPIn number is %d!\n', xmlName, counterDT);
end
end