function modelChecked = aseUDPOutSignal(modelName, prjPath)
    % 加载系统并运行一次仿真以获取编译后的模型信息
% /******************** (C) COPYRIGHT 2023 ACG Tech Group.**********************************************
%  * 作    者 ： 朱小虎、吴莛、曾庆华
%  * 文 件 名 ： procDtOutParaName.m
%  * 描    述 ： DtComOut模块的帧序号处理与参数名处理程序
%  * 版    本 ： V1.01.231024   初版基本功能程序
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：无人飞行控制
%  * 描    述 ： DtComOut模块的帧序号处理与参数名处理程序
%  * 版    本 ： V2.01.240104
%  V1.02.231024更改：
%  1）生成的xml文件中每个DTComOut的信号组增加GROUP进行区分，满足软件组需求,
%  2）生成的xml文件对于未做标记的信号进行了补充，默认按DTComOut名称+S序号表示（如DTComOut3_S6），以适配mux源信号未做标记的情况

%  V1.03.231114更改：
%  1）优化功能：修正信号线在没有连接源模块或目的模块报错；
%  2）优化功能：修正模型不存在DTComOut模块时报错；
%  3）优化功能：修正模型存在注释的DTComOut模块仍然会生成信号组的情况。
%  注：吴莛那部分完善中，故暂时注释掉35-37行。

%  V1.04.240102更改：
%  1）优化功能：修正模型不存在DTComOut模块时或DTComOut模块被注释时报错；
%  2）说明：由于程序通过信号线互联进行查找，故该版本暂时无法区分DTComOut模块没有与任何信号线相连的情况。
%
%  V2.01.240104更改：
%  1）重大修改：针对之前版本无法处理单独DTComOut的情况，对程序进行重新修改；
%  2）说明：由于程序通过DTComOut向前朔源进行查找，目前可区分DTComOut未连接信号线、帧类型码相同情况给出提示；
%  3）双击DTComOut模块后弹出"确认信号"对话框，此部分在单独的文件MsgDTComOutSignal.m，与本文件存在区别。
%
%  V2.02.240311更改：
%  1）重大修改：修复原版本无法区分Mux某一个或多个输入信号为多维的情况；
%  
% **********************(C) COPYRIGHT 2023 ACG Tech Group.**********************************************/
    load_system(modelName);
    set_param(modelName, 'SimulationCommand', 'start');
    % % 停止仿真    
    set_param(modelName, 'SimulationCommand', 'pause');
    
    SignalInfor = getDTComOut(modelName);  % 查找当前模型中UDP_scope及其关联的信号线名称
    
    set_param(modelName, 'SimulationCommand', 'stop');

    if size(SignalInfor, 1) >= 1
        % modelChecked = checkDtComOutFrame(SignalInfor);  % 确认模型中DTComOut是否存在帧类型码相同的情况
        writeDtComParaName2Xml(prjPath, SignalInfor);  % 根据信号线名称，生成xml文件
    else
        modelChecked = 2;
    end
end

%%
function SignalInfor = getDTComOut(modelName)
    % 获取模型中DTComOut的连接信号线
    SignalInfor = {};
    allHandle = find_system(modelName, 'FindAll', 'On', 'IncludeCommented', 'off', 'BlockType', 'SubSystem');
    
    if ~isempty(allHandle)
        [rowN, ~] = size(allHandle);
        DTComOutHandle = zeros(rowN, 1);
        
        counter = 0;
        for i = 1:rowN
            if contains(get_param(allHandle(i), 'ReferenceBlock'), "ASEMonitorOut")  % 判断当前打开模块是否为DTcomout
                counter = counter + 1;
                DTComOutHandle(counter) = allHandle(i);
            end
        end

        if counter >= 1
            DTComOutHandle = DTComOutHandle(1:counter, 1);
            SignalInfor = cell(counter, 3);

            for i = 1:counter
                SignalInfor(i, 1) = {getfullname(DTComOutHandle(i))};  % UDP_scope路径
                tempDat = uint16(str2double(get_param(DTComOutHandle(i), 'g_iFrameType')));  % UDP_scope句柄
                SignalInfor(i, 2) = {tempDat};
                SignalInfor(i, 3) = {ProcessDTComOutSignal(modelName, DTComOutHandle(i))};  % 信号名
            end
        end
    end
end

%%
function modelChecked = checkDtComOutFrame(Signaldata)
    % 检查DTComOut模块的帧类型码是否重复
    counterDT = size(Signaldata, 1);
    if counterDT >= 2
        if (length(cell2mat(Signaldata(:, 2))) - length(unique(cell2mat(Signaldata(:, 2))))) ~= 0
            disp("error: Dtcomout帧类型码不能相同，请检查！");
            modelChecked = 0;
        else
            modelChecked = 1;
        end
    elseif counterDT == 1
        warning("Dtcomout数量为1！");
        modelChecked = 1;
    else
        modelChecked = 2;
    end
end

