function [header]=getHeader(filename)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Header extractor from AXIOS export data                           %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 02.10.2015                                      %%
% %%   Version: 1.0                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function extracts all information about the measurement from the
% first ten lines of the exported file from the axios system. All
% information ist stored in 'header' structure.
% no debugging implemented!

%% Check input arguments
if nargin<1
    %header.filename = questdlg('Please choose a file','Side','Right','Left','Right');%check correct input
    %[FileName,PathName,FilterIndex] = uigetfile(FilterSpec)
    msgbox('No correct file selected for header export, not implemented yet')
else
    header.filename = filename;     %add filename to header
end
    
%% Initialize variables.
%header.filename = '/Users/pascal/Dropbox/PIPSemProject/Axios/data/f10_1032r_philos_destr_adj.csv';
delimiter = ';';                %delimiter character between data
axiosDataDelimiter = '|';       %delimiter character between axios data: measurementsystem,locator1,locator2,...|LoC1,point1,point2,..,pointN|...|LoCN,point1,point2,..,pointN|
endRow = 10;                    %number of header lines 10-1=9 ->max 9 measurement systems

header.pointLength = 13;        %number of cells used to safe point data
formatSpec = '%s';
uniLocator = 'relative_to';     %unique word in header within locators

%% Extract header of the text file.
%maybe faster with fgetl?!
fileID = fopen(header.filename,'r'); %open file
headerString = textscan(fileID, formatSpec, endRow); %read first ten lines of file
headerString = headerString{1,1}; %read first ten lines of file
fclose(fileID); %% close the file.

%% Extract relevant parameters from header string
headerArray = strsplit(headerString{1,1}, delimiter); %Split first line of header at delimiter character

%convert first nine datalines into array
for i = 2:length(headerString(:,1))
    sampleArray(i-1,:) = strsplit(headerString{i,1}, delimiter); %Split line at delimiter character save in array
end

% Search for Locators
header.locatorPos = find(cellfun(@(x) strcmp(x,uniLocator), headerArray))-1;%returns cell numbers with LocName in header line
header.Nlocator = length(header.locatorPos);%number of locators

for i = 1:header.Nlocator %iterate through locator cells
   header.locatorName(1,i) = sampleArray(1,header.locatorPos(1,i));%get names of locators
   header.locatorRef(1,i) = sampleArray(1,header.locatorPos(1,i));%get locator reference
end

% Search for points
header.pointPos = find(cellfun(@(x) strcmp(x,axiosDataDelimiter), sampleArray(1,:)));%returns cell numbers with data split character in second line
header.pointPos = header.pointPos + 2;%shift on correct field 
NdataSplit = length(header.pointPos);%returns number of data split characters

for i = 2:NdataSplit%iterate through dataSplit sections calculate number of points
    header.locatorNPoints(1,i-1)=(header.pointPos(1,i)-header.pointPos(1,i-1)-2)/header.pointLength;%subtract two = because locatorreference + data split character
end

header.pointPos = header.pointPos(1:end-1);% remove last postion, equals end delimiter
header.Npoint = sum(header.locatorNPoints);%add up all points

%Search for number of measurement systems
index = find(strcmp(sampleArray(:,6),'0'));%get row numbers
if ~isempty(index)%only delete if exist
    sampleArray(index(:),:)=[];
    
end

header.measSystem(1,1)=sampleArray(1,3); % get first measurement system name

for i = 2:length(headerString(:,1))%iterate through measurement colum and add names to measurement systems
    if ~strcmp(sampleArray(i,3),header.measSystem(1,1))% when new system is found, added to list
        header.measSystem(1,length(header.measSystem)+1)=sampleArray(i,3); 
    else
        break;%stop when back at previous measurement system name on third position
    end
end

header.NmeasSystem=length(header.measSystem(1,:));

header = orderfields(header);%sort field names according alphabet

end

