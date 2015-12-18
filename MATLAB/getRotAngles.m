function [flexionPIP,abductionPIP,rotationPIP,flexionMCP,abductionMCP,rotationMCP]=getRotAngles(header,VD,subject)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Calculate rotation angles between L1 and L2                       %%
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
%
%calculates the relativ rotation of L2 araound L1. Movment against
%reference position and in rotation terms along axes of L0


%!not cleaned, still stuf from debugging!

lastFrame = header.NFrames;%get frame numbers
model = subject.Personalien.model; % get model from subject to adjust results


%% get neutral position of hand segments and extract angles
RL1o = [subject.Model.Locator.L1.Q(1,1:3);subject.Model.Locator.L1.Q(1,4:6);subject.Model.Locator.L1.Q(1,7:9)];%*Q_correction;%reference position proximal pahalange
RL2o = [subject.Model.Locator.L2.Q(1,1:3);subject.Model.Locator.L2.Q(1,4:6);subject.Model.Locator.L2.Q(1,7:9)];%reference position intermediate pahalange
RL0o = [1 0 0; 0 1 0;0 0 1];%reference position of hand palm, this matrix due L1 and L2 are measured in relative to it

abductionMCP0 = asin(-RL1o(1,2))*360/2/pi;
flexionMCP0 = acos(RL1o(2,2)/abductionMCP0)*360/2/pi;
rotationMCP0 = acos(RL1o(1,1)/abductionMCP0)*360/2/pi;




Q_ref1 = RL1o'*RL0o;
Q_ref2 = RL2o'*RL0o;

%Q_mov0 = RL1o'*RL2o;
Q_mov0 = Q_ref2'*Q_ref1;

flexionPIP0 = atan(Q_mov0(3,2)/Q_mov0(3,3))*360/2/pi;
abductionPIP0 = -asin(Q_mov0(3,1))*360/2/pi;
rotationPIP0 = atan(Q_mov0(2,1)/Q_mov0(1,1))*360/2/pi;

abductionPIP0 = asin(-RL2o(1,2))*360/2/pi;
    flexionPIP0 = acos(RL2o(2,2)/abductionPIP0)*360/2/pi;
    rotationPIP0 = acos(RL2o(1,1)/abductionPIP0)*360/2/pi;


if strcmp(header.measSystem,'synthetic Data')
    
Q_correction = [1 0 0; 0 1 0;0 0 1];%syntetic data

flexionPIP0 = 0;
abductionPIP0 = 0;
rotationPIP0 = 0;
end


%% get angles between L1 and L2 for each frame

for i= 1:lastFrame
    
    %book theory Zatsiorsky
    %RL1o = [VD.L1.rot(1,1:3);VD.L1.rot(1,4:6);VD.L1.rot(1,7:9)];%reference position proximal pahalange
    RL1l = [VD.L1.rot(i,1:3);VD.L1.rot(i,4:6);VD.L1.rot(i,7:9)];%*Q_correction;%*Q_correction;%actual frame proximal pahalange
    %RL2o = [VD.L2.rot(1,1:3);VD.L2.rot(1,4:6);VD.L2.rot(1,7:9)];%reference position intermediate pahalange
    RL2l = [VD.L2.rot(i,1:3);VD.L2.rot(i,4:6);VD.L2.rot(i,7:9)];%*Q_correction;%actual frame intermediate pahalange
 %   RL0 = [VD.L0.rot(1,1:3);VD.L0.rot(1,4:6);VD.L0.rot(1,7:9)];
    
    %get movement of proximal segment
    Q_movMCP = RL1o'*RL1l;  %calculate relative movment of L1  
    
if (model == 2) || (model == 1) %for glove and artFinger
    flexionMCP(i) = atan(Q_movMCP(3,2)/Q_movMCP(3,3))*360/2/pi;
    abductionMCP(i) = -asin(Q_movMCP(3,1))*360/2/pi;
    rotationMCP(i) = atan(Q_movMCP(2,1)/Q_movMCP(1,1))*360/2/pi;
end

if (model == 0) || (model == 1) %virtual model
    flexionMCP(i) = asin(-Q_movMCP(1,2))*360/2/pi;
    abductionMCP(i) = asin(Q_movMCP(2,2)/acos(Q_movMCP(1,2)))*360/2/pi;
    rotationMCP(i) = asin(Q_movMCP(1,3)/acos(Q_movMCP(1,2)))*360/2/pi;
end    
    
    %get rel. movment of both segments
    Qref1 = RL1o'*RL1l; %get relative movment of L1 to its reference
    Qref2 = RL2o'*RL2l; %get relative movment of L2 to its reference
        
    Q_movPIP(:,:,i) = Qref1'*Qref2; %calculate movment between segments

if (model == 0) || (model == 1) %for glove and artFinger   
    flexionPIP(i) = asin(-Q_movPIP(1,2,i))*360/2/pi;
    abductionPIP(i) = asin(Q_movPIP(3,2,i)/acos(Q_movPIP(1,2,i)))*360/2/pi;
    rotationPIP(i) = asin(Q_movPIP(1,3,i)/acos(Q_movPIP(1,2,i)))*360/2/pi;
end
    
if (model == 2) || (model == 1)%virtual model & artFinger
    flexionPIP(i) = atan(Q_movPIP(3,2,i)/Q_movPIP(3,3,i))*360/2/pi;
    abductionPIP(i) = -asin(Q_movPIP(3,1,i))*360/2/pi;
    rotationPIP(i) = atan(Q_movPIP(2,1,i)/Q_movPIP(1,1,i))*360/2/pi;
end
    
end

%save('fileMCP','flexionPIP0','abductionPIP0','rotationPIP0','abductionMCP0',...
%   'abductionMCP0','rotationMCP0','flexionMCP','abductionMCP','rotationMCP','abductionPIP1','flexionPIP1','rotationPIP1');

%% adjustemnt of the angles to the different models
switch model
    case 0 %glove
        flexionPIP = flexionPIP;
        abductionPIP = abductionPIP;
        rotationPIP = rotationPIP;
    case 1 %artFinger
        temp = flexionPIP;
        flexionPIP = rotationPIP;
        abductionPIP = -abductionPIP;
        rotationPIP = -temp;
    case 2 %virtual model
        abductionPIP = -abductionPIP;
end        


end