%%
function DTComOUtSignalNames = ProcessDTComOutSignal(modelName, DTcomH)
    % 判断DTComOut模块是否被注释以及获取信号线名称
    flatDTcom = get_param(DTcomH, 'Commented');

    if strcmp(flatDTcom, 'off')
        lineH = get_param(DTcomH, "LineHandles");
        
        if lineH.Inport(1, 1) ~= -1
            SourceH = get_param(lineH.Inport, "SrcBlockHandle");
            
            if SourceH ~= -1
                SourceT = get_param(SourceH, "BlockType");

                if strcmp(SourceT, 'Mux')
                    h = get_param(SourceH, 'PortHandles');
                    
                    dimOutDimen = get_param(h.Outport, 'CompiledPortDimensions');  % 获取Mux输出信号维度
                    dimInputSignal = get_param(h.Inport, 'SignalHierarchy');  % 获取Mux输入信号层级信息
                    dimInputDimen = get_param(h.Inport, 'CompiledPortDimensions');  % 获取Mux输入信号维度信息

                        [rowMux, ~] = size(dimInputSignal);
                    NamesCell = cell(dimOutDimen(2), 1);
                    j = 1;
                    
                    for i = 1:rowMux
                        if dimInputDimen{i, 1}(1, 2) == 1
                            if isempty(dimInputSignal{i, 1}.SignalName)
                                NamesCell{j, 1} = sprintf('S%02d', i);
                            else
                                NamesCell{j, 1} = dimInputSignal{i, 1}.SignalName;
                            end
                            j = j + 1;
                        elseif dimInputDimen{i, 1}(1, 2) > 1.5
                            for k = 1:dimInputDimen{i, 1}(1, 2)
                                NamesCell{j + k - 1, 1} = sprintf('%s_%02d', dimInputSignal{i, 1}.SignalName, k);
                            end
                            j = j + k;
                        end
                    end
                else
                    NamesCell = {get_param(lineH.Inport, "Name")};
                    if NamesCell{1, 1} == ""
                        warning('存在UDP_scope未与任何信号线连接');
                        NamesCell = {'S1'};
                    end
                end
            else
                warning('UDP_scope输入信号线未与任何模块连接');
            end
        else
            warning('存在DTComOut未与任何信号线连接');
        end
    else
        warning('当前UDP_scope已被注释');
    end

    if exist('NamesCell', 'var')
        DTComOUtSignalNames = NamesCell;
    else
        DTComOUtSignalNames = 0;
    end
end

%%
function writeDtComParaName2Xml(prjPath, Signaldata)
    % 将信号信息写入XML文件
    counterDT = size(Signaldata, 1);
    xmlName = fullfile(prjPath, 'WorkShop\aseUDPOutSignalNames.xml');
    
    if counterDT >= 1
        docNode = com.mathworks.xml.XMLUtils.createDocument('obj');
        docRootNode = docNode.getDocumentElement;

        for i = 1:counterDT
            GROUPNode = docNode.createElement('Group');

            IDNode = docNode.createElement('ID');
            IDNode.appendChild(docNode.createTextNode(sprintf('%s', Signaldata{i, 1})));
            GROUPNode.appendChild(IDNode);

            %FrameIDNode = docNode.createElement('Handle');
            FrameIDNode = docNode.createElement('FrameID');
            FrameIDNode.appendChild(docNode.createTextNode(sprintf('%d', Signaldata{i, 2})));
            GROUPNode.appendChild(FrameIDNode);

            elementNum = length(Signaldata{i, 3});
            objNmNode = docNode.createElement('SignalNumber');
            if elementNum >= 1
                objNmNode.appendChild(docNode.createTextNode(sprintf('%d', elementNum)));
            else
                objNmNode.appendChild(docNode.createTextNode(sprintf('%d', elementNum + 1)));
            end
            GROUPNode.appendChild(objNmNode);

            thisElement = docNode.createElement(sprintf('SignalName'));
            GROUPNode.appendChild(thisElement);

            if elementNum > 1
                for j = 1:elementNum
                    dataNode = docNode.createElement(sprintf('Name_%d', j));
                    if isempty(Signaldata{i, 3}{j, 1})
                        dataNode.appendChild(docNode.createTextNode(sprintf('S%d', j)));
                    else
                        dataNode.appendChild(docNode.createTextNode(Signaldata{i, 3}{j, 1}));
                    end
                    thisElement.appendChild(dataNode);
                    docRootNode.appendChild(GROUPNode);
                end
            elseif elementNum == 1
                dataNode = docNode.createElement(sprintf('Name_%d', 1));
                if iscell(Signaldata{i, 3})
                    dataNode.appendChild(docNode.createTextNode(Signaldata{i, 3}));
                elseif isa(Signaldata{i, 3}, 'double')
                    dataNode.appendChild(docNode.createTextNode(sprintf('S1')));
                end
                thisElement.appendChild(dataNode);
                docRootNode.appendChild(GROUPNode);
            end
        end
    end

    docNode.appendChild(docNode.createComment('AFC5_UDP_scope_SignalNames'));
    xmlwrite(xmlName, docNode);
    fprintf('Success:The file %s has been created. And the UDP_scope number is %d!\n', xmlName, counterDT);
end
