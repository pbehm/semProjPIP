function [header,VD,subject,hand]=HandModelTranslationRotation(PIP_F,PIP_A,PIP_R,PIP_t,MCP_F,MCP_A,calib,subject,hand)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Creation of hand model with moving index finger                   %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 21.09.2015                                      %%
% %%   Aenderungsdatum: 1.12.2015                                        %%
% %%   Version: 1.1                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This program creates an synthetic dataset of PIP joint movment of the indexfinger as it is
% aimed to measure with the AXIOS system. Similar to the AXIOS system the
% output is a rotation matrix and translation vector of a locator. The
% locators L0 (handpalm),L1 (proximal segment) and L2 (intermediate
% segment) of the index finger are generated and saved into a video data VD
% structure. Also a subject file is created where information about
% the generated movment and the resting position of the index finger
% segments are stored.

% This is only the first version, lot of improvment is possible in the
% code!

%1. reference postion of hand containing index finger is created. Random
%oriented locator on proximal and intermediate segment added.
%2. locators Q and t saved in subject file as reference and 50 frames in VD
%file (optionally) plot of the initial hand model
%3. update model for each frame to given movement in indexfinger and save
%each frame in VD (optionally) plot of the final hand model after movement
%4. (optionally) add noise

%When used for calibration, new files (subject, hand and header) are being
%generated. If not used for calibration, a new dataset is created from the
%provided subject, hand and header file. Output only VD.

%load different parameters if calibration wanted
if calib
    %init movements parameters for index finger
    NrefFrames = 50; %50 frames for reference calculation
    NFrames = 30; %how many frames in total
else
    NrefFrames = 0;
    NFrames = 100;
end

%noise parameters
noise = true;
noiseTranslation = 0.06; %noise level in mm optained from static measurement
noiseRot = 0.0935; %value optained from static measurement

%Locator settings
randLocators = false; %place locators with random oientation and location on segment

%plotting settings
plotHand = true; %plot initial and end postion of the hand
plotLocators = false; % plot locators of each frame
plotSpecLocator = [0 4 5]; %only L0, L1 and L2

%% Create Hand model if claibration wanted
%antropometric hand data (anatomical axes)
%only if calibration needed

if calib
    %read antropometric data from subject
    hand.fingers = {'IF' 'MF' 'RF' 'LF' 'TH'};
    hand.segments = {'MC' 'PP' 'IP' 'DP'};
    hand.MC.Q = rotateEulerCardan([1 0 0; 0 1 0; 0 0 1],0,0,0);%possibility to rotate hand palm in room
    hand.MC.t = [0 0 0]';%translation of hand palm origin
    
    %indexfinger
    hand.IF.MC.l=[22 0 -80]';%translation from center of hand palm to MCP joint
    hand.IF.PP.l = [0 0 -45]'; %length proximal phalange
    hand.IF.IP.l = [0 0 -28]'; %length intermediate phalange
    hand.IF.DP.l = [0 0 -25]';%length distal phalange
    
    % data middle finger
    hand.MF.MC.l = [0 0 -80]';%translation from center of hand palm to MCP joint
    hand.MF.PP.l = [0 0 -50]'; %length proximal phalange
    hand.MF.IP.l = [0 0 -30]'; %length intermediate phalange
    hand.MF.DP.l = [0 0 -25]';%length distal phalange
    
    % data ring finger
    hand.RF.MC.l = [-25 0 -75]';%translation from center of hand palm to MCP joint
    hand.RF.PP.l = [0 0 -48]'; %length proximal phalange
    hand.RF.IP.l = [0 0 -30]'; %length intermediate phalange
    hand.RF.DP.l = [0 0 -25]';%length distal phalange
    
    % data little finger
    hand.LF.MC.l = [-48 0 -65]';%translation from center of hand palm to MCP joint
    hand.LF.PP.l = [0 0 -35]'; %length proximal phalange
    hand.LF.IP.l = [0 0 -20]'; %length intermediate phalange
    hand.LF.DP.l = [0 0 -23]';%length distal phalange
    
    % data thumb
    hand.TH.MC.l = [45 40 -45]';%translation from center of hand palm to MCP joint
    hand.TH.PP.l = [10 10 -40]'; %length proximal phalange
    hand.TH.IP.l = [0 0 0]'; %length intermediate phalange =>does not exist
    hand.TH.DP.l = [0 5 -30]';%length distal phalange
