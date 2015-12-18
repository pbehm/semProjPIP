function [translation]=getTranslation(header,VD,subject)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Calculate translation between FCoR on proximal and distal segment %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 23.11.2015                                      %%
% %%   Version: 1.1                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculates translation vector between FCoR of proximal and distal
%segment. Vector is rotated back the movment L1 performed.

% calculate translation from segments
lastFrame = header.NFrames;%get frame numbers
model = subject.Personalien.model; % get model from subject to adjust results


%% get offseterror in neutral position
%CORgp0 = subject.Model.Locator.L1.t'+[subject.Model.Locator.L1.Q(1:3)',subject.Model.Locator.L1.Q(4:6)',subject.Model.Locator.L1.Q(7:9)']*subject.Model.Joint.PIP.ProxSegment;
%CORgd0 = subject.Model.Locator.L2.t'+[subject.Model.Locator.L2.Q(1:3)',subject.Model.Locator.L2.Q(4:6)',subject.Model.Locator.L2.Q(7:9)']*subject.Model.Joint.PIP.DistSegment;
CORgp0 = subject.Model.Locator.L1.t'+[subject.Model.Locator.L1.Q(1:3);subject.Model.Locator.L1.Q(4:6);subject.Model.Locator.L1.Q(7:9)]*subject.Model.Joint.PIP.ProxSegment;
CORgd0 = subject.Model.Locator.L2.t'+[subject.Model.Locator.L2.Q(1:3);subject.Model.Locator.L2.Q(4:6);subject.Model.Locator.L2.Q(7:9)]*subject.Model.Joint.PIP.DistSegment;

delta0 = CORgd0-CORgp0;

for i= 1:lastFrame
    %     
%     CORgp = VD.L1.data(i,:)'+[VD.L1.rot(i,1:3)',VD.L1.rot(i,4:6)',VD.L1.rot(i,7:9)']*subject.Model.Joint.PIP.ProxSegment;%calculate COR in global system from proximal segment
%     CORgd = VD.L2.data(i,:)'+[VD.L2.rot(i,1:3)',VD.L2.rot(i,4:6)',VD.L2.rot(i,7:9)']*subject.Model.Joint.PIP.DistSegment;%calculate COR in global system from proximal segment
%     
%    CORgp(:,i) = VD.L1.data(i,:)'+[VD.L1.rot(i,1:3);VD.L1.rot(i,4:6);VD.L1.rot(i,7:9)]*subject.Model.Joint.PIP.ProxSegment;
 %   CORgd(:,i) = VD.L2.data(i,:)'+[VD.L2.rot(i,1:3);VD.L2.rot(i,4:6);VD.L2.rot(i,7:9)]*subject.Model.Joint.PIP.DistSegment;
    RL1l = [VD.L1.rot(i,1:3);VD.L1.rot(i,4:6);VD.L1.rot(i,7:9)]; %actual orientation L1
    RL1lo = [subject.Model.Locator.L1.Q(1:3);subject.Model.Locator.L1.Q(4:6);subject.Model.Locator.L1.Q(7:9)]; %reference orientation L1
 
 
    CORgp(:,i) = VD.L1.data(i,:)'+[VD.L1.rot(i,1:3);VD.L1.rot(i,4:6);VD.L1.rot(i,7:9)]*subject.Model.Joint.PIP.ProxSegment;
    CORgd(:,i) = VD.L2.data(i,:)'+[VD.L2.rot(i,1:3);VD.L2.rot(i,4:6);VD.L2.rot(i,7:9)]*subject.Model.Joint.PIP.DistSegment;
     
     
    deltaCOR(:,i) =(CORgd(:,i)-CORgp(:,i)-delta0);%calculate drift including offset neutral position

    deltaCOR(:,i) =  (RL1l*RL1lo')'*deltaCOR(:,i); %rotate drift back into anatomical reference by movement of L1 relative to L1 reference

    
end

translation = deltaCOR';

%% adjustemnt of the angles to the different models
temp = translation;

switch model
    case 0 %glove
        translation(:,1) = -temp(:,1);
        translation(:,2) = temp(:,3);
        translation(:,3) = temp(:,2);
    case 1 %artFinger
        translation(:,1) = -temp(:,1);
        translation(:,2) = temp(:,3);
        translation(:,3) = temp(:,2);
    case 2 %virtual model
        translation(:,3) = -temp(:,3);
        
end 


% if strcmp(header.measSystem,'synthetic Data')
%     %transStart = translation(1,:);
%     %transEnd = translation(lastFrame,:);%print last position
%     
%     %plot last COR of both segments into plot
%     plot3(CORgp(1),CORgp(2),CORgp(3),'-oc')
%     plot3(CORgd(1),CORgd(2),CORgd(3),'-oc')
% end

%correction of directions by



end
