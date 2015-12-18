function [VD,header]=importAxiosData()
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Data importer for AXIOS export data                               %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 07.10.2015                                      %%
% %%   Version: 1.0                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this function importes Axios data into matlab. the resulting data
% structure is similar to the one used by the people from HEST (Lorenzetti,
% List,..). This function provides importation of dynamic export data of the
% Axios system, no restrictions on number of Locators and Points.

% subfunctions
%       - getHeaderAxiosCSV(filename); % reads header of imort file 
%       - getDataValue(header,measurement); % reads data of import file
%          ---->function below!!!!!

%BEWARE:
%v1.0   - does ONLY convert the LOCATOR DATA
%       - NO data importet of the single POINTS 
%       - program might be SLOW, no attempts to fasten it done jet
%       - NO ERROR HANDLING implemented jet

%get file
waitfor(msgbox({'Choose the adjusted axios measurement file for import'},'Success'));
[file, folder]=uigetfile('*.csv','Choose a file to import');
filename = fullfile(folder,file);
%filename = '/Users/pascal/Dropbox/PIPSemProject/Axios/data/f10_1032r_philos_destr_adj.csv';%get file path

%% get header and measurement info
header = getHeader(filename);

%% read data and convert to usable form
table = readtable(filename,'Delimiter',';','ReadVariableNames',false,'HeaderLines',1);%skip header
newTable = table2cell(table);%convert table to struct

%delete row with invalud measurements only seen in first line, therefore
%deletion done same as when header has been extracted
index = find([newTable{1:9,6}] == 0);%get row numbers
if ~isempty(index)%only delete if exist
    newTable(index(:),:)=[];
end

header.NFrames = length(newTable(:,1))/header.NmeasSystem;%extract number of recorded frames

%% split data in sets of measurement systems
%get a seperate table with measurement values of each measurement system
%measurement.measSysName1.[nFrames x allValues]
%measurement.measSysName2.[nFrames x allValues]
%...
%measurement.measSysNameN.[nFrames x allValues]


%create cell containing all measurement systems
measurement = cell(header.NmeasSystem,1); %preallocates dimensions of measurements
%first results independently
for k = 1:header.NmeasSystem
            measurement{k,1}(1,:)=newTable(k,:);%copy data from measurement system accordingly
end

%iterate through measurements 2:eof, skip header
for i = header.NmeasSystem+1:header.NmeasSystem:length(newTable(:,1))-1
    %creates cell array that contains tables;
    for k = 1:header.NmeasSystem
            measurement{k,1}(((i-1)/header.NmeasSystem)+1,:)=newTable(i+k-1,:);%copy data from measurement system accordingly
    end
end

%convert into data structure similar structure as used by HEST (Lorenzetti,List,...)
VD = getDataValue(header,measurement);

end


function [VD]=getDataValue(header,measurement)
% header = header information
% measurement = table containing values from each measurement system
%measurement.measSysName1.[nFrames x allValues]
%measurement.measSysName2.[nFrames x allValues]
%...
%measurement.measSysNameN.[nFrames x allValues]

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Data extracotr from AXIOS export data                             %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 08.10.2015                                      %%
% %%   Version: 1.0                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function reads and reformates the export data from the axios
%software. The generated structure is similar to the data strucutre from
%the Vicon system.

% VD =                        VD.LTAS =
%     LTAS: [1x1 struct]               Values: [1x1 struct]
%     LTMS: [1x1 struct]               Unit: 'mm'
%     LTPS: [1x1 struct]
%     SACR: [1x1 struct]
%     RTPS: [1x1 struct]
%     RTMS: [1x1 struct]      VD.LTAS.Values =
%     RTAS: [1x1 struct]                       x_coord: [1194x1 single]
%     LTLH: [1x1 struct]                       y_coord: [1194x1 single]
%     LTLL: [1x1 struct]                       z_coord: [1194x1 single]
%     LTLE: [1x1 struct]                       resid: [1194x1 single] 
%     LTFR: [1x1 struct]
%     LTME: [1x1 struct]
%     LTHF: [1x1 struct]      VD.LTAS.Values.x_coord = 
%     LTTT: [1x1 struct]                              201.3021
%     LTMT: [1x1 struct]                              201.3634
%     LTLF: [1x1 struct]                              201.4396
%     LTLM: [1x1 struct]                              201.4466
%     LTMM: [1x1 struct]                              201.4874
%     LTLC: [1x1 struct]                              ...
%     LTHL: [1x1 struct]                              ...
%     LTHH: [1x1 struct]                              ...
%     LTMC: [1x1 struct]
%     LTVB: [1x1 struct]      VD.LTAS.Values.resid =    
%     LTVM: [1x1 struct]                            0
%     LTTO: [1x1 struct]                            0 = VALID
%     RTLL: [1x1 struct]                            ...
%     RTFR: [1x1 struct]                            ...
%     RTLE: [1x1 struct]                            ...
%     RTME: [1x1 struct]      0 means that all markers are visible

