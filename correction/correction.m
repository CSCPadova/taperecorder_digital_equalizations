function corr = correction(fs, nBit, standardW, speedW, standardR, speedR, graphs, save, useResample, y, inputName)
% CORRECTION creates a filter that is used to apply a different 
% equalization standard to an audio file, which can be optionally passed as
% an input parameter.
%
% Input parameters:
%   fs :            Audio file sampling frequency [Hz].
%                   (44100, 48000, 96000)
%   nBit :          Audio file bits per sample.
%                   (8, 16, 24, 32)
%   standardW :     Equalization standard used to record the tape.
%                   ("NAB", "CCIR")
%   speedW :        Recording tape speed [ips].
%                   (3.75, 7.5, 15, 30)
%   standardR :     Equalization standard used to read the tape.
%                   ("NAB", "CCIR")
%   speedR :        Reading tape speed [ips].
%                   (3.75, 7.5, 15, 30)
%   graphs:         Boolean variable to enable graph plots.
%                   0: disabled - 1: enabled
%   save:           Boolean variable to enable impulse response file saving.
%                   0: disabled - 1: enabled
%   useResample:    Use "resample" function when speeds are different.
%                   0: change file sampling frequency - 1: use "resample"
%   y :             OPTIONAL - Double array of a stereo audio file.
%
%   inputName:      OPTIONAL - String containing the name to use to save the
%                   corrected file.
%
% Output variables:
%   corr :          OPTIONAL - Double array corresponding to the corrected 
%                   audio file.

%% Input parameters check

% Recording tape speed check.
if speedW~=3.75 && speedW~=7.5 && speedW~=15 && speedW~=30
    error('Incorrect recording speed. Accepted value are: 3.75, 7.5, 15, 30.');
end

% Reading tape speed check.
if speedR~=3.75 && speedR~=7.5 && speedR~=15 && speedR~=30
    error('Incorrect reading speed. Accepted values are: 3.75, 7.5, 15, 30.');
end

% Equalization standard check.
if (strcmp(standardR,"CCIR")==0 && strcmp(standardR,"NAB")==0 || strcmp(standardW,"CCIR")==0 && strcmp(standardW,"NAB")==0)
    error('Incorrect equalization standard. Accepted values are: CCIR, NAB.');
end

% CCIR check.
if strcmp(standardW,"CCIR")==1 && speedW==3.75
    warning('CCIR standard is undefined at a 3.75 ips speed. Recording equalization standard is set to NAB.');
    standardW = "NAB";
end
if strcmp(standardR,"CCIR")==1 && speedR==3.75
    warning('CCIR standard is undefined at a 3.75 ips speed. Reading equalization standard is set to NAB.');
    standardR = "NAB";
end

% NAB check.
if strcmp(standardW,"NAB")==1 && speedW==30
    warning('NAB standard is undefined at a 30 ips speed. Recording equalization standard is set to CCIR.');
    standardW = "CCIR";
end
if strcmp(standardR,"NAB")==1 && speedR==30
    warning('NAB standard is undefined at a 30 ips speed. Reading equalization standard is set to CCIR.');
    standardR = "CCIR";
end

% Sampling frequency check.
if fs~=44100 && fs~=48000 && fs~=96000
    error('Incorrect sampling rate. Accepted values are: 44100, 48000, 96000.');
end

% Bits per sample check.
if nBit~=8 && nBit~=16 && nBit~=24 && nBit~=32
    error('Incorrect bit depth. Accepted values are: 8, 16, 24, 32.');
end

%% Equalization standard time constants

% CCIR time constants.
t2_30 = 17.5*10^-6;  % time constant CCIR_30
t2_15 = 35*10^-6;    % time constant CCIR_15 
t2_7  = 70*10^-6;    % time constant CCIR_7.5

% NAB time constants.
t3    = 3180*10^-6; 
t4_15 = 50*10^-6;   % time constant NAB_15
t4_7  = 50*10^-6;   % time constant NAB_7.5
t4_3  = 90*10^-6;   % time constant NAB_3.75

%% Decision stage
% This section will establish which time constants must be modified to
% obtain the desired equalization standard.

