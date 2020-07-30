%% This code connects with CAISO's OASIS API and downloads data files
% Written by Josh Eichman

%% Initialization
clear all, close all, clc
tic;

year_range = 2018:2019;  % Select specific or range of years
month_range = 1:12; % Select specific or range of months

file_size = 0.01;   % Set lower limit for file size (kB)(will repeat step if size is not correct)
                    % Simple way to catch failed downloads
currentfolder = pwd;
Save_files = [pwd,'\data\'];
[status, msg, msgID] = mkdir(Save_files);

day_zero1 = '';     % For startdate
day_zero2 = '';     % For enddate
month_zero1 = '';   % For startdate
month_zero2 = '';   % For enddate

progress_calc1 = datenum(min(year_range),min(month_range),1,0,0,0); % used to calculate progress
progress_calc2 = datenum(max(year_range),max(month_range),max(max(calendar(max(year_range),max(month_range)))),0,0,0);           


%% Inputs
Select_data = 8; %(1=PRC_LMP_DA, 2=PRC_AS_DA, 3=PRC_FUEL, 4=ATL_Resource, 5=ATL_PNODE, 6=ENE_SLRS, 7=DAM_PRC_AS_GRP, 8=DLAP LMP, 9=DLAP Interval LMP)
if Select_data==1     %% PRC_LMP DA
    id0 = {'queryname=',...         %1
           '&startdatetime=',...    %2
           '&enddatetime=',...      %3
           '&version=',...          %4
           '&market_run_id=',...    %5
           '&grp_type=',...         %6
           '',...                   %7
           '',...                   %8
           ''};                     %9
    id1 = {'PRC_LMP',...            %1
           '',...                   %2
           '',...                   %3
           '1',...                  %4
           'DAM',...                %5
           'ALL_PNODES',...         %6
           '',...                   %7
           '',...                   %8
           ''};                     %9
    pause_vals = [5,10,5];          %   Select time for pauses
elseif Select_data==2  %% PRC_AS DA
    id0 = {'queryname=',...         %1
           '&startdatetime=',...    %2
           '&enddatetime=',...      %3
           '&version=',...          %4
           '&market_run_id=',...    %5
           '&anc_type=',...         %6
           '&anc_region=',...       %7
           '&resultformat=',...     %8
           ''};                     %9
    id1 = {'PRC_AS',...             %1
           '',...                   %2
           '',...                   %3
           '1',...                  %4
           'DAM',...                %5
           'ALL',...                %6
           'ALL',...                %7
           '6',...                  %8
           ''};                     %9
    pause_vals = [5,10,5];          %   Select time for pauses
elseif Select_data==3 %% PRC_Fuel 
    id0 = {'queryname=',...         %1
           '&startdatetime=',...    %2
           '&enddatetime=',...      %3
           '&version=',...          %4
           '&fuel_region_id=',...   %5
           '',...                   %6
           '',...                   %7
           '',...                   %8
           ''};                     %9
    id1 = {'PRC_FUEL',...           %1
           '',...                   %2
           '',...                   %3
           '1',...                  %4
           'ALL',...                %5
           '',...                   %6
           '',...                   %7
           '',...                   %8
           ''};                     %9  
    pause_vals = [5,10,5];          %   Select time for pauses  
elseif Select_data==4
    id0 = {'queryname=',...         %1
           '&startdatetime=',...    %2
           '&enddatetime=',...      %3
           '&version=',...          %4
           '&resource_id=',...      %5
           '&agge_type=',...        %6
           '&resource_type=',...    %7
           '',...                   %8
           ''};                     %9
    id1 = {'ATL_RESOURCE',...       %1
           '',...                   %2
           '',...                   %3
           '1',...                  %4
           'ALL',...                %5
           'ALL',...                %6
           'ALL',...                %7
           '',...                   %8
           ''};                     %9 
    pause_vals = [5,10,5];          %   Select time for pauses   
elseif Select_data==5    
    id0 = {'queryname=',...         %1
           '&startdatetime=',...    %2
           '&enddatetime=',...      %3
           '&version=',...          %4
           '&Pnode_id=',...         %5
           '&Pnode_type=',...       %6
           '',...                   %7
           '',...                   %8
           ''};                     %9
    id1 = {'ATL_PNODE',...          %1
           '',...                   %2
           '',...                   %3
           '1',...                  %4
           'ALL',...                %5
           'ALL',...                %6
           '',...                   %7
           '',...                   %8
           ''};                     %9 
    pause_vals = [5,10,5];          %   Select time for pauses   
elseif Select_data==6    
    id0 = {'queryname=',...         %1
           '&startdatetime=',...    %2
           '&enddatetime=',...      %3
           '&version=',...          %4
           '&market_run_id=',...    %5
           '&tac_zone_name=',...    %6
           'schedule=',...          %7
           '',...                   %8
           ''};                     %9
    id1 = {'ENE_SLRS',...           %1
           '',...                   %2
           '',...                   %3
           '1',...                  %4
           'RTM',...                %5
           'ALL',...                %6
           'ALL',...                %7
           '',...                   %8
           ''};                     %9          
    pause_vals = [5,10,5];          %   Select time for pauses
elseif Select_data==7   
    id0 = {'http://oasis.caiso.com/oasisapi/GroupZip?',... %1
           '&groupid=',...          %2
           '&startdatetime=',...    %3
           '&version=',...          %4
           '&resultformat=',...     %5  Create CSV with resultformat=6
           '',...                   %6
           '',...                   %7
           '',...                   %8
           ''};                     %9
    id1 = {'',...                   %1
           'DAM_PRC_AS_GRP',...     %2
           '',...                   %3
           '1',...                  %4
           '6',...                  %5
           '',...                   %6
           '',...                   %7
           '',...                   %8
           ''};                     %9         
    pause_vals = [5,10,5];          %   Select time for pauses
elseif Select_data==8   
    id0 = {'http://oasis.caiso.com/oasisapi/SingleZip?',... %1
           'queryname=',...         %2
           '&startdatetime=',...    %3
           '&enddatetime=',...      %4
           '&version=',...          %5  
           '&market_run_id=',...    %6
           '&node=',...             %7
           '&resultformat=',...     %8 Create CSV with resultformat=6
           ''};                     %9
    id1 = {'',...                   %1
           'PRC_LMP',...            %2
           '',...                   %3
           '',...                   %4
           '1',...                  %5
           'DAM',...                %6
           'DLAP_SCE-APND',...      %7  DLAP: PGAE, SCE, SDGE, VEA
           '6',...                  %8
           ''};                     %9 
    pause_vals = [5,5,5];           %   Select time for pauses
elseif Select_data==9   
    id0 = {'http://oasis.caiso.com/oasisapi/SingleZip?',... %1
           'queryname=',...         %2
           '&startdatetime=',...    %3
           '&enddatetime=',...      %4
           '&version=',...          %5  
           '&market_run_id=',...    %6
           '&node=',...             %7
           '&resultformat=',...     %8 Create CSV with resultformat=6
           ''};                     %9
    id1 = {'',...                   %1
           'PRC_INTVL_LMP',...      %2
           '',...                   %3
           '',...                   %4
           '1',...                  %5
           'DAM',...                %6
           'DLAP_SCE-APND',...     %7  DLAP: PGAE, SCE, SDGE, VEA
           '6',...                  %8
           ''};                     %9 
    pause_vals = [5,5,5];           %   Select time for pauses
end
id00=id0;   %Reserve for later use  
id11=id1;   %Reserve for later use

% % Examples
% PRC_LMP DA
% http://oasis.caiso.com/oasisapi/SingleZip?queryname=PRC_LMP&startdatetime=20130919T07:00-0000&enddatetime=20130920T07:00-0000&version=1&market_run_id=DAM&grp_type=ALL_APNODES
% PRC_AS Regional Shadow prices DA
% http://oasis.caiso.com/oasisapi/SingleZip?queryname=PRC_AS&market_run_id=DAM&startdatetime=20130919T07:00-0000&enddatetime=20130920T07:00-0000&version=1&anc_type=ALL&anc_region=ALL
% PRC_Fuel
% http://oasis.caiso.com/oasisapi/SingleZip?queryname=PRC_FUEL&fuel_region_id=ALL&startdatetime=20130919T07:00-0000&enddatetime=20130920T07:00-0000&version=1
% GRP_AS CSV
% http://oasis.caiso.com/oasisapi/GroupZip?groupid=DAM_AS_GRP&startdatetime=20130919T07:00-0000&version=1
% http://oasis.caiso.com/oasisapi/GroupZip?groupid=HASP_AS_GRP&startdatetime=20130919T07:00-0000&version=1
% http://oasis.caiso.com/oasisapi/SingleZip?queryname=PRC_LMP&startdatetime=20130919T07:00-0000&enddatetime=20130920T07:00-0000&version=1&market_run_id=DAM&node=LAPLMG1_7_B2
%% Select website, download data and save  
for year_val = year_range
    for month_val = month_range
        for day_val = 1:max(max(calendar(year_val,month_val)))
            starttime1 = 'T00:00-0000';     % Set start time
            endtime1 = 'T00:00-0000';       % Set end time
            
            % Create easy to manipulate dates for start and end times
            startdate_num = datenum(year_val,month_val,day_val,0,0,0);  
            enddate_num = datenum(year_val,month_val,day_val+1,0,0,0);
            start_vec = datevec(startdate_num);
            end_vec = datevec(enddate_num);
            
            % Account for values with zeros in front (e.g., 01, 02 vs. 10)
            if start_vec(2)<10, month_zero1 = '0'; else month_zero1 = ''; end
            if end_vec(2)  <10, month_zero2 = '0'; else month_zero2 = ''; end
            if start_vec(3)<10, day_zero1 = '0';   else day_zero1 = '';   end
            if end_vec(3)  <10, day_zero2 = '0';   else day_zero2 = '';   end
            
            % Formulate start and end values to send to CAISO website
            startdate1=[num2str(start_vec(1)),month_zero1,num2str(start_vec(2)),day_zero1,num2str(start_vec(3)),starttime1];
            enddate1  =[num2str(end_vec(1))  ,month_zero2,num2str(end_vec(2))  ,day_zero2,num2str(end_vec(3))  ,endtime1];
            id1(2) = {startdate1};  % Set startdate in id matrix
            id1(3) = {enddate1};    % Set enddate in id matrix

            % Adjust data items order, if necessary
            if Select_data==3   %Adjust elements for PRC_FUEL
                id0 = {id00{1},id00{5},id00{2:4},id00{6:8}};
                id1 = {id11{1},id11{5},startdate1,enddate1,id11{4},id11{6:8}};
            elseif Select_data==7 %Adjust for AS GRP
                id0 = id00;
                id1 = id11;
                id1{3} = startdate1;
            elseif Select_data==8 %Adjust for PRC_LMP
                id0 = id00;
                id1 = id11;
                id1{3} = startdate1;
                id1{4} = enddate1;
            end
            
        %%% Perform data grab from OASIS 
          % Also, check to see if the file size is appropriate, otherwise repeat draw
            file_size_actual = 0;   % Initialize size constraint
            while file_size_actual<file_size        % Used to ensure that the file sizes are correct (I am not sure why they are sometimes too small)
                if Select_data>=7
                     website1 = [id0{1},id1{1},...
                                 id0{2},id1{2},...
                                 id0{3},id1{3},...
                                 id0{4},id1{4},...
                                 id0{5},id1{5},...
                                 id0{6},id1{6},...
                                 id0{7},id1{7},...
                                 id0{8},id1{8},...
                                 ];                                 
                else
                    website1 = ['http://oasis.caiso.com/oasisapi/SingleZip?',...
                            id0{1},id1{1},...
                            id0{2},id1{2},...
                            id0{3},id1{3},...
                            id0{4},id1{4},...
                            id0{5},id1{5},...
                            id0{6},id1{6},...
                            id0{7},id1{7},...
                            id0{8},id1{8},...
                            ];                                
                          % OLD SITE: 'http://oasis.caiso.com/mrtu-oasis/SingleZip?',...
                end
                
                filename1 = [id1{1},'_',id1{2},'_',id1{3},'_',id1{4},'_',id1{5},'_',id1{6},'_',id1{7},'_',id1{8}];                   
                filename2 = strrep(filename1,':','');
                try    websave([Save_files,filename2,'.zip'],website1); 
                       pause(pause_vals(1));    % Need to pause to allow file to download and save
                catch, pause(pause_vals(2));    %%urlwrite(website1,[Save_files,filename2,'.zip']);    
                end
                progress_calc3 = (datenum(year_val,month_val,day_val,0,0,0)-progress_calc1)/(progress_calc2-progress_calc1);
                time1 = toc;
                predicted_time = time1/progress_calc3;
                disp([num2str(round(progress_calc3*100*10)/10),'% Complete    ',num2str(year_val),'-',month_zero1,num2str(month_val),'-',day_zero1,num2str(day_val),'    ',num2str(round(time1/60)),'min of ',num2str(round(predicted_time/60)),'min'])
                try
                    dirInfo = dir([Save_files,filename2,'.zip']);  %# Where dirName is the directory name where the file is located
                    file_size_actual = dirInfo.bytes/1000;  %# The size of the file, in bytes 
                catch, pause(pause_vals(3));  
                end
            end
        end
    end
end
       

%% Test Section  
if 1==0
% % % Old version (2009?)
%                     website1 = (['http://oasis.caiso.com/oasisapi/SingleZip?queryname=PRC_LMP',...
%                                 '&startdatetime=20140101T07:00-0000&enddatetime=20140101T07:00-0000',...
%                                 '&version=1&market_run_id=DAM&grp_type=ALL_APNODES']); %&node=LAPLMG1_7_B2']; %
% % % New Version (2014)
% website1 = (['http://oasis.caiso.com/oasisapi/SingleZip?queryname=PRC_LMP',...
%             '&startdatetime=20130919T07:00-0000&enddatetime=20130920T07:00-0000',...
%             '&version=1&market_run_id=DAM&grp_type=ALL_APNODES']);                        
% website2 = (['http://oasis.caiso.com/oasisapi/SingleZip?queryname=PRC_LMP',...
%             '&startdatetime=20130101T08:00-0000&enddatetime=20130102T08:00-0000',...
%             '&version=1&market_run_id=DAM&grp_type=ALL_APNODES']);
% website1 = (['http://oasis.caiso.com/oasisapi/SingleZip?queryname=PRC_FUEL',...
%             '&fuel_region_id=ALL',...
%             '&startdatetime=20130919T07:00-0000&enddatetime=20130920T07:00-0000&version=1']);
% website1 = (['http://oasis.caiso.com/oasisapi/SingleZip?queryname=ATL_RESOURCE',...
%              '&resource_id=ALL&agge_type=ALL&resource_type=ALL&',...
%              'startdatetime=20140101T00:00-0000&enddatetime=20140101T00:00-0000&version=1']);
% website1 = (['http://oasis.caiso.com/oasisapi/SingleZip?queryname=ATL_PNODE',...
%              '&Pnode_id=ALL&Pnode_type=ALL&startdatetime=20130919T07:00-0000&enddatetime=20130920T07:00-0000&version=1']);
% website1 = (['

% % ENE_SLRS__DA         
website1 = (['http://oasis.caiso.com/oasisapi/SingleZip?queryname=ENE_SLRS&market_run_id=RTM',...
             '&tac_zone_name=ALL&schedule=ALL&startdatetime=20130919T00:00-0000&enddatetime=20130920T00:00-0000&version=1']);

% % ENE_EA   Expected_Energy
% http://oasis.caiso.com/oasisapi/SingleZip?queryname=ENE_EA&energy_type=ALL&opr_interval=ALL&startdatetime=20130919T07:00-0000&enddatetime=20130920T07:00-0000&version=1


startdatetime = '20130919T07:00-0000';
enddatetime   = '20130919T08:00-0000';

startdate1 = startdatetime;
% website1 = (['http://oasis.caiso.com/oasisapi/GroupZip?groupid=DAM_LMP_GRP',...
%              '&startdatetime=',startdatetime,'&version=1']);

% If grp_type = "All" or "All_APNODES" then query will ignore enddatetime and return 1 day of data

filename2 = ['DAM_LMP_',strrep(startdate1,':','_')];
urlwrite(website1,[Save_files,filename2,'.zip']);

end