%                             !!!!ATTENTION HERE THE EXPORT DATA FROM AXIOS
%                             IS TRUE FOR A VALID MEASUREMENT. FOR SAKES TO
%                             USE THE HEST PROGRAMMES A LOGICAL NOT IS USED
%
%
%   Import of points not implemented jet.
%   Only locators are imported!
%
%----- ADDITIONAL AXIOS DATA FOR LOCATORS
%
%                               VD.L1.ref = '-'

%                               VD.L1.rot [nxm] n = frames, m = [x y z]
%                                               (translation vector)
%                               
%                               VD.L1.data [nxm] n = frames, m = [R00 ... R22]
%                                               (rotation matrix!)
%
%                               VD.L1.ok = 
%                                       1
%                                       1
%                                       0
%                                       ...
%                                       ...
%                               1 means the obtained measurement was rated
%                               as correct by the AXIOS system


%initialise information about cells containing values
spaceLocatorNn = 4; %fields not important to skip before values
locatorValues = 12; % number of fields containing values
spacePointNn = 2; %fileds not important
pointValues = 3; % number of fields containing values
spacePointPoint = 13;% number of fields to next point within same locator

tempValue = header.locatorPos+spaceLocatorNn; %get Locator fileds and shift position on the first locator value
tempPos = 1; %init temporary position counter

%Create structure with values similar as used by HEST (Lorenzetti, List)
VD = struct('measurementSys', header.measSystem(1,1));%create field containing measurement system
%----------NOT IMPLEMENTED---------->>
%iterate through different measurement systems
%do for each measurement system individually
%<<----------NOT IMPLEMENTED----------

for i = 1:header.Nlocator %iterate through locator positions
    
    for k = 0:locatorValues-1 % iterate through fields with values
      value(1,tempPos) = tempValue(i)+k; %create vector containing field numbers
      tempPos = tempPos+1; %increment temporary position counter
    end
    
    %create similar structure as vicon system ->ONLY DONE WITH LOCATORS =>
    %prepared translation for points
    VD.(char(header.locatorName(1,i))).unit = 'mm';%create field containing unit of measurement
    VD.(char(header.locatorName(1,i))).relative_to = measurement{1,1}{1,tempValue(i)-3};%create field containing reference of current locator 
    
    % information about measurement
    % ATTENTION: this information is inverted compared to the vicon system
    %VD.(char(header.locatorName(1,i))).Values.resid = ~str2int(strrep(measurement{1,1}(:,tempValue(i)-2),',','.')); %create vector containing information if locator is visible
    VD.(char(header.locatorName(1,i))).Values.resid = ~[measurement{1,1}{:,tempValue(i)-2}]'; %create vector containing information if locator is visible
    VD.(char(header.locatorName(1,i))).Values.ok = ~[measurement{1,1}{:,tempValue(i)-1}]'; % create vector if locator measurement is ok
    
    % extend structure due translation and rotation already calculated by axios system 
    % *.data nxm matrix, n=frames ans m=[x y z]
    % *.rot nxm matrix, n=frames ans m=[R00 R01 ... R22]
    VD.(char(header.locatorName(1,i))).data = str2double(strrep(measurement{1,1}(:,tempValue(i):tempValue(i)+2),',','.')); %create matrix containing x
    VD.(char(header.locatorName(1,i))).rot = str2double(strrep(measurement{1,1}(:,tempValue(i)+3:tempValue(i)+11),',','.')); %create matrix containing x
    
end

%adjust locator orientation to anatomic coordinate system
% only done for L1 and L2
%if artFinger

if (false)
    Qorient = [-1 0 0;0 1 0;0 0 -1];
    
    for i=1:header.NFrames
        VD.L1.data(i,:) = Qorient*VD.L1.data(i,:)';
        Qtemp = Qorient*[VD.L1.rot(i,1:3);VD.L1.rot(i,4:6);VD.L1.rot(i,7:9)];
        VD.L1.rot(i,1:3)= Qtemp(1,1:3);
        VD.L1.rot(i,4:6)= Qtemp(2,1:3);
        VD.L1.rot(i,7:9)= Qtemp(3,1:3);
        
        VD.L2.data(i,:) = Qorient*VD.L2.data(i,:)';
        Qtemp = Qorient*[VD.L2.rot(i,1:3);VD.L2.rot(i,4:6);VD.L2.rot(i,7:9)];
        VD.L2.rot(i,1:3)= Qtemp(1,1:3);
        VD.L2.rot(i,4:6)= Qtemp(2,1:3);
        VD.L2.rot(i,7:9)= Qtemp(3,1:3);
        
    end
    
end


%----------NOT IMPLEMENTED---------->>
%convert point values
% startPointPos = length(value)+1; % returns where the point positions start in vector
% 
% tempValue = header.pointPos+spacePointNn; %get position of first point of each locator shift position on the first point value 
% 
% for i = 1:length(tempValue) %iterate through position of first point from each locator 
%     for k = 0:header.locatorNPoints(i)-1 %iterate through number of points from each locator
%         for n = 0:pointValues-1 %iterate through values of point
%             value(1,tempPos) = tempValue(i)+k*spacePointPoint+n; %add cell positions to vector with field numbers
%             tempPos = tempPos+1; %increment temporary position counter
%         end
%     end
% end
%<<----------NOT IMPLEMENTED----------

end