end


% data index finger
s_MC_IFMCP = hand.IF.MC.l;%translation from center of hand palm to MCP joint
l_IFPP = hand.IF.PP.l; %length proximal phalange
l_IFIP = hand.IF.IP.l; %length intermediate phalange
l_IFDP = hand.IF.DP.l;%length distal phalange

%% Create Handpalm
%MC as origin
%implies anatomical axis
t_MC = hand.MC.t; %%LOcator L0
Q_MC = hand.MC.Q;%Locator L0/orientation of hand

%% Create fingers
%all segments formed the same way, start at proximal joint and create
%vector, according to antropometric data of bone, with specific rotation.
%End of the vector describes the distal joint

for f=1:length(hand.fingers)
    
    %MC
    hand.([hand.fingers{f}]).MC.s = hand.MC.t +hand.MC.Q*hand.([hand.fingers{f}]).MC.l;
    %create metacarpal segment
    t_IFPP = t_MC + Q_MC*s_MC_IFMCP; %create metacarpal joint by adding
    %metacarpal segment to origin at hand palm. t_IFPP start of proximal
    %segment at MCP joint
    
    %PP
    hand.([hand.fingers{f}]).PP.t = hand.MC.t + hand.MC.Q*hand.([hand.fingers{f}]).MC.l;% get MCP position of proximal phalange
    hand.([hand.fingers{f}]).PP.Q = hand.MC.Q; % rotation of start position
    hand.([hand.fingers{f}]).PP.s = hand.([hand.fingers{f}]).PP.t + hand.([hand.fingers{f}]).PP.Q*hand.([hand.fingers{f}]).PP.l;%create proximal phalange
    
    Q_IFPP = Q_MC;% rotation of start position
    s_IFPIP = t_IFPP + Q_IFPP*l_IFPP;%create proximal phalange
    
    %add locator to proximal phalange
    if strcmp([hand.fingers{f}],'IF') %only add locator on indexfinger
        if randLocators %randomly placed locator
            offsetL1 = rand*(hand.([hand.fingers{f}]).PP.l+[5 5 0]');%random locator position on segment
            locatorL1t = hand.([hand.fingers{f}]).PP.t + hand.([hand.fingers{f}]).PP.Q*offsetL1;%Locator L1
            locatorL1Qo= rotateEulerCardan(Q_MC,rand*90,rand*90,rand*90);%random orientation of Locator L1
            Qrot1=Q_IFPP'*locatorL1Qo;%get relative motion between finger segment and locator
        else
            offsetL1=1/3*hand.([hand.fingers{f}]).PP.l+[-6 0 0]' ;%random locator position on segment
            locatorL1t = hand.([hand.fingers{f}]).PP.t + hand.([hand.fingers{f}]).PP.Q*offsetL1;%Locator L1
            locatorL1Qo= rotateEulerCardan(hand.MC.Q,0,0,0);% orientation of Locator L1 as L0
            Qrot1=Q_IFPP'*locatorL1Qo;%get relative motion between finger segment and locator
        end
        locatorL1Q=locatorL1Qo;
    end
    
    
    %IP
    hand.([hand.fingers{f}]).IP.t = hand.([hand.fingers{f}]).PP.s;% get PIP position of proximal phalange
    hand.([hand.fingers{f}]).IP.Q = hand.MC.Q; % rotation of start position
    hand.([hand.fingers{f}]).IP.s = hand.([hand.fingers{f}]).IP.t + hand.([hand.fingers{f}]).IP.Q*hand.([hand.fingers{f}]).IP.l;%create intermediate phalange
    
    t_IFIP = s_IFPIP;% get PIP position of proximal phalange
    Q_IFIP = Q_MC;% rotation of start position
    s_IFDIP = t_IFIP + Q_IFIP*l_IFIP; %create intermediate phalange
    
    %add locator to intermediate phalange
    if strcmp([hand.fingers{f}],'IF') %only add locator on indexfinger
        if randLocators %randomly placed locator
            offsetL2 = rand*(hand.([hand.fingers{f}]).IP.l+[5 5 0]');%random locator position on segment
            locatorL2t = hand.([hand.fingers{f}]).IP.t + hand.([hand.fingers{f}]).IP.Q*offsetL2;%Locator L2
            locatorL2Qo= rotateEulerCardan(Q_MC,rand*90,rand*90,rand*90);% random orientation of Locator L2
            Qrot2=Q_IFIP'*locatorL2Qo;%get relative rotation between finger segment and locator
        else
            offsetL2=2/3*hand.([hand.fingers{f}]).IP.l+[-6 0 0]';%random locator position on segment
            locatorL2t = hand.([hand.fingers{f}]).IP.t + hand.([hand.fingers{f}]).IP.Q*offsetL2;%Locator L2
            locatorL2Qo= rotateEulerCardan(Q_MC,0,0,0);% random orientation of Locator L2
            Qrot2=Q_IFIP'*locatorL2Qo;%get relative rotation between finger segment and locator
        end
        locatorL2Q=locatorL2Qo;
    end
    
    
    %IFDP
    hand.([hand.fingers{f}]).DP.t = hand.([hand.fingers{f}]).IP.s;% get PIP position of proximal phalange
    hand.([hand.fingers{f}]).DP.Q = hand.MC.Q; % rotation of start position
    hand.([hand.fingers{f}]).DP.s = hand.([hand.fingers{f}]).DP.t + hand.([hand.fingers{f}]).DP.Q*hand.([hand.fingers{f}]).DP.l;%create intermediate phalange
    
    t_IFDP = s_IFDIP;%get DIP postion of proximal segment
    Q_IFDP = Q_MC;% rotation of start position
    s_IFFT = t_IFDP + Q_IFDP*l_IFDP; %create distal phalange
    
end

%% Save locators in VD, header and subject file
%create header
header.Nlocator = 3;
header.locatorName = {'L0','L1','L2'};
header.locatorRef = {'-','L0','L0'};
header.NFrames = NFrames;
header.NmeasSystem = 1;
header.measSystem = 'synthetic Data';

%create subject
subject.Personalien.id = 'synthetic Data';
subject.Personalien.model = 2;
%information about subject incluing simulated movement
subject.Personalien.info.MCP_F = MCP_F; % flexion
subject.Personalien.info.MCP_A = MCP_A; % abduction
subject.Personalien.info.PIP_F = PIP_F; % flexion
subject.Personalien.info.PIP_A = PIP_A; % abduction
subject.Personalien.info.PIP_R = PIP_R; % rotation
subject.Personalien.info.PIP_t = PIP_t; % translation


%save reference position of hand if calibration needed
if calib
    %L0
    subject.Model.Locator.L0.t = hand.MC.t;
    subject.Model.Locator.L0.Q = [hand.MC.Q(1,:) hand.MC.Q(2,:) hand.MC.Q(3,:)];
    %L1
    subject.Model.Locator.L1.t = locatorL1t';
    subject.Model.Locator.L1.Q = [locatorL1Q(1,:) locatorL1Q(2,:) locatorL1Q(3,:)];
    %L2
    subject.Model.Locator.L2.t = locatorL2t';
    subject.Model.Locator.L2.Q = [locatorL2Q(1,:) locatorL2Q(2,:) locatorL2Q(3,:)];
end

%create VD
VD.measurementSys = 'Synthetic Data Generator';
%L0
VD.L0.unit = 'mm';
VD.L0.relative_to = header.locatorName{1,1};
%L1
VD.L1.unit = 'mm';
VD.L1.relative_to = header.locatorName{1,1};
%L0
VD.L2.unit = 'mm';
VD.L2.relative_to = header.locatorName{1,1};

%% not needed!
if calib
    %create first 50 referencevalues
    for i = 1:length(header.locatorName(1,:)) %iteration through locators
        for k = 1:NrefFrames
            VD.(char(header.locatorName(1,i))).data(k,:) = subject.Model.Locator.(char(header.locatorName(1,i))).t;
            VD.(char(header.locatorName(1,i))).rot(k,:) = subject.Model.Locator.(char(header.locatorName(1,i))).Q;
            VD.(char(header.locatorName(1,i))).Values.resid(k,1) = 0;
            VD.(char(header.locatorName(1,i))).Values.ok(k,1) = 0;
        end
    end
end

%%



%% plot model in standart position
%plot segments
if plotHand
    for f=1:length(hand.fingers)%iterate through fingers
        %hand palm, MCP
        g_MC = [hand.MC.t';hand.([hand.fingers{f}]).MC.s'];
        plot3(g_MC(:,1),g_MC(:,2),g_MC(:,3),'-or');
        hold on
        axis equal
        xlabel('xAchse')
        ylabel('yAchse')
        
        %IFPP
        g_IFPP = [hand.([hand.fingers{f}]).PP.t';hand.([hand.fingers{f}]).PP.s'];
        plot3(g_IFPP(:,1),g_IFPP(:,2),g_IFPP(:,3),'-ob');
        
        %IFIP
        g_IFIP = [hand.([hand.fingers{f}]).IP.t';hand.([hand.fingers{f}]).IP.s'];
        plot3(g_IFIP(:,1),g_IFIP(:,2),g_IFIP(:,3),'-om');
        
        %IFDP
        g_IFDP = [hand.([hand.fingers{f}]).DP.t';hand.([hand.fingers{f}]).DP.s'];
        plot3(g_IFDP(:,1),g_IFDP(:,2),g_IFDP(:,3),'-oc');
    end
end

%plot locators
if plotLocators
    %plot all locators L0,L1,L2,MC,PIP,DIP
    locatororig = [hand.MC.t';hand.IF.PP.t';hand.IF.IP.t';hand.IF.DP.t';locatorL1t';locatorL2t'];
    locatordirect = [hand.MC.Q;hand.IF.PP.Q;hand.IF.IP.Q;hand.IF.DP.Q;locatorL1Q;locatorL2Q];
    
    %plot only L0,L1,L2
    %locatororig = [hand.MC.t';locatorL1t';locatorL2t'];
    %locatordirect = [hand.MC.Q;locatorL1Q;locatorL2Q];
    
    plot3(locatororig(:,1),locatororig(:,2),locatororig(:,3),'xb')%plot locator origins
    
    for i = 0:length(locatororig)-1
        quiver3(locatororig(i+1,1),locatororig(i+1,2),locatororig(i+1,3),...
            locatordirect(i*3+1,1)',locatordirect(i*3+2,1)',locatordirect(i*3+3,1)','r');%plot x unit vector
        quiver3(locatororig(i+1,1),locatororig(i+1,2),locatororig(i+1,3),...
            locatordirect(i*3+1,2)',locatordirect(i*3+2,2)',locatordirect(i*3+3,2)','g');%plot y unit vector
        quiver3(locatororig(i+1,1),locatororig(i+1,2),locatororig(i+1,3),...
            locatordirect(i*3+1,3)',locatordirect(i*3+2,3)',locatordirect(i*3+3,3)','b');%plot z unit vector
    end
end

%% create movement per angle

MCP_Fx = MCP_F/(NFrames); % flexion in degrees
MCP_Ax = MCP_A/(NFrames); % abduction in degrees
PIP_Fx = PIP_F/(NFrames); % flexion in degrees
PIP_Ax = PIP_A/(NFrames); % abduction in degrees
PIP_Rx = PIP_R/(NFrames); % rotation in degrees
PIP_tx = PIP_t/(NFrames); % translation in mm

%update movement in model for each frame
for counter = 1:NFrames
    
    % get Movment angles
    % MCP 2DOF
    MCP_F = counter*MCP_Fx*(2*pi/360); %rot around x axis = flexion/extension
    MCP_A = counter*MCP_Ax*(2*pi/360); %rot around y axis = abduction/aduction
    
    Rx_MCP=[1 0 0;0 cos(MCP_F) -sin(MCP_F);0 sin(MCP_F) cos(MCP_F)];
    Ry_MCP=[cos(MCP_A) 0 sin(MCP_A);0 1 0;-sin(MCP_A) 0 cos(MCP_A)];
    
    MCP_Q = Ry_MCP * Rx_MCP;%rotation matrix from MCP
    %MCP_Q = Q_MC*MCP_Q;
    
    % PIP 6DOF
    PIP_t = counter*PIP_tx; %translation of IFIP against IFPP
    
    PIP_F = counter*PIP_Fx*(2*pi/360); %rot flexion/extension
    PIP_A = counter*PIP_Ax*(2*pi/360); %rot abduction/aduction
    PIP_R = counter*PIP_Rx*(2*pi/360); %rot rotation
    
    Rx_PIP=[1 0 0;0 cos(PIP_F) -sin(PIP_F);0 sin(PIP_F) cos(PIP_F)];
    Ry_PIP=[cos(PIP_A) 0 sin(PIP_A);0 1 0;-sin(PIP_A) 0 cos(PIP_A)];
    Rz_PIP=[cos(PIP_R) -sin(PIP_R) 0;sin(PIP_R) cos(PIP_R) 0;0 0 1];
    
    PIP_Q = Rz_PIP*Ry_PIP*Rx_PIP;%rotation matrix from PIP
    
    
    % DIP 1DOF
    DIP_F = PIP_F*2/3;%estimated radom flexion of distal part
    
    Rx_DIP=[1 0 0;0 cos(DIP_F) -sin(DIP_F);0 sin(DIP_F) cos(DIP_F)];
    
    DIP_Q = Rx_DIP;%rotation matrix from DIP
    
    %% calculate Movment of segments as movement chain
    
    
    %% update IF
    %MC
    t_IFPP = t_MC + Q_MC*s_MC_IFMCP;% create metacarpal segment from hand palm
    
    %IFPP
    Q_IFPP = Q_MC*MCP_Q ;
 %Q_IFPP = MCP_Q*Q_MC;
    s_IFPIP = t_IFPP + Q_IFPP*l_IFPP;%create proximal phalange
    %add locator to proximal segment
    locatorL1t = t_IFPP +Q_IFPP*offsetL1;%Locator L1 on proximal phalange
    
    locatorL1Q= Q_IFPP';
    
    %locatorL1Q= Q_IFPP*Qrot1;%%Locator L1, rotate locator pp
    %locatorL1Q= locatorL1Qo*MCP_Q;%Locator L1 rotate locator system like pp
    %locatorL1Q= MCP_Q*locatorL1Qo
    
    %IFIP
    t_IFIP = t_IFPP + Q_IFPP*(l_IFPP+PIP_t);%get PIP from from proximal segment
    Q_IFIP = Q_IFPP*PIP_Q;%rotate intermedial phalange in relation to proximal segment

  %  Q_IFIP = PIP_Q*Q_IFPP;%rotate intermedial phalange in relation to proximal segment
    s_IFDIP = t_IFIP + Q_IFIP*l_IFIP; %create intermediate phalange
    %add locator to intermediate segment
    locatorL2t = t_IFIP + Q_IFIP*offsetL2;%Locator L2
    
    locatorL2Q=  Q_IFIP';
    
    %locatorL2Q=  Q_IFIP*Qrot2;%
    %locatorL2Q=  locatorL2Qo*MCP_Q*PIP_Q;%Locator L2
    %locatorL2Q=  MCP_Q*PIP_Q*locatorL2Qo;%Locator L2
    
    %IFDP
    t_IFDP = s_IFDIP;%get DIP from from intermediate segment
   % Q_IFDP = DIP_Q*Q_IFIP;%rotate distal segment
    Q_IFDP = Q_IFIP*DIP_Q;
    s_IFFT = t_IFDP + Q_IFDP*l_IFDP;%create distal segment
    
    %save calculated data in VD
    
    k = counter;%+NrefFrames; %for k = 1:50
    VD.L0.data(k,:) = subject.Model.Locator.L0.t;
    VD.L0.rot(k,:) = subject.Model.Locator.L0.Q;
    VD.L0.Values.resid(k,1) = 0;
    VD.L0.Values.ok(k,1) = 0;
    
    VD.L1.data(k,:) = locatorL1t;
    VD.L1.rot(k,:) = [locatorL1Q(1,:) locatorL1Q(2,:) locatorL1Q(3,:)];
    VD.L1.Values.resid(k,1) = 0;
    VD.L1.Values.ok(k,1) = 0;
    
    VD.L2.data(k,:) = locatorL2t;
    VD.L2.rot(k,:) = [locatorL2Q(1,:) locatorL2Q(2,:) locatorL2Q(3,:)];
    VD.L2.Values.resid(k,1) = 0;
    VD.L2.Values.ok(k,1) = 0;
    
    
    %plot segments and locators only at end position, plot center of locators
    %inbetween
    if (counter == NFrames) || (counter == NFrames/3) || (counter == 2*NFrames/3) %plot hand segments in final position
        
        %hand palm, MCP
        g_MC = [t_MC';hand.IF.MC.s'];
        
        plot3(g_MC(:,1),g_MC(:,2),g_MC(:,3),'-og');
        hold on
        
        %IFPP
        g_IFPP = [t_IFPP';s_IFPIP'];
        plot3(g_IFPP(:,1),g_IFPP(:,2),g_IFPP(:,3),'-og');
        
        
        %IFIP
        g_IFIP = [t_IFIP';s_IFDIP'];
        plot3(g_IFIP(:,1),g_IFIP(:,2),g_IFIP(:,3),'-og');
        
        %IFIP
        g_IFDP = [t_IFDP';s_IFFT'];
        plot3(g_IFDP(:,1),g_IFDP(:,2),g_IFDP(:,3),'-og');
        
        xlabel('xAchse')
        ylabel('yAchse')
        
        
        %plot locators at final position
        if plotLocators
            %plot L0,L1,L2,MCP,PIP,DIP
            locatororig = [t_MC';t_IFPP';t_IFIP';t_IFDP';locatorL1t';locatorL2t'];
            locatordirect = [Q_MC;Q_IFPP;Q_IFIP;Q_IFDP;locatorL1Q;locatorL2Q];
            
            %plot only L0,L1,L2
            %locatororig = [t_MC';locatorL1t';locatorL2t'];
            %locatordirect = [Q_MC;locatorL1Q;locatorL2Q];
            
            plot3(locatororig(:,1),locatororig(:,2),locatororig(:,3),'xb')%plot locator origins
            hold on
            for i = 0:length(locatororig)-1
                quiver3(locatororig(i+1,1),locatororig(i+1,2),locatororig(i+1,3),...
                    locatordirect(i*3+1,1)',locatordirect(i*3+2,1)',locatordirect(i*3+3,1)','r');%plot x unit vector
                quiver3(locatororig(i+1,1),locatororig(i+1,2),locatororig(i+1,3),...
                    locatordirect(i*3+1,2)',locatordirect(i*3+2,2)',locatordirect(i*3+3,2)','g');%plot y unit vector
                quiver3(locatororig(i+1,1),locatororig(i+1,2),locatororig(i+1,3),...
                    locatordirect(i*3+1,3)',locatordirect(i*3+2,3)',locatordirect(i*3+3,3)','b');%plot z unit vector
            end
        end
        
    else
        %plot during movment
        if plotLocators
            %plot locators and joint centers
            %locatororig = [t_MC';t_IFPP';t_IFIP';t_IFDP';locatorL1t';locatorL2t'];
            
            %only plot locators L0,L1 and L2
            locatororig = [t_MC';locatorL1t';locatorL2t'];
            
            plot3(locatororig(:,1),locatororig(:,2),locatororig(:,3),'xb')%plot locator origins
            hold on
        end
    end
    
end

% add noise to data
if noise
    for i = 1:length(header.locatorName(1,:)) %iteration through locators
        r = -noiseTranslation + (2*noiseTranslation).*rand(size(VD.(char(header.locatorName(1,i))).data));
        VD.(char(header.locatorName(1,i))).data = VD.(char(header.locatorName(1,i))).data+r;
        
        %r = -noiseRot +
        %(2*noiseRot).*rand(size(VD.(char(header.locatorName(1,i))).rot));%!numerical
        %problems
        for k=1:length(VD.(char(header.locatorName(1,i))).rot(:,1))
            Q = [VD.(char(header.locatorName(1,i))).rot(k,1:3);VD.(char(header.locatorName(1,i))).rot(k,4:6);VD.(char(header.locatorName(1,i))).rot(k,7:9)];
            Q_noisy = rotateEulerCardan(Q,rand*noiseRot,rand*noiseRot,rand*noiseRot);
            VD.(char(header.locatorName(1,i))).rot(k,:) = [Q_noisy(1:3) Q_noisy(4:6) Q_noisy(7:9)];
        end
    end
end

end


function Q_new = rotateEulerCardan(Q_old, alpha, beta, gamma)
%function rotates a rotation matrix about alpha (x-axis), beta (y-axis) and
%gamma (z-axis). Rotation oder as mentioned. Implies alpha
%flexion/extension, beta abduction/adduction and gamma axial rotation

rotX = alpha*(2*pi/360); %rot around x axis
rotY = beta*(2*pi/360); %rot around y axis
rotZ = gamma*(2*pi/360); %rot around z axis

%rotation matrices
Rx=[1 0 0;0 cos(rotX) -sin(rotX);0 sin(rotX) cos(rotX)];
Ry=[cos(rotY) 0 sin(rotY);0 1 0;-sin(rotY) 0 cos(rotY)];
Rz=[cos(rotZ) -sin(rotZ) 0;sin(rotZ) cos(rotZ) 0;0 0 1];

Q_new=Rz*Ry*Rx*Q_old; %rotation

end