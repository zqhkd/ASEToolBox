% ==========================================================================
%  
% History
% Date        Ver   Description
% 2024/11/10  0.1   Frameword built and MOXA CP-116E-A added.
% 2024/11/17  0.2   Reflective Memory added.
% 
% ==========================================================================

function blkStruct = slblocks  
 
%SLBLOCKS Defines a block library.  
 
% Library's name. The name appears in the Library Browser's  
% contents pane.  
 
blkStruct.Name = ['RT-Manager Driver Blocks' newline 'IO Board Simulink Library'];  
 
% Information for "Blocksets and Toolboxes" subsystem

blkStruct.OpenFcn = ' ';
blkStruct.MaskDisplay = 'disp(''Linux RTOS Based IO Driver Simulink Library which is developped by 湖南卓飞智控科技有限公司 @MATLAB 2023a'')';

% Information for Simulink Library Browser
Browser.Library = 'ASEToolBox';
% Browser.Name    = 'Linux RTOS Based IO Board Drvier Simulink Library';
Browser.Name    = 'ASEToolBox';
Browser.IsFlat  = 0;

blkStruct.Browser = Browser;