switch standardW

    case 'CCIR'
        
        switch speedW
            
            case 30
                
                switch standardR
                    
                    case 'NAB'
                        
                        switch speedR
                            
                            % Case 1
                            case 15
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x2.
                                        y = resample(y, 1, 2);
                                    else
                                        % Double sampling frequency.
                                        fs = 2*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw15_mod + CCIRr30,
                                % NAB constants divided by 2.
                                t3 = t3/2;
                                t4 = t4_15/2;
                                % CCIR_30 constant not altered.
                                t2 = t2_30;
                                % Filter coefficients.
                                a = [t2*t3 t2+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 1;
                                
                            % Case 2
                            case 7.5
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x4.
                                        y = resample(y, 1, 4);
                                    else
                                        % Quadruple sampling frequency.
                                        fs = 4*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw7.5_mod + CCIRr30,
                                % NAB constants divided by 4.
                                t3 = t3/4;
                                t4 = t4_7/4;
                                % CCIR_30 constant not altered.
                                t2 = t2_30;
                                % Filter coefficients.
                                a = [t2*t3 t2+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 2;
                                
                            % Case 3
                            case 3.75
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x8.
                                        y = resample(y, 1, 8);
                                    else
                                        % Multiply by 8 the sampling frequency.
                                        fs = 8*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw3.75_mod + CCIRr30,
                                % NAB constants divided by 8.
                                t3 = t3/8;
                                t4 = t4_3/8;
                                % CCIR_30 constant not altered.
                                t2 = t2_30;
                                % Filter coefficients.
                                a = [t2*t3 t2+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 3;
                                
                        end
                    
                    case 'CCIR'
                        
                        switch speedR
                            
                            % Case 31
                            case 30
                            
                                if exist('y', 'var')
                                    % Nothing to do here!
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 31");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                return
                                
                            % Case 15
                            case 15
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x2.
                                        y = resample(y, 1, 2);
                                    else
                                        % Double sampling frequency.
                                        fs = 2*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 15");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                % If an input file is given, save the resampled file.
                                if exist('y', 'var')
                                    % Create output file name
                                    corr_str = strcat("audio/corrected/", inputName, "_", standardW, "w", num2str(speedW), "_", standardR, "r", num2str(speedR), "_", num2str(fs), "Hz", num2str(nBit), "_output.wav");
                                    disp(strcat("Saving corrected audio file as: ", corr_str, " ..."));
                                    % Save output file
                                    audiowrite(corr_str, corr, fs, "BitsPerSample", nBit);
                                end
                                
                                return
                                
                            % Case 16
                            case 7.5
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x4.
                                        y = resample(y, 1, 4);
                                    else
                                        % Quadruple sampling frequency.
                                        fs = 4*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 16");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                % If an input file is given, save the resampled file.
                                if exist('y', 'var')
                                    % Create output file name
                                    corr_str = strcat("audio/corrected/", inputName, "_", standardW, "w", num2str(speedW), "_", standardR, "r", num2str(speedR), "_", num2str(fs), "Hz", num2str(nBit), "_output.wav");
                                    disp(strcat("Saving corrected audio file as: ", corr_str, " ..."));
                                    % Save output file
                                    audiowrite(corr_str, corr, fs, "BitsPerSample", nBit);
                                end
                                
                                return
                                
                        end
                        
                end
                
            case 15
                
                switch standardR
                    
                    case 'NAB'
                        
                        switch speedR
                            
                            % Case 28
                            case 15
                                
                                % No speed change.
                                % Correction filter: NAB15w + CCIR15r,
                                % NAB_15 constant not altered.
                                t4 = t4_15;
                                % Filter coefficients.
                                a = [t2_15*t3 t2_15+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 28;
                                
                            % Case 6
                            case 7.5
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x2.
                                        y = resample(y, 1, 2);
                                    else
                                        % Double sampling frequency.
                                        fs = 2*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw7.5_mod + CCIRr15,
                                % NAB constants divided by 2.
                                t3 = t3/2;
                                t4 = t4_7/2;
                                % CCIR_15 constant not altered.
                                t2 = t2_15;
                                % Filter coefficients.
                                a = [t2*t3 t2+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 6;
                                
                            % Case 7
                            case 3.75
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x4.
                                        y = resample(y, 1, 4);
                                    else
                                        % Quadruple sampling frequency.
                                        fs = 4*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw3.75_mod + CCIRr15,
                                % NAB constants divided by 4.
                                t3 = t3/4;
                                t4 = t4_3/4;
                                % CCIR_15 constant not altered.
                                t2 = t2_15;
                                % Filter coefficients.
                                a = [t2*t3 t2+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 7;
                                
                        end
                    
                    case 'CCIR'
                        
                        switch speedR
                            
                            % Case 19
                            case 30
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/2.
                                        y = resample(y, 2, 1);
                                    else
                                        % Half sampling frequency.
                                        fs = fs/2;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 19");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                % If an input file is given, save the resampled file.
                                if exist('y', 'var')
                                    % Create output file name
                                    corr_str = strcat("audio/corrected/", inputName, "_", standardW, "w", num2str(speedW), "_", standardR, "r", num2str(speedR), "_", num2str(fs), "Hz", num2str(nBit), "_output.wav");
                                    disp(strcat("Saving corrected audio file as: ", corr_str, " ..."));
                                    % Save output file
                                    audiowrite(corr_str, corr, fs, "BitsPerSample", nBit);
                                end
                                
                                return
                                
                            % Case 33
                            case 15
                            
                                if exist('y', 'var')
                                    % Nothing to do here!
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 33");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                return
                                
                            % Case 20
                            case 7.5
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x2.
                                        y = resample(y, 1, 2);
                                    else
                                        % Double sampling frequency.
                                        fs = 2*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 20");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                % If an input file is given, save the resampled file.
                                if exist('y', 'var')
                                    % Create output file name
                                    corr_str = strcat("audio/corrected/", inputName, "_", standardW, "w", num2str(speedW), "_", standardR, "r", num2str(speedR), "_", num2str(fs), "Hz", num2str(nBit), "_output.wav");
                                    disp(strcat("Saving corrected audio file as: ", corr_str, " ..."));
                                    % Save output file
                                    audiowrite(corr_str, corr, fs, "BitsPerSample", nBit);
                                end
                                
                                return
                                
                        end
                        
                end
                
            case 7.5
                
                switch standardR
                    
                    case 'NAB'
                        
                        switch speedR
                            
                            % Case 10
                            case 15
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/2.
                                        y = resample(y, 2, 1);
                                    else
                                        % Half sampling frequency.
                                        fs = fs/2;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw15_mod + CCIRr7.5,
                                % NAB constants multiplied by 2.
                                t3 = t3*2;
                                t4 = t4_15*2;
                                % CCIR_7.5 constant not altered.
                                t2 = t2_7;
                                % Filter coefficients.
                                a = [t2*t3 t2+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 10;
                                
                            % Case 30
                            case 7.5
                                
                                % No speed change.
                                % Correction filter: NAB7.5w + CCIR7.5r,
                                % NAB_7.5 constant not altered.
                                t4 = t4_7;
                                % Filter coefficients.
                                a = [t2_7*t3 t2_7+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 30;
                                
                            % Case 11
                            case 3.75
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x2.
                                        y = resample(y, 1, 2);
                                    else
                                        % Double sampling frequency.
                                        fs = 2*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw3.75_mod + CCIRr7.5,
                                % NAB constants divided by 2.
                                t3 = t3/2;
                                t4 = t4_3/2;
                                % CCIR_7.5 constant not altered.
                                t2 = t2_7;
                                % Filter coefficients.
                                a = [t2*t3 t2+t3 1];
                                b = [t3*t4 t3 0];
                                
                                % Plot information.
                                case_n = 11;
                                
                        end
                    
                    case 'CCIR'
                        
                        switch speedR
                            
                            % Case 23
                            case 30
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/4.
                                        y = resample(y, 4, 1);
                                    else
                                        % 1/4 the sampling frequency.
                                        fs = fs/4;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 23");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                % If an input file is given, save the resampled file.
                                if exist('y', 'var')
                                    % Create output file name
                                    corr_str = strcat("audio/corrected/", inputName, "_", standardW, "w", num2str(speedW), "_", standardR, "r", num2str(speedR), "_", num2str(fs), "Hz", num2str(nBit), "_output.wav");
                                    disp(strcat("Saving corrected audio file as: ", corr_str, " ..."));
                                    % Save output file
                                    audiowrite(corr_str, corr, fs, "BitsPerSample", nBit);
                                end
                                
                                return
                                
                            % Case 24
                            case 15
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/2.
                                        y = resample(y, 2, 1);
                                    else
                                        % Half sampling frequency.
                                        fs = fs/2;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 24");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                % If an input file is given, save the resampled file.
                                if exist('y', 'var')
                                    % Create output file name
                                    corr_str = strcat("audio/corrected/", inputName, "_", standardW, "w", num2str(speedW), "_", standardR, "r", num2str(speedR), "_", num2str(fs), "Hz", num2str(nBit), "_output.wav");
                                    disp(strcat("Saving corrected audio file as: ", corr_str, " ..."));
                                    % Save output file
                                    audiowrite(corr_str, corr, fs, "BitsPerSample", nBit);
                                end
                                
                                return
                                
                            % Case 35
                            case 7.5
                            
                                if exist('y', 'var')
                                    % Nothing to do here!
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 35");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                return
                                
                        end
                        
                end
                
        end
        
    case 'NAB'
        
        switch speedW
            
            case 15
                
                switch standardR
                    
                    case 'NAB'
                        
                        switch speedR
                            
                            % Case 32
                            case 15
                            
                                if exist('y', 'var')
                                    % Nothing to do here!
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 32");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                return
                                
                            % Case 17
                            case 7.5
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x2.
                                        y = resample(y, 1, 2);
                                    else
                                        % Double sampling frequency.
                                        fs = 2*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw7.5_mod + NABr15,
                                % NAB constants divided by 2.
                                t4_mod = t4_7/2;
                                t3_mod = t3/2;
                                % Filter coefficients.
                                a = [t3_mod*t3*t4_15 t3_mod*t3+t3*t4_15 t3];
                                b = [t3_mod*t4_mod*t3 t3_mod*t3+t3_mod*t4_mod t3_mod];
                                
                                % Plot information.
                                case_n = 17;
                                
                            % Case 18
                            case 3.75
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x4.
                                        y = resample(y, 1, 4);
                                    else
                                        % Quadruple sampling frequency.
                                        fs = 4*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw3.75_mod + NABr15,
                                % NAB constants divided by 4.
                                t4_mod = t4_3/4;
                                t3_mod = t3/4;
                                % Filter coefficients.
                                a = [t3_mod*t3*t4_15 t3_mod*t3+t3*t4_15 t3];
                                b = [t3_mod*t4_mod*t3 t3_mod*t3+t3_mod*t4_mod t3_mod];
                                
                                % Plot information.
                                case_n = 18;
                                
                        end
                    
                    case 'CCIR'
                        
                        switch speedR
                            
                            % Case 4
                            case 30
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/2.
                                        y = resample(y, 2, 1);
                                    else
                                        % Half sampling frequency.
                                        fs = fs/2;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: CCIRw30_mod + NABr15,
                                % CCIR_30 constant multiplied by 2.
                                t2 = t2_30*2;
                                % NAB_15 constant not altered.
                                t4 = t4_15;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2*t3 t2+t3 1];
                                
                                % Plot information.
                                case_n = 4;
                                
                            % Case 27
                            case 15
                                
                                % No speed change.
                                % Correction filter: CCIR15w + NAB15r,
                                % NAB_15 constant not altered.
                                t4 = t4_15;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2_15*t3 t2_15+t3 1];
                                
                                % Plot information.
                                case_n = 27;
                                
                            % Case 5
                            case 7.5
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x2.
                                        y = resample(y, 1, 2);
                                    else
                                        % Double sampling frequency.
                                        fs = 2*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: CCIRw7.5_mod + NABr15,
                                % CCIR_7.5 constant divided by 2.
                                t2 = t2_7/2;
                                % NAB_15 constant not altered.
                                t4 = t4_15;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2*t3 t2+t3 1];
                                
                                % Plot information.
                                case_n = 5;
                                
                        end
                        
                end
                
            case 7.5
                
                switch standardR
                    
                    case 'NAB'
                        
                        switch speedR
                            
                            % Case 21
                            case 15
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/2.
                                        y = resample(y, 2, 1);
                                    else
                                        % Half sampling frequency.
                                        fs = fs/2;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw15_mod + NABr7.5,
                                % NAB constants multiplied by 2.
                                t4_mod = t4_15*2;
                                t3_mod = t3*2;
                                % Filter coefficients.
                                a = [t3_mod*t3*t4_7 t3_mod*t3+t3*t4_7 t3];
                                b = [t3_mod*t4_mod*t3 t3_mod*t3+t3_mod*t4_mod t3_mod];
                                
                                % Plot information.
                                case_n = 21;
                                
                            % Case 34
                            case 7.5
                                
                                if exist('y', 'var')
                                    % Nothing to do here!
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 34");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                return
                                
                            % Case 22
                            case 3.75
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x2.
                                        y = resample(y, 1, 2);
                                    else
                                        % Double sampling frequency.
                                        fs = 2*fs;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw3.75_mod + NABr7.5,
                                % NAB constants divided by 2.
                                t4_mod = t4_3/2;
                                t3_mod = t3/2;
                                % Filter coefficients.
                                a = [t3_mod*t3*t4_7 t3_mod*t3+t3*t4_7 t3];
                                b = [t3_mod*t4_mod*t3 t3_mod*t3+t3_mod*t4_mod t3_mod];
                                
                                % Plot information.
                                case_n = 22;
                                
                        end
                    
                    case 'CCIR'
                        
                        switch speedR
                            
                            % Case 8
                            case 30
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/4.
                                        y = resample(y, 4, 1);
                                    else
                                        % 1/4 sampling frequency.
                                        fs = fs/4;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: CCIRw30_mod + NABr7.5,
                                % CCIR_30 constant multiplied by 4.
                                t2 = t2_30*4;
                                % NAB_7.5 constant not altered.
                                t4 = t4_7;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2*t3 t2+t3 1];
                                
                                % Plot information.
                                case_n = 8;
                                
                            % Case 9
                            case 15
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/2.
                                        y = resample(y, 2, 1);
                                    else
                                        % Half sampling frequency.
                                        fs = fs/2;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: CCIRw15_mod + NABr7.5,
                                % CCIR_15 constant multiplied by 2.
                                t2 = t2_15*2;
                                % NAB_7.5 constant not altered.
                                t4 = t4_7;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2*t3 t2+t3 1];
                                
                                % Plot information.
                                case_n = 9;
                                
                            % Case 29
                            case 7.5
                                
                                % No speed change.
                                % Correction filter: CCIR7.5w + NAB7.5r,
                                % NAB_7.5 constant not altered.
                                t4 = t4_7;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2_7*t3 t2_7+t3 1];
                                
                                % Plot information.
                                case_n = 29;
                                
                        end
                        
                end
                
            case 3.75
                
                switch standardR
                    
                    case 'NAB'
                        
                        switch speedR
                            
                            % Case 25
                            case 15
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/4.
                                        y = resample(y, 4, 1);
                                    else
                                        % 1/4 sampling frequency.
                                        fs = fs/4;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw15_mod + NABr3.75,
                                % NAB constants multiplied by 4.
                                t4_mod = t4_15*4;
                                t3_mod = t3*4;
                                % Filter coefficients.
                                a = [t3_mod*t3*t4_3 t3_mod*t3+t3*t4_3 t3];
                                b = [t3_mod*t4_mod*t3 t3_mod*t3+t3_mod*t4_mod t3_mod];
                                
                                % Plot information.
                                case_n = 25;
                                
                            % Case 26
                            case 7.5
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/2.
                                        y = resample(y, 2, 1);
                                    else
                                        % Half sampling frequency.
                                        fs = fs/2;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: NABw7.5_mod + NABr3.75,
                                % NAB constants multiplied by 2.
                                t4_mod = t4_7*2;
                                t3_mod = t3*2;
                                % Filter coefficients.
                                a = [t3_mod*t3*t4_3 t3_mod*t3+t3*t4_3 t3];
                                b = [t3_mod*t4_mod*t3 t3_mod*t3+t3_mod*t4_mod t3_mod ];
                                
                                % Plot information.
                                case_n = 26;
                                
                            % Case 36
                            case 3.75
                                
                                if exist('y', 'var')
                                    % Nothing to do here!
                                    corr = y;
                                end
                                
                                disp("REFERENCE CASE: 36");
                                disp(" ");
                                
                                if graphs == 1
                                    disp("There is no filter plot available.");
                                end
                                
                                return
                                
                        end
                    
                    case 'CCIR'
                        
                        switch speedR
                            
                            % Case 12
                            case 30
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/8.
                                        y = resample(y, 8, 1);
                                    else
                                        % 1/8 sampling frequency.
                                        fs = fs/8;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: CCIRw30_mod + NABr3.75,
                                % CCIR_30 constant multiplied by 8.
                                t2 = t2_30*8;
                                % NAB_3.75 constant not altered.
                                t4 = t4_3;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2*t3 t2+t3 1];
                                
                                % Plot information.
                                case_n = 12;
                                
                            % Case 13
                            case 15
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/4.
                                        y = resample(y, 4, 1);
                                    else
                                        % 1/4 sampling frequency.
                                        fs = fs/4;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: CCIRw15_mod + NABr3.75,
                                % CCIR_15 constant multiplied by 4.
                                t2 = t2_15*4;
                                % NAB_3.75 constant not altered.
                                t4 = t4_3;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2*t3 t2+t3 1];
                                
                                % Plot information.
                                case_n = 13;
                                
                            % Case 14
                            case 7.5
                                
                                if exist('y', 'var')
                                    if useResample == 1
                                        % Speed change: resample x1/2.
                                        y = resample(y, 2, 1);
                                    else
                                        % Half sampling frequency.
                                        fs = fs/2;
                                        disp(strcat("Sampling frequency modified to: ", num2str(fs), " Hz."));
                                    end
                                end
                                % Correction filter: CCIRw7.5_mod + NABr3.75,
                                % CCIR_7.5 constant multiplied by 2.
                                t2 = t2_7*2;
                                % NAB_3.75 constant not altered.
                                t4 = t4_3;
                                % Filter coefficients.
                                a = [t3*t4 t3 0];
                                b = [t2*t3 t2+t3 1];
                                
                                % Plot information.
                                case_n = 14;
                                
                        end
                        
                end
                
        end
        
