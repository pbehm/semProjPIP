function subject = createSubject(header,VD)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   creates subject file from AXIOS data and gets reference           %%
% %%                                                                     %%
% %%   Autor: Pascal Behm                                                %%
% %%          Institut for Biomedical Engineering                        %%
% %%          ETH Zuerich                                                %%
% %%                                                                     %%
% %%   Erstellungsdatum: 21.10.2015                                      %%
% %%   Version: 1.0                                                      %%
% %%                                                                     %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% create subject
%name id etc
if ~(exist('subject','var'))
    %get patient id from user
    
    subject.Personalien.id  = inputdlg('Patient/Measurement id:',...
             'Id', [1 50]);
    %further inputs by user goe here...
    
else
    subject.Personalien.id = 'synth data';
end

%% getReference
%get reference position of all segments from the first 50 values
subject = getReference(subject,header,VD);


%% getCoordinateOrientation
%for correct anatomical planes save model type into subject, adjustment 
%done by individual function
% 0: glove
% 1: artFinger
% 2: virtual hand model

subject.Personalien.model = 0;

end