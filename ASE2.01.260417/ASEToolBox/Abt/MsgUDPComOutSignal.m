function MsgUDPComOutSignal
% 程序功能：双击DTComOut模块后弹出"确认信号"对话框；
% 若修改并确认，则自动修改对应的信号线名称，否则不进行处理。
% /******************** (C) COPYRIGHT 2024 ACG Tech Group.**********************************************
%  * 作    者 ： 朱小虎、吴莛、曾庆华
%  * 文 件 名 ： MsgDTComOutSignal.m
%  * 描    述 ： DtComOut模块的帧序号处理与参数名处理程序
%  * 版    本 ： V1.01.240104   初版基本功能程序
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：无人飞行控制
%  * 描    述 ： DtComOut模块的参数名处理程序
%  * 版    本 ： V1.01.240104
%  V1.01.240104更改：
%  1）重大修改：针对之前版本无法处理单独DTComOut的情况，对程序进行重新修改；
%  2）说明：由于程序通过DTComOut向前朔源进行查找，目前可区分DTComOut未连接信号线、帧类型码相同情况给出提示；
%  3）双击DTComOut模块后弹出"确认信号"对话框
% **********************(C) COPYRIGHT 2024 ACG Tech Group.***
% clear;
% clc;
 DTcomH = getSimulinkBlockHandle(gcb);%当前DTComOut句柄

 flatDTcom = get_param(DTcomH,'Commented');%当前DTComOut状态，on表示注释，off表示未被注释

 if strcmp(flatDTcom,'off')  %如果DTComOut模块未被注释即处于可用状态

    lineH = get_param(DTcomH,"LineHandles");%DTComOut输入信号线A的句柄

    if lineH.Inport(1,1) ~= -1  %判断DTComOut是否存在输入信号线A，若为-1则不存在

        SourceH = get_param(lineH.Inport,"SrcBlockHandle");%与DTComOut输入信号线A相连的源模块B的句柄

        if SourceH ~= -1  %判断信号线A是否与模块B相连，若为-1则表示未连接

            SourceT = get_param(SourceH,"BlockType");%源模块B的类型

            if strcmp(SourceT,'Mux')  %如果与DTComOut输入信号线相连源模块B的类型为Mux
                SignalLineH = get_param(SourceH,"LineHandles");%则获取Mux输入信号线C的句柄

                [~, colSignal] = size(SignalLineH.Inport);

                if colSignal > 0.5
                    NamesCell = strings(colSignal,1);
                    labelName = strings(colSignal,1);
                    for i = 1:colSignal
                        if SignalLineH.Inport(i) ~= -1  %则获取Mux输入信号线C的名称，默认为空
                            NamesCell(i) = get_param(SignalLineH.Inport(i),'Name');
                            labelName(i) = sprintf("Signal %d",i);%初始化标签
                        else
                            warning("Mux的第%d个输入未连接信号线",i);
                            NamesCell(i) = "";
                            labelName(i) = sprintf("Signal %d（该输入不存在信号线，无法命名）",i);%初始化标签
                        end
                    end

                    SignalName = convertCharsToStrings(NamesCell);

                    fig = uifigure("Name",gcb,"Position",[300 50 260 460]);
                    uit = uitable(fig,"Data",table(SignalName),'ColumnEditable',true,"Position",[20 30 220 420]);
                    uit.RowName = "numbered";

                    uit.DisplayDataChangedFcn = @(src,event) updatePlot(src,SignalLineH);

                end

            else  %如果与DTComOut输入信号线相连源模块B不是Mux类型
                NamesCell = {get_param(lineH.Inport,"Name")};%则直接获取与DTComOut输入信号线A的名称

                if ~isempty(NamesCell)
                    [rowN, colN] = size(NamesCell);
                    if rowN > 0.5
                        labelName = strings(rowN,1);
                        for i = 1:rowN
                            labelName(i) = sprintf("Signal %d",i);
                        end

                        SignalName = convertCharsToStrings(NamesCell);
                        fig = uifigure("Name",gcb,"Position",[300 50 260 460]);
                        uit = uitable(fig,"Data",table(SignalName),'ColumnEditable',true,"Position",[20 30 220 420]);
                        uit.RowName = "numbered";
                        uit.DisplayDataChangedFcn = @(src,event) updatePlot2(src,lineH);

                    end
                else
                    warning('存在DTComOut未与任何信号线连接');
                end
            end

        else
            warning('DTComOut输入信号线未与任何模块连接');
        end

    else
        warning('存在DTComOut未与任何信号线连接');
    end

 else
    warning('当前DTComOut已被注释');
 end
end

function updatePlot(src,SignalLineH)
for i = 1:length(src.Data.SignalName)
    set_param(SignalLineH.Inport(i),'Name',src.Data.SignalName{i,1});
end
end

function updatePlot2(src,LineH)%通过回调函数获取的信号名，使用这些更新后的信号名对模型中的信号线进行修改
for i = 1:length(src.Data.SignalName)
    set_param(LineH.Inport,'Name',src.Data.SignalName{i,1});
end
end