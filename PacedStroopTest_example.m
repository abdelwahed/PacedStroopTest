%% Take the Paced Stroop Test
%   
%  This is the timed implementation of Stroop Color-Word Interference Test, 
%  where the user can be programmatically paced to take the stroop test and 
%  record their response within a time specified by the experimenter. The
%  code generates a MATLAB .mat file containing exact time when the stroop 
%  figure was shown, exact time when the user responds along with the color,
%  word and response from each figure.
%
%  This project is inspired by a Matlab File Exchange entry on static Stroop Test 
%  by George Papazafeiropoulos which can be found at -
%  http://www.mathworks.com/matlabcentral/fileexchange/46596-stroop-test
%  For the sake of completeness, some parts of this help file has been
%  reproduced as-is from the above cited project.

%% Reference
%
% The test along with its experimental results is described in:
%
% |Stroop, John Ridley (1935). "Studies of interference in serial verbal
% reactions". Journal of Experimental Psychology 18 (6): 643–662.|
%

%% Brief history of the Stroop Test
%
% In 1935, a farmer’s son named John Ridley Stroop became the first to
% publish in English on the current version of this cognitive task.
% Developed as part of his dissertation at George Peabody College, his task
% became the basis for the Stroop Test, which remains a widely used
% neuropsychological assessment to this day.
%

%% How your brain processes the Stroop Test
% 
% Because most people’s automatic response is to read a word, the Stroop
% Test is a classic test of response inhibition. This skill involves
% responding quickly while avoiding incorrect impulses that may interfere
% with accomplishing goal-driven tasks. Response inhibition is associated
% with the brain’s executive function, and brain imaging studies have found
% that performing the Stroop Test activates brain areas involved in
% executive function, such as the dorsolateral prefrontal cortex.
% In fact, individuals with ADHD and depression, whose poor executive
% function makes them struggle to pay attention and control reactions,
% often have a harder time performing the Stroop Test.
% The Stroop Test also challenges selective attention, or the ability to
% choose which stimuli to focus on and which to ignore. The mental
% flexibility required to switch between multiple stimuli is essential:
% without good selective attention, it can also be easy to make errors.
%

%% Documentation
%
help PacedStroopTest

%% Initial definitions
% In the subsequent code the following initial definitions are made (in the
% order presented below):
%
% # Set variable to log serial data 
% # Set variable to not log serial data
% # Set SHUFFLE parameter so that colors are shuffled
% # Set SHUFFLE parameter so that colors are not shuffled
logSerialData1 = 0; %1
logSerialData2 = 1; %2
SHUFFLE1=1; %3
SHUFFLE2=0; %4

%% Applications
% 
% # Produce Figure 1 (Paced Stroop test with no serial data log)
% # Produce Figure 2 (Paced Stroop test with no serial data log and congruent test only)
% # Produce Figure 3 (Paced Stroop test with no serial data log and non-congruent test only)
% 

% [t,s]=PacedStroopTest(logSerialData1);            %1
% 
% [t,s]=PacedStroopTest(logSerialData1,SHUFFLE1);   %2
% 
% [t,s]=PacedStroopTest(logSerialData1,SHUFFLE2);   %3


%% Copyright
%
% Copyright (c) 13-Dec-2014 by Deba Pratim Saha
%
% * Electrical Engineer, M.S.,
%   Ph.D. Student, ECE Virginia Tech.
% * Email: dpsaha@vt.edu
% 