end

% Notify in Command Window the selected case.
disp(strcat("REFERENCE CASE: ", num2str(case_n)));
disp(" ");

%% Correction filter

% Set the impulse response length.
ir_length = fs;

% Analogue transfer function.
H = tf(a, b);
[a1_a, b1_a] = tfdata(H);
numzt_a = cell2mat(a1_a);
denzt_a = cell2mat(b1_a);
% Compute analogue filter frequency response.
% Upper limit is set to fs*pi so that it will be fs/2.
w_a = logspace(log10(0.01), log10(fs*pi), 5000);
ht_a = freqs(numzt_a, denzt_a, w_a);
% In the frequency response graph we use as abscissa the frequency, not the pulsation.
ft_a = w_a/(2*pi);

% MPZ Digitization.
Hd = c2d(H, 1/fs, 'matched');
% Extract numerator and denominator of the transfer function.
[a1, b1] = tfdata(Hd);
numzt_mpz = cell2mat(a1);
denzt_mpz = cell2mat(b1);

% Save MPZ numzt and denzt for correction.
numzt = numzt_mpz;
denzt = denzt_mpz;

% Compute filter MPZ frequency response.
[ht_mpz, ft_mpz] = freqz(numzt_mpz, denzt_mpz, logspace(log10(0.01), log10(fs/2), 5000), fs);
% Compute filter MPZ impulse response.
[stabfiltimp_mpz, T_mpz] = impz(numzt_mpz, denzt_mpz, ir_length, fs);

