% Manuel Seet Apr 2018
% Clear the workspace and the screen
sca;
close all;
clearvars;

Screen('Preference', 'SkipSyncTests', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% PARTICIPANT DETAILS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Participant ID:','Age:'};
title = 'Participant Information';
dims = [1 35];
answer = inputdlg(prompt,title,dims);

particID = answer{1};
particAge = answer{2};

today = datestr(now,'ddmmmyy_HHMM');


particID = answer{1};
particAge = answer{2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
%%PSYCHTOOLBOX, GENERAL SETTINGS and PARAMTERS%
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% Get the screen numbers
screens = Screen('Screens');
% Draw to the external screen if avaliable
screenNumber = max(screens);
% Define black, white and grey


white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;
%}
% black and white colors
black = 0;
white = 255;
grey = (white/2);

% find screen size [x y]
whichScreen = 0;
monitor = Screen('Rect',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% PREPARE STIM AND RESPONSE PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Response Parameters%
allowedSet = 'bnQ'; % b for Yes, n for No, Q for quit
down_key = 'b';
up_key = 'n';

%Stimulus parameters
mem_img_dur = 1;
fixation = ['+'];
fixation_dur = 1;
ISI = 1;
qn_dur = 1; %question duration


%define tone
Fs = 10000;                                     % Sampling Frequency
dur = 0.2;                                      %duration
t  = linspace(0, dur-1/Fs, dur*Fs);             % One Second Time Vector
w = 2*pi*1000;                                  % Radian Value To Create 1kHz Tone
s = sin(w*t);                                   % Create Tone


%%%%%%%%%%%%%%%%%%% Reading Stimuli List from Excel %%%%%%%%%%%%%%%%%%%%%%%
DocName = ['Test3_list.xlsx'];
%Setting up data file reading parameters
worksheet_no = 1;
first_column = 'B';
last_column = 'E';
start_row = '2';
end_row = '21';
num_test = (str2num(end_row) - str2num(start_row) + 1);
%define the stimuli list range for excel sheet reading
stim_range = [first_column,start_row,':',last_column,end_row];
%read stimuli excel file
[~,~,raw]  = xlsread(DocName,stim_range);
stim_list = raw;
%shuffle the stimuli rows
%shufflerow(stim_list)

%%%%%%%%%%%%%%PREPARE DATA SAVING%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = [particID,'_','TestC','_',today,'.xlsx'];
excel_data = {'Trial No.','SubjectID','Age','Test Time','Image No.','Starting Luminance','Preferred Level'};
%save the file first
%xlswrite(filename,excel_data,1,'A1');

%save
filenameMAT = [particID,'_','TestC','_',today,'.mat'];
eval(['save ' filenameMAT]);

try

%#######################################################################%
%####################% START STIM PRESENTATION ##########################%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%##################### OPEN SCREEN & GET SCREEN INFO%%############%

window = Screen('OpenWindow',whichScreen,grey);
HideCursor();


%[0] Start with blank screen
Screen('FillRect', window, grey);
Screen('Flip', window);
WaitSecs(0.2);

%[1] Show Welcome Screen
Screen('TextSize', window, 40);
DrawFormattedText(window, 'Welcome to Test C. \n\nPress the Spacebar to continue.', 'center','center', [1 1 1]);
Screen('Flip', window);
WaitSecs(0.5);
% after holding fixation, hit space bar to start a block
FlushEvents('keyDown');	% discard previous key presses in the event queue.
character = GetChar;
while (character ~= ' ')
    character = GetChar;
end

%[2] Show Instructions Screen
Screen('TextSize', window, 40);
DrawFormattedText(window, 'In this test, you will adjust the brightness of images.\n\nPress "b" to decrease brightness and "n" to increase brightness.\nThen press SPACEBAR when the brightness matches that given in the reference. \n\nWhen you are ready, press the Spacebar to start.', 'center','center', [1 1 1]);
Screen('Flip', window);
WaitSecs(0.5);
% after holding fixation, hit space bar to start a block
FlushEvents('keyDown');	% discard previous key presses in the event queue.
character = GetChar;
while (character ~= ' ')
    character = GetChar;
end

%[3] Blank Screen before the trial starts
Screen('FillRect', window, grey);
Screen('Flip', window);
WaitSecs(0.2);



%#########################################################################
%########################################################################

for i = [1:num_test]
    
    %%%%%%%%%%%Prepare Stimuli and text for the Trial%%%%%%%%%%%%%%%%
    %read stimuli
    start_level = stim_list{i,4};
    image = imread([stim_list{i,3},num2str(start_level),'.jpg']);
    
    % Make the images into a texture
    image1 = Screen('MakeTexture', window, image);
    
    
    %%%%%%%%%%%End Preparation for the Trial%%%%%%%%%%%%%%%%
    
    if i > 1
        %Ready to proceed to trial; wait for self-paced keypress
        Screen('TextSize', window, 60);
        DrawFormattedText(window, 'Press the spacebar to continue', 'center','center', [1 1 1]);
        Screen('Flip', window);

        FlushEvents('keyDown');	% discard previous key presses in the event queue.
        character = GetChar;
        while (character ~= ' ')
            character = GetChar;
        end
    elseif i == 1
        WaitSecs(0.01);
    end
    
    %#############################################################
    %%%%%%%%%%%%%START TRIAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %#############################################################
        
    % Now blank screen for 1 seconds
    Screen('FillRect', window, grey);
    Screen('Flip', window);
    WaitSecs(1);
    
    Screen('TextSize', window, 70);
    DrawFormattedText(window, '+', 'center','center', [1 1 1]);
    Screen('Flip', window);
    WaitSecs(ISI);
    
    % Draw stimuli image1 
    Screen('DrawTexture', window, image1, [], [], 0);
    Screen('Flip', window);
    sound(s, Fs); % Produce alert Tone

    % after holding fixation, hit space bar to start a block
    FlushEvents('keyDown');	% discard previous key presses in the event queue.
    character = GetChar;
    n = start_level;
    
    while (character ~= ' ')
        character = GetChar;
        if character == 'b'
            if n == 1
                n = 1;
            elseif n > 1
                n = n-1;
            end
            
        elseif character =='n'
            if n == 17
                n = 17;
            elseif n < 17
                n = n+1;
            end
        end
        
    image_adj = imread([stim_list{i,3},num2str(n),'.jpg']);    
    image_adjusted = Screen('MakeTexture', window, image_adj);
    
    Screen('DrawTexture', window, image_adjusted, [], [], 0);
    Screen('Flip', window);

    end
    
    %APPEND EXCEL DATA in cell array using {}
    results = {i,particID,particAge,today,stim_list{i,2},start_level,n};
    excel_data = [excel_data; results]; %append new results in new row,in list function i.e. []
    %xlswrite(filename,excel_data);
    
    %Save to Mat file
    eval(['save ' filenameMAT]);
    
    % Now blank screen for 1 seconds
    Screen('FillRect', window, grey);
    Screen('Flip', window);
    WaitSecs(ISI)
    
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Clear the screen%%%%%%%%%%%%%%%%%%%%%%%%%

sca;

%#####################################################################

%Save to EXCEL file
%xlswrite(filename,excel_data);

%save to matfile
eval(['save ' filenameMAT]);

end 