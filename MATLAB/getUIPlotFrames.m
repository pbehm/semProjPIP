function [start,ending]=getUIPlotFrames(locator,data,request)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Get start and end frame of sequence from user of AXIOS data       %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 22.11.2015                                      %%
% %%   Version: 1.0                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% To get a start and end frame of the data, the 3d data and one value as
% function of the frames. After certain amount of frames colour of the
% curve is changed.


nFrames = length(data(:,1));

fig = figure; % new figure
subplot(1,2,1); % top left subplot

%3D plot of locator
plot3(data(1:floor(nFrames/4),1),data(1:floor(nFrames/4),2),data(1:floor(nFrames/4),3),'r',...
    data(floor(nFrames/4):floor(2*nFrames/4),1),data(floor(nFrames/4):floor(2*nFrames/4),2),data(floor(nFrames/4):floor(2*nFrames/4),3),'g',...
    data(floor(2*nFrames/4):floor(3*nFrames/4),1),data(floor(2*nFrames/4):floor(3*nFrames/4),2),data(floor(2*nFrames/4):floor(3*nFrames/4),3),'b',...
    data(floor(3*nFrames/4):nFrames,1),data(floor(3*nFrames/4):(nFrames),2),data(floor(3*nFrames/4):(nFrames),3),'m');

%label plot
titleLeft = ['3D plot locator ' locator ' translation of origin'];
title(titleLeft)
xlabel('x-value [mm]');
ylabel('y-value [mm]');
zlabel('z-value [mm]');

subplot(1,2,2); % top right subplot
%2D plot of locator
plot(1:floor(nFrames/4),data(1:floor(nFrames/4),1),'r');
hold on %keep plotting in same plot
plot(floor(nFrames/4):floor(2*nFrames/4),data(floor(nFrames/4):floor(2*nFrames/4),1),'g');
plot(floor(2*nFrames/4):floor(3*nFrames/4),data(floor(2*nFrames/4):floor(3*nFrames/4),1),'b');
plot(floor(3*nFrames/4):floor(4*nFrames/4),data(floor(3*nFrames/4):floor(4*nFrames/4),1),'m');

%label plot
titleRight = ['2D plot locator ' locator ' x translation of origin'];
title(titleRight)
xlabel('frames');
ylabel('x-value [mm]');

hold off

%create box waiting for ui to continue
h = uicontrol('Position',[20 20 200 40],'String','Continue',...
    'Callback','uiresume(gcbf)');
uiwait(gcf);

if (request)%ask user for frame range intput if requested
    %ask user for start and end frame
    
    max = num2str(nFrames);%plot max frame for user
    max = ['Enter end frame (last frame nbr: ' max '):'];
    
    prompt = {'Enter start frame:',max};
    dlg_title = 'Select start and end of needed position/movement';
    num_lines = 1;
    defaultans = {'1','50'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    start = str2num(answer{1,1});%convert inputs from user
    ending = str2num(answer{2,1});%convert inputs from user
else
    start = 0;
    ending = 0;
end

close(fig);%close figure

end