% Two other digitization methods are now computed to be compared with MPZ method.

% First Order Hold Digitization.
Hd_foh = c2d(H, 1/fs, 'foh');
% Extract numerator and denominator of the transfer function.
[a1, b1] = tfdata(Hd_foh);
numzt_foh = cell2mat(a1);
denzt_foh = cell2mat(b1);

% Compute filter "method" frequency response.
[ht_foh, ft_foh] = freqz(numzt_foh, denzt_foh, logspace(log10(0.01), log10(fs/2), 5000), fs);

% Bilinear Digitization.
% Prewarp: The frequency to be matched when using bilinear transform
f_bil = 0;
opt = c2dOptions('Method', 'tustin', 'PrewarpFrequency', f_bil*2*pi);
Hd_bil = c2d(H, 1/fs, opt);
[a1, b1] = tfdata(Hd_bil);
numzt_bil = cell2mat(a1);
denzt_bil = cell2mat(b1);

% Compute filter bilinear frequency response.
[ht_bil, ft_bil] = freqz(numzt_bil, denzt_bil, logspace(log10(0.01), log10(fs/2), 5000), fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%     POLE CHECK     %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the pole that eliminates magnitude response of infinity at DC.
% The modification is done in the analogue domain, digital transfer
% functions are therefore computed again.

% New pole frequency [Hz].
f_new_pole = 2;
% Move to zero-pole representation.
[Z, P, K] = tf2zp(a, b);
% Boolean variable to notify if the pole has been added.
% 0: unmodified function - 1: modified function
pole = 0;

% Check if the function requires the pole.
% For each pole...
for i = 1 : length(P)
    
    % ... check if the current pole is at 0 Hz...
    if P(i) == 0
        
        % ... and replace it with the new one.
        P(i) = -f_new_pole*2*pi;
        % Update boolean variable.
        pole = 1;
        
        % Notify in Command Window the modification.
        disp("Pole at 0 Hz replaced.");

        % Back to transfer function representation.
        [a_p, b_p] = zp2tf(Z, P, K);
        
        % New analogue transfer function.
        H_p = tf(a_p, b_p);
        [a1_a_p, b1_a_p] = tfdata(H_p);
        numzt_a_p = cell2mat(a1_a_p);
        denzt_a_p = cell2mat(b1_a_p);
        w_a_p = logspace(log10(0.01), log10(fs*pi), 5000);
        ht_a_p = freqs(numzt_a_p, denzt_a_p, w_a_p);
        ft_a_p = w_a_p/(2*pi);
        
        % MPZ Digitization.
        Hd_p = c2d(H_p, 1/fs, 'matched');
        [a1_p, b1_p] = tfdata(Hd_p);
        numzt_mpz_p = cell2mat(a1_p);
        denzt_mpz_p = cell2mat(b1_p);
        
        % Set numzt and denzt, used for the correction, as the modified ones.
        numzt = numzt_mpz_p;
        denzt = denzt_mpz_p;
        
        % Compute modified filter frequency response.
        [ht_mpz_p, ft_mpz_p] = freqz(numzt_mpz_p, denzt_mpz_p, logspace(log10(0.01), log10(fs/2), 5000), fs);
        % Compute modified filter impulse response.
        [stabfiltimp_mpz_p, T_mpz_p] = impz(numzt_mpz_p, denzt_mpz_p, ir_length, fs);
        
        % First Order Hold Digitization.
        Hd_foh_p = c2d(H_p, 1/fs, 'foh');
        [a1_p, b1_p] = tfdata(Hd_foh_p);
        numzt_foh_p = cell2mat(a1_p);
        denzt_foh_p = cell2mat(b1_p);

        % Compute modified filter "method" frequency response.
        [ht_foh_p, ft_foh_p] = freqz(numzt_foh_p, denzt_foh_p, logspace(log10(0.01), log10(fs/2), 5000), fs);
        
        % Bilinear Digitization.
        Hd_bil_p = c2d(H_p, 1/fs, opt);
        [a1_p, b1_p] = tfdata(Hd_bil_p);
        numzt_bil_p = cell2mat(a1_p);
        denzt_bil_p = cell2mat(b1_p);

        % Compute modified filter bilinear frequency response.
        [ht_bil_p, ft_bil_p] = freqz(numzt_bil_p, denzt_bil_p, logspace(log10(0.01), log10(fs/2), 5000), fs);
        
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input audio file correction and save

% If an input file is given, apply the correction filter to it.
if exist('y', 'var')
    % Set the output variable as the modified input signal.
    corr = filter(numzt, denzt, y);
    % Create output file name
    corr_str = strcat("audio/corrected/", inputName, "_", standardW, "w", num2str(speedW), "_", standardR, "r", num2str(speedR), "_", num2str(fs), "Hz", num2str(nBit));
    disp(strcat("Saving corrected audio file as: ", corr_str, " ..."));
    % Save output file
    audiowrite(corr_str, corr, fs, "BitsPerSample", nBit);
end

%% Normalization
% This section checks if the impulse response should be normalized.

% Initialize output file name normalization string.
IR_normalizationFactor_string = "";
% Normalization flag showing if the impulse response should be normalized.
% 0: to be not normalized - 1: to be normalized
norm = 0;

% Check if the impulse response should be normalized:
% This should happen if numerator maximum value is higher than 1.
max_num = max(numzt);
if max_num > 1
    % Set the normalization flag to 1.
    norm = 1;
    % Modify impulse response file name normalization string.
    IR_normalizationFactor_string = "_norm8";
    % Notify in Command Window.
    disp("Normalization required.");
    % To normalize, divide the numerator by 8.
    % The maximum value EXPERIMENTALLY never exceeds 8.
    numzt = numzt/8;
    
    % Compute normalized filter frequency response.
    [ht_norm, ft_norm] = freqz(numzt, denzt, logspace(log10(0.01), log10(fs/2), 5000), fs);
    % Compute normalized filter impulse response.
    [stabfiltimp_norm, T_norm] = impz(numzt, denzt, ir_length, fs);
    
end

%% Impulse response file saving

% Impulse response file name.
ir_str = strcat('audio/impulse_response/', num2str(case_n), '_corrective_IR_', standardW, 'w', num2str(speedW), '_', standardR, 'r', num2str(speedR), '_', num2str(fs), 'Hz', num2str(nBit), IR_normalizationFactor_string, '.wav');

% If enabled, save the impulse response as an audio file.
if save == 1
    if norm == 1
        stabfiltimp = stabfiltimp_norm;
    else
        if pole == 1
            stabfiltimp = stabfiltimp_mpz_p;
        else
            stabfiltimp = stabfiltimp_mpz;
        end        
    end
    % Find the index of the first value that will be saved as 0 in WAV files.
    % Values depend on the bits per sample: they have been found EXPERIMENTALLY.
    % They are different if the value has negative or positive sign.
    switch nBit
        case 8
            if sign(stabfiltimp(length(stabfiltimp))) == 1
                max_value = 0.007812499062495;
            else
                max_value = 2.328306141530708e-10;
            end
        case 16
            if sign(stabfiltimp(length(stabfiltimp))) == 1
                max_value = 3.051734258671293e-05;
            else
                max_value = 2.328306141530708e-10;
            end
        case 24
            if sign(stabfiltimp(length(stabfiltimp))) == 1
                max_value = 1.189760948804744e-07;
            else
                max_value = 2.328306141530708e-10;
            end
        case 32
            if sign(stabfiltimp(length(stabfiltimp))) == 1
                max_value = 7.006492317461587e-46;
            else
                max_value = 7.006492282461413e-46;
            end
    end
    % Boolean flag to notify that ir_length is big
    % enough to contain the entire impulse response, i.e. zeroes
    % are reached.
    ir_ends = 0;
    % Starting index is ir_length*0.4, so that the impulse
    % response will not be cut if it passes through zero during initial
    % phases. Moreover, the frequency response graph will start from 
    % 1 / 0.4 = 2.5Hz.
    for j = round(ir_length*0.4) : length(stabfiltimp)
        if abs(stabfiltimp(j)) < max_value
            disp(strcat("WAV impulse response duration: ~", num2str(j/fs), " s"));
            % Update ir_ends flag.
            ir_ends = 1;
            break
        end
    end
    if ir_ends == 0
        % Throw warning, since the impulse response length is too small to
        % contain the whole information with the chosen bit resolution.
        warning("The last value of the WAV impulse response will not be zero, since variable ir_length is too small.");
        disp(strcat("WAV impulse response duration: ", num2str(length(stabfiltimp)/fs), " s"));
    end
    % Notify saving in Command Window.
    disp(strcat("Saving filter impulse response as: ", ir_str, " ..."));
    % Save impulse response up to i+9, so that there should be at least 10
    % zeroes at the end of wav file (there will be more if impulse response
    % decreases to 0 before ir_length*0.4).
    audiowrite(ir_str, stabfiltimp(1:(j+9)), fs, 'BitsPerSample', nBit);
    % Save an impulse response of length ir_length
    audiowrite(ir_str, stabfiltimp, fs, 'BitsPerSample', nBit);
    % The following "wavdither" function applies dithering when saving the
    % impulse response. Please note that the function comes from MATLAB Add-ons.
    % wavdither(stabfiltimp(1:(j+9)), fs, nBit, ir_str);
end

%% Graphs
% If enabled, plot graphs.

if graphs == 1
    
    disp("Plotting graphs...");
    
    % Read the produced impulse response to plot its FFT.
    % Useful to verify if the WAV file is correct.
    % Throws a warning if impulse response file is not present.
    try
       ir_wav = audioread(ir_str);
       disp(strcat("Loaded impulse response: ", ir_str, " ..."));
       % Save its FFT to plot it later.
       % Computed in a high number of points to be more precise.
       IR_WAV = fft(ir_wav, 10*fs);
    catch ME
       if strcmp(ME.identifier, "MATLAB:audiovideo:audioread:fileNotFound")
           warning(strcat("Impulse response file not found at: ", ir_str, ". Launch this program with flag 'save' = 1 to create the required impulse response."));
       end
    end

    % Check if the WAV has been read.
    if exist('IR_WAV', 'var')
       % "if" cascade to call the correct plotting functions.
       if pole == 1
           if norm == 1
               plot_graph_p_norm(ht_a, ft_a, ht_mpz, ft_mpz, ht_a_p, ft_a_p, ht_mpz_p, ft_mpz_p, ht_norm, ft_norm, case_n, fs, IR_WAV);
               plot_ir(stabfiltimp_norm, T_norm, case_n);
           else
               plot_graph_p(ht_a, ft_a, ht_mpz, ft_mpz, ht_a_p, ft_a_p, ht_mpz_p, ft_mpz_p, case_n, fs, IR_WAV);
               plot_ir(stabfiltimp_mpz_p, T_mpz_p, case_n);
           end
       else
           if norm == 1
               plot_graph_norm(ht_a, ft_a, ht_mpz, ft_mpz, ht_norm, ft_norm, case_n, fs, IR_WAV);
               plot_ir(stabfiltimp_norm, T_norm, case_n);
           else
               plot_graph(ht_a, ft_a, ht_mpz, ft_mpz,  case_n, fs, IR_WAV);
               plot_ir(stabfiltimp_mpz, T_mpz, case_n);
           end
       end
    else
       % "if" cascade to call the correct plotting functions.
       if pole == 1
           if norm == 1
               plot_graph_p_norm(ht_a, ft_a, ht_mpz, ft_mpz, ht_a_p, ft_a_p, ht_mpz_p, ft_mpz_p, ht_norm, ft_norm, case_n, fs);
               plot_ir(stabfiltimp_norm, T_norm, case_n);
           else
               plot_graph_p(ht_a, ft_a, ht_mpz, ft_mpz, ht_a_p, ft_a_p, ht_mpz_p, ft_mpz_p, case_n, fs);
               plot_ir(stabfiltimp_mpz_p, T_mpz_p, case_n);
           end
       else
           if norm == 1
               plot_graph_norm(ht_a, ft_a, ht_mpz, ft_mpz, ht_norm, ft_norm, case_n, fs);
               plot_ir(stabfiltimp_norm, T_norm, case_n);
           else
               plot_graph(ht_a, ft_a, ht_mpz, ft_mpz, case_n, fs);
               plot_ir(stabfiltimp_mpz, T_mpz, case_n);
           end
       end
    end
    
    % Comparison between digitization methods.
    if pole == 1
        plot_methods(ht_a_p, ft_a_p, ht_mpz_p, ft_mpz_p, ht_foh_p, ft_foh_p, ht_bil_p, ft_bil_p, case_n, fs);
    else
        plot_methods(ht_a, ft_a, ht_mpz, ft_mpz, ht_foh, ft_foh, ht_bil, ft_bil, case_n, fs);
    end
end

end