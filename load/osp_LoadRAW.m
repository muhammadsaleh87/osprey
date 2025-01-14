function [MRSCont] = osp_LoadRAW(MRSCont)
%% [MRSCont] = osp_LoadRAW(MRSCont)
%   This function reads data from LCModel .RAW files.
%
%   USAGE:
%       [MRSCont] = osp_LoadRAW(MRSCont);
%
%   INPUTS:
%       MRSCont     = Osprey MRS data container.
%
%   OUTPUTS:
%       MRSCont     = Osprey MRS data container.
%
%   AUTHOR:
%       Dr. Georg Oeltzschner (Johns Hopkins University, 2021-08-16)
%       goeltzs1@jhmi.edu
%   
%   CREDITS:    
%       This code is based on numerous functions from the FID-A toolbox by
%       Dr. Jamie Near (McGill University)
%       https://github.com/CIC-methods/FID-A
%       Simpson et al., Magn Reson Med 77:23-33 (2017)

% Close any remaining open figures
close all;
warning('off','all');
if MRSCont.flags.hasMM %re_mm adding functionality to load MM data
    if ((length(MRSCont.files_mm) == 1) && (MRSCont.nDatasets(1)>1))   %re_mm seems like specificy one MM file for a batch is also an option to plan to accomodate
        for kk=2:MRSCont.nDatasets(1) %re_mm 
            MRSCont.files_mm{kk} = MRSCont.files_mm{1}; % re_mm allowable to specify one MM file for the whole batch
        end %re_mm 
    end   %re_mm 
    if ((length(MRSCont.files_mm) ~= MRSCont.nDatasets(1)) )   %re_mm 
        msg = 'Number of specified MM files does not match number of specified metabolite files.'; %re_mm 
        fprintf(msg);
        error(msg);
    end   %re_mm 
end   %re_mm 
if MRSCont.flags.hasRef
    if length(MRSCont.files_ref) ~= MRSCont.nDatasets(1)
        msg = 'Number of specified reference files does not match number of specified metabolite files.'; %re_mm 
        fprintf(msg);
        error(msg);
    end
end
if MRSCont.flags.hasWater
    if length(MRSCont.files_w) ~= MRSCont.nDatasets(1)
        msg = 'Number of specified water files does not match number of specified metabolite files.'; %re_mm 
        fprintf(msg);
        error(msg);
    end
end

%% Get the data (loop over all datasets)
refLoadTime = tic;
if MRSCont.flags.isGUI
    progressText = MRSCont.flags.inProgress;
else
    progressText = '';
end
for kk = 1:MRSCont.nDatasets(1)
    for ll = 1: 1:MRSCont.nDatasets(2)
        [~] = printLog('OspreyLoad',kk,ll,MRSCont.nDatasets,progressText,MRSCont.flags.isGUI ,MRSCont.flags.isMRSI);     
        if ~(MRSCont.flags.didLoadData == 1 && MRSCont.flags.speedUp && isfield(MRSCont, 'raw') && (kk > length(MRSCont.raw))) || ~strcmp(MRSCont.ver.Osp,MRSCont.ver.CheckOsp)

            % Read in the raw metabolite data. For now, this is only defined
            % for unedited data.
            metab_ll = MRSCont.opts.MultipleSpectra.metab(ll);
            if MRSCont.flags.isUnEdited
                raw         = io_loadspec_lcmraw(MRSCont.files{metab_ll,kk});
                raw.flags.isUnEdited = 1;    
            end
            MRSCont.raw{metab_ll,kk}      = raw;

            % Read in the raw MM data. re_mm
            if MRSCont.flags.hasMM %re_mm
                temp_ll = MRSCont.opts.MultipleSpectra.mm(ll);
                if MRSCont.flags.isUnEdited %re_mm
                    raw_mm = io_loadspec_lcmraw(MRSCont.files_mm{temp_ll,kk}); %re_mm
                    raw_mm.flags.isUnEdited = 1; 
                end
                MRSCont.raw_mm{temp_ll,kk}  = raw_mm;
            end %re_mm      

            % Read in the raw reference data.
            if MRSCont.flags.hasRef
                ref_ll = MRSCont.opts.MultipleSpectra.ref(ll);
                if MRSCont.flags.isUnEdited
                    raw_ref = io_loadspec_lcmraw(MRSCont.files_ref{ref_ll,kk});
                    raw_ref.flags.isUnEdited = 1;
                end
                MRSCont.raw_ref{ref_ll,kk}  = raw_ref;
            end

            % Read in the raw short-TE water data.
            if MRSCont.flags.hasWater
                w_ll = MRSCont.opts.MultipleSpectra.w(ll);
                raw_w   = io_loadspec_lcmraw(MRSCont.files_w{w_ll,kk});
                raw_w.flags.isUnEdited = 1;
                MRSCont.raw_w{w_ll,kk}    = raw_w;
            end
        end
    end
end
time = toc(refLoadTime);
[~] = printLog('done',time,ll,MRSCont.nDatasets,progressText,MRSCont.flags.isGUI ,MRSCont.flags.isMRSI);  

% Set flags
MRSCont.flags.coilsCombined     = 1;
MRSCont.flags.skipProcess       = 1; % don't do any processing

MRSCont.runtime.Load = time;

end