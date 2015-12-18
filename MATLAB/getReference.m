function [subject] = getReference(subject,header,VD)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Calculate refrence position from AXIOS data                       %%
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

%% calculate references
%calculate reference from values
%idea next version: only use first measurements that were judeged with ok
%axios data: user selects frames during time when locators were in neutral
%postion
%synthetic data: as created by the function the first 50 values are in
%neutral position

subject.Model.LocatorName = header.locatorName;
plotNbrFrames = false;

if strcmp(subject.Personalien.id,'synth data')
    start = 1;
    ending = 50;
else
    waitfor(msgbox({'Reference of locators being calculated' 'Please select start and ending frame of neutral position during measurement'},'Success'));%wait till user acknowledges
    
    %get frames from neutral position of the hand, L0 very stable when hand
    %on table
    [start,ending]=getUIPlotFrames('L0',VD.L0.data,true);
    
    close all
end

if (plotNbrFrames)
    denum = ending+1-start; %define frames to calculate the reference of
    
    disp(['Anzahl frames zur Ermittlung der Referenzsegmente: ' ...
        num2str(denum)])
    disp(' ');
end

for i=1:length(header.locatorName)
    %calculate mean for all coordinates of one segment
    subject.Model.Locator.(header.locatorName{i}).t = mean(VD.(header.locatorName{i}).data(start:ending,:));
    subject.Model.Locator.(header.locatorName{i}).Q = mean(VD.(header.locatorName{i}).rot(start:ending,:));
end



end