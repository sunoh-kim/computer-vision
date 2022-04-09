function params = get_params(file_name)
%% Testing if param file exists in the params directory
if exist(['params',filesep,strcat(file_name,'.mat')],'file')
    params = load(['params',filesep,strcat(file_name,'.mat')]);
    
elseif exist(strcat(file_name,'.mat'),'file')
    params = load(strcat(file_name,'.mat'));
    
else
    [param_file,PathName,~] = uigetfile('*.mat',strcat('Select parameter file (',file_name,')'));
    if ~isa(param_file,'double')
        params = load([PathName,filesep,param_file]);
    else
        fprintf('Errors : Missing param file...\nexiting...\n\n');
        return
    end
end

end
