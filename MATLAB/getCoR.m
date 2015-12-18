function [subject,functionalCoRGlob,functionalCoRLocProx,functionalCoRLocDis]=getCoR(header,subject,proxSegment,distSegment)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Calculate CoR from two relative moving segments                   %%
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

%This function calculates the CoR of the projected points from distal
%segment into proximal segment. Sphere fitting is used.

% ! Axis of rotation is not implemented!

plotPoints = false;

%% project movement of intermediate segment(L2) around proximal segment(L1)
delta = distSegment.data-proxSegment.data;%relative movment of L2 against L1

for i = 1:header.NFrames
    projectionLocator(i,:)=transpose([proxSegment.rot(i,1:3);proxSegment.rot(i,4:6);proxSegment.rot(i,7:9)])*delta(i,:)';%projection of intermediate segment in proximal segment at each frame
end

%% reduce data only data containing movment
%plot projection for visualisation and extraction of movment that user can
%select best frames containing the motion. When Input data is synthetic
%data, only data used from 51:end, due synthetic data generator takes the
%first 50 frames for reference.
if strcmp(subject.Personalien.id,'synthetic Data')
    start = 1;
    ending = header.NFrames;
    plotPoints = true;
    projectionLocator = projectionLocator(start:ending,:);
    exportPoints = projectionLocator;
    save('filename','exportPoints');
else
    waitfor(msgbox({'Please select frames of flexion movment'},'OK'));
    [start,ending]=getUIPlotFrames('L2 vs L1',projectionLocator,true);
    %reduce dataset to movment frames
    projectionLocator = projectionLocator(start:ending,:);
    exportPoints = projectionLocator;
    save('filename','exportPoints');
end

%% calculate center of rotation
% Fit sphere into projection of L2 on proximal segment
% with simulated data not stable due to almost singular matrix...problem yields from a movement
% in plane
% not representative due to noise from measurement
% stable when noise added
[functionalCoRLocProx,radius,residual] = spherefit(projectionLocator)
%plot3(functionalCoRLocProx(1),functionalCoRLocProx(2),functionalCoRLocProx(3),'xr');
if radius>=50
    display('CoR: Radius >= 50mm!')
end

%% calculate axis of rotation
% not implemented

%% save COR into subject
% transform CoR in standart position into global coordinate system
functionalCoRGlob = proxSegment.data(1,:)' + [proxSegment.rot(1,1:3);proxSegment.rot(1,4:6);proxSegment.rot(1,7:9)]*functionalCoRLocProx

%transform CoR on standart position into local coordinate system distal segment
functionalCoRLocDis = transpose([distSegment.rot(1,1:3);distSegment.rot(1,4:6);distSegment.rot(1,7:9)])*(functionalCoRGlob-distSegment.data(1,:)')

%save data into subject file
subject.Model.Joint.PIP.ProxSegment = functionalCoRLocProx;
subject.Model.Joint.PIP.DistSegment = functionalCoRLocDis;
subject.Model.Joint.PIP.AxiosSegment = functionalCoRGlob;

if strcmp(subject.Personalien.id,'synthetic Data')
    if plotPoints
        %plot into visualisation of hand model
        hold on
        plot3(projectionLocator(:,1),projectionLocator(:,2),projectionLocator(:,3),'xg');
        plot3(functionalCoRLocProx(1),functionalCoRLocProx(2),functionalCoRLocProx(3),'oc');
        plot3(functionalCoRGlob(1),functionalCoRGlob(2),functionalCoRGlob(3),'xr');
        plot3(functionalCoRLocDis(1),functionalCoRLocDis(2),functionalCoRLocDis(3),'om');
%        quiver3(functionalCoRLocProx(1),functionalCoRLocProx(2),functionalCoRLocProx(3),u1(1),u1(2),u1(3),'g');
        hold off
    end
else
    %plot a new graph containing the measured points and calculated center
    %of rotation
    showCOR = figure;
    plot3(projectionLocator(:,1),projectionLocator(:,2),projectionLocator(:,3),'xb');
    hold on
    plot3(functionalCoRLocProx(1),functionalCoRLocProx(2),functionalCoRLocProx(3),'xr');
%    quiver3(functionalCoRLocProx(1),functionalCoRLocProx(2),functionalCoRLocProx(3),u1(1),u1(2),u1(3),'g');
    hold off
    h = uicontrol('Position',[20 20 200 40],'String','Continue',...
        'Callback','uiresume(gcbf)');
    uiwait(gcf);
    close(showCOR);
    
    %
    %     [~,~] = getUIPlotFrames('L2 projected into L1',projectionLocator,false);
    %     hold on
    %     plot3(functionalCoRLocProx(1),functionalCoRLocProx(2),functionalCoRLocProx(3),'xr');
    %     hold off
end

function [center,radius,residuals] = spherefit(x,y,z)
% Fit a sphere to data using the least squares approach.
%
% adapted from Alan Jennings


narginchk(1,3);
n = size(x,1);
switch nargin  % n x 3 matrix
    case 1
        validateattributes(x, {'numeric'}, {'2d','real','size',[n,3]});
        z = x(:,3);
        y = x(:,2);
        x = x(:,1);
    otherwise  % three x,y,z vectors
        validateattributes(x, {'numeric'}, {'real','vector'});
        validateattributes(y, {'numeric'}, {'real','vector'});
        validateattributes(z, {'numeric'}, {'real','vector'});
        x = x(:);  % force into columns
        y = y(:);
        z = z(:);
        validateattributes(x, {'numeric'}, {'size',[n,1]});
        validateattributes(y, {'numeric'}, {'size',[n,1]});
        validateattributes(z, {'numeric'}, {'size',[n,1]});
end

% solve linear system of normal equations
A = [x, y, z, ones(size(x))];
b = -(x.^2 + y.^2 + z.^2);
a = A \ b;

% return center coordinates and sphere radius
center = -a(1:3)./2;
radius = realsqrt(sum(center.^2)-a(4));

if nargout > 2
	% calculate residuals
   residuals = radius - sqrt(sum(bsxfun(@minus,[x y z],center.').^2,2));
elseif nargout > 1
	% skip
else
    % plot sphere
    hold all;
	sphere_gd(6,radius,center);
    hold off;
end

