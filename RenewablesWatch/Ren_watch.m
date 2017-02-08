%% This script combines CAISO "Renewables Watch" text file into one spreadsheet
% First, go to http://www.caiso.com/market/Pages/ReportsBulletins/DailyRenewablesWatch.aspx and download all the text files associated with the renewables watch
% Second, run this script to combine into one spreadsheet
%
% Written by Josh Eichman

%% Initialization
clear all, close all, clc

currentfolder = pwd;
path_name2 = 'Text_files\';
mkdir([pwd,'\',path_name2])

%%% Loads all csv files in a given folder
    files2load = dir(path_name2); files2load2={files2load.name}';  % Identify files in a folder    
    for i0=1:length(files2load2) % Remove items from list that do not fit criteria
        load_file1(i0)=~isempty(strfind(files2load2{i0},'.txt'));       % Find only txt files        
    end 
    files2load2=files2load2(load_file1);    clear load_file1 load_file2 load_file3

%% Create and combine data files
C1_data1 = [];
C1_data2 = [];
Cmp_strings = {'[-11059] No Good Data For Calculation',...      % Match stupid strings!
               '#VALUE!','Resize to show all values',...
               'Connection to the server lost.  ','#NAME?','#REF!',...
               'Invalid function argument:Start time and End time differ by less than 15 micro seconds'};
for i0=1:length(files2load2)
    fid = fopen([path_name2,char(files2load2(i0))],'rt'); % Read and parse file
    C1 = textscan(fid, '%s','Delimiter','\t','HeaderLines',0,'MultipleDelimsAsOne',true, 'CollectOutput',false);
    fclose(fid);
    C1_1 = C1{1,1};   
    file_date(24*(i0-1)+1:24*(i0-1)+24,1) = C1_1(1);
    if max(strcmp(C1_1{10},{'SOLAR THERMAL','Solar Thermal'}))
        header1(i0,:) = C1_1(3:10);         % Get header for first set of data 
        for i1=1:24                         % Get renewable data
            for i2=1:length(header1(i0,:))
                if max(strcmp(C1_1{10+(i1-1)*(length(header1(i0,:)))+i2},Cmp_strings))                    
                    C1_data1(i1,i2) = 9999999;
                else
                    C1_data1(i1,i2) = str2num(C1_1{10+(i1-1)*(length(header1(i0,:)))+i2});
                end
            end            
        end        
        header2(i0,:) = [C1_1(204:209)];    % Get header for second set of data (drop first two columns (hour and renewable, repeats)
        for i1=1:24    % Get the rest of the system data
            for i2=1:length(header2(i0,:))
                if max(strcmp(C1_1{209+(i1-1)*length(header2(i0,:))+i2},Cmp_strings))
                    C1_data1(i1,i2+length(header1(i0,:))) = 9999999;
                else
                    C1_data1(i1,i2+length(header1(i0,:))) = str2num(C1_1{209+(i1-1)*(length(header2(i0,:)))+i2});
                end
            end            
        end     
    else
        header1(i0,:) = [C1_1(3:9);{''}];   % Get header for first set of data
        for i1=1:24                         % Get renewable data
            for i2=1:length(header1(i0,:))-1
                if max(strcmp(C1_1{9+(i1-1)*(length(header1(i0,:))-1)+i2},Cmp_strings))
                    C1_data1(i1,i2) = 9999999;
                else
                    try     % Due to daylight savings time sometimes there is an error in the hour naming convention, this fixes that issue
                        C1_data1(i1,i2) = str2num(C1_1{9+(i1-1)*(length(header1(i0,:))-1)+i2});
                    catch
                        interim1 = C1_1{9+(i1-1)*(length(header1(i0,:))-1)+i2};
                        C1_1{9+(i1-1)*(length(header1(i0,:))-1)+i2} = num2str(str2num(interim1(1))+1);
                        C1_data1(i1,i2) = str2num(C1_1{9+(i1-1)*(length(header1(i0,:))-1)+i2});
                    end
                end
            end            
        end
        C1_data1(:,8)=0;    % Add empty matrix for "SOLAR THERMAL"
        header2(i0,:) = [C1_1(179:184)];    % Get header for second set of data (drop first two columns (hour and renewable, repeats)
        for i1=1:24    % Get the rest of the system data
            for i2=1:length(header2(i0,:))
                if max(strcmp(C1_1{184+(i1-1)*length(header2(i0,:))+i2},Cmp_strings))
                    C1_data1(i1,i2+length(header1(i0,:))) = 9999999;
                else
                    C1_data1(i1,i2+length(header1(i0,:))) = str2num(C1_1{184+(i1-1)*length(header2(i0,:))+i2});
                end                
            end            
        end
    end
    C1_data1(:,9:10)=[];    % Remove hour and renewable entry (repeated)
    C1_data2 = [C1_data2;C1_data1];
    C1_data1 = [];
    disp([num2str(i0),' of ',num2str(length(files2load2))])
end

% Replace error values for Solar Thermal with 0
C1_data2(find(C1_data2(:,8)==9999999),8)=0;

% Replace error values with average of neighbors
for i3=find(C1_data2==9999999)'
    const2=0;
    const3=0;
    while const3==0;
        const2=const2+1;
        if (C1_data2(i3+const2)==9999999)
        else const3=1;
        end
    end
    slope1 = (C1_data2(i3+const2)-C1_data2(i3-1))/(const2+1);
    C1_data2(i3:i3+const2-1) = (1:const2)*slope1+C1_data2(i3-1);
end

%% Write file to disk
xlswrite([path_name2,'Renewable_data_combined.xlsx'],[[{'Date'},header1(end,:),header2(end,3:end)];[file_date,num2cell(C1_data2)]]);



