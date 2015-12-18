% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Data analyser for AXIOS system                                    %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 23.10.2015                                      %%
% %%   Version: 1.0                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This program is intended to asses the PIP movement of the index
%finger of a patient recorded by the AXIOS measurement system. This
%programm is only a first version.

clear all
close all

%ask user for calibration (new subject) or aditional measurement of existing subject
choice = questdlg('Do you need calibration? First time loading data of this subject?');

%% new data
if strcmp(choice,'Yes')
    
    %import data
    [VD,header] = importAxiosData();
    
    %create Subject
    subject = createSubject(header,VD);
    
    %get center of rotation of PIP from relevant data
    [subject,functionalCoRGlob,functionalCoRLocProx,functionalCoRLocDis]=getCoR(header,subject,VD.L1,VD.L2);
    %information
    waitfor(msgbox({'Subject calibrated!'},'OK'));
    
    %save calibration data
    save('calibration.mat','header','VD','subject');
    
    %ask user for further procedure
    choice2 = questdlg('Do you want to continue?');
    
    if strcmp(choice,'Yes') || strcmp(choice,'Cancel')
        clear 'VD','header';%keep only subject variable
    end
    
    close all
end

if strcmp(choice,'No') || strcmp(choice2,'Yes')
    %check if subject is already in workspace
    if ~(exist('subject', 'var'))
        %if no subject in workspace, get calibration variables from user
        waitfor(msgbox({'Calibration data of from subject needed!' 'Please select *.mat file containing calibration data'},'OK'));
        if strcmp(choice,'No')
            [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file containing calibration data: "subject"');
            load(FileName,'subject');
        end
        
    end
    
    %import data
    [VD,header] = importAxiosData();
    
    %calculate rotation angles
    [flexionPIP,abductionPIP,rotationPIP,flexionMCP,abductionMCP,rotationMCP]=getRotAngles(header,VD,subject);
    
    %calculate translation
    [translation]=getTranslation(header,VD,subject);
    save('measurement.mat','header','VD','subject','flexionPIP','abductionPIP','rotationPIP','translation');
    
    %plot rotation angles and translation
    getPlotResults;
    
end