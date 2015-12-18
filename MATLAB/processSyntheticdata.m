%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Data analyser for AXIOS system using data from Model              %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 25.11.2015                                      %%
% %%   Version: 1.0                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This program is intended to asses the PIP movement of the index
%finger of a patient recorded by the AXIOS measurement system. This
%programm is only a first version

clear all
close all

%ask user for calibration (new subject) or aditional measurement of existing subject
choice = questdlg('Do you need calibration? First time loading data of this subject?');

if strcmp(choice,'Yes')
    %% calibration and video data generation
    %create synthetic calibration data only flexion
    
    PIP_F = 40; % flexion in degrees
    
    MCP_F = 0; % flexion in degrees
    
    [header,VD,subject,hand]=handModel(PIP_F,0,0,0,MCP_F,0,true);
    
    %calculate center of rotation
    [subject,functionalCoRGlob,functionalCoRLocProx,functionalCoRLocDis]=getCoR(header,subject,VD.L1,VD.L2);
    
    %save calibration measurement
    save('calibration.mat','header','VD','subject','hand');
    clear 'VD';
    
    waitfor(msgbox({'Model with random locatros created, including 60 degree flexion movement for calibration.' 'Data saved under calibration.mat'},'Success'));
    close all
end

%check if subject is already in workspace
if ~(exist('subject','var'))
    %if not get calibration variables from user
    if strcmp(choice,'No')
        [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file with "subject" and "hand" variables');
        load(FileName,'subject','hand');
    end
    
end

% %% create video data for specific movement
% get values from user
prompt = 'Flexion angle [deg]: ';
PIP_F = input(prompt);

prompt = 'Abduction angle (radial)[deg]: ';
PIP_A = input(prompt);

prompt = 'Axial rotation angle [deg]: ';
PIP_R = input(prompt);

prompt = 'Lateral translation (radial)[mm]: ';
PIP_tx = input(prompt);

prompt = 'Saggital translation (palmar)[mm]: ';
PIP_ty = input(prompt);

prompt = 'Axial translation (distal)[mm]: ';
PIP_tz = input(prompt);


PIP_t = [PIP_tx PIP_ty -PIP_tz]'; % translation in mm

MCP_F = (2/3)*PIP_F; % flexion in degrees
MCP_A = 0; % abduction in degrees

[header,VD,subject]=handModel(PIP_F,-PIP_A,PIP_R,PIP_t,MCP_F,MCP_A,false,subject,hand);

%calculate rotation angles
[flexionPIP,abductionPIP,rotationPIP,flexionMCP,abductionMCP,rotationMCP]=getRotAngles(header,VD,subject);

%calculate translation
[translation]=getTranslation(header,VD,subject);
save('measurement.mat','header','VD','subject','flexionPIP','abductionPIP','rotationPIP','translation');

%plot rotation angles and translation
getPlotResults;
