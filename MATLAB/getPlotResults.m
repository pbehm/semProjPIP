% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                                                     %%
% %%   Plot the rotation angles and translation vectors                  %%
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

%this function plots the calculated movment angles and translations in a
%very easy way.

result = figure;
subplot(2,3,1)
plot(1:length(flexionPIP),flexionPIP);
title('Flexion angle');
xlabel('frame');
ylabel('flexion [degrees]');

subplot(2,3,2)
plot(1:length(abductionPIP),abductionPIP);
title('Abduction angle');
xlabel('frame');
ylabel('abduction [degrees]');

subplot(2,3,3)
plot(1:length(rotationPIP),rotationPIP);
title('Rotation angle');
xlabel('frame');
ylabel('rotation [degrees]');

subplot(2,3,4)
plot(1:length(translation),translation(:,1));
title('Lateral translation (radial)');
xlabel('frame');
ylabel('translation [mm]');

subplot(2,3,5)
plot(1:length(translation),translation(:,2));
title('Saggital translation (palmar)');
xlabel('frame');
ylabel('translation [mm]');

subplot(2,3,6)
plot(1:length(translation),translation(:,3));
title('Axial translation (distal)');
xlabel('frame');
ylabel('translation [mm]');