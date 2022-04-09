function [varargout] = rdir(rootdir,varargin)
%% Lists the files in a directory and its sub directories. 

if ~exist('rootdir','var')
  rootdir = '*';
end

prepath = '';       
wildpath = '';      
postpath = rootdir;
I = find(rootdir==filesep,1,'last');
if ~isempty(I)
  prepath = rootdir(1:I);
  postpath = rootdir(I+1:end);
  I = find(prepath=='*',1,'first');
  if ~isempty(I)
    postpath = [prepath(I:end) postpath];
    prepath = prepath(1:I-1);
    I = find(prepath==filesep,1,'last');
    if ~isempty(I)
      wildpath = prepath(I+1:end);
      prepath = prepath(1:I);
    end
    I = find(postpath==filesep,1,'first');
    if ~isempty(I)
      wildpath = [wildpath postpath(1:I-1)];
      postpath = postpath(I:end);
    end
  end
end

if isempty(wildpath)
  D = dir([prepath postpath]);
  D([D.isdir]==1) = [];
  for ii = 1:length(D)
    if (~D(ii).isdir)
      D(ii).name = [prepath D(ii).name];
    end
  end


elseif strcmp(wildpath,'**')

  D = rdir([prepath postpath(2:end)]);

  Dt = dir(''); 
  tmp = dir([prepath '*']);
  for ii = 1:length(tmp)
    if (tmp(ii).isdir && ~strcmpi(tmp(ii).name,'.') && ~strcmpi(tmp(ii).name,'..') )
      Dt = [Dt; rdir([prepath tmp(ii).name filesep wildpath postpath])];
    end
  end
  D = [D; Dt];

else
  tmp = dir([prepath wildpath]);
  D = dir(''); 
  for ii = 1:length(tmp)
    if (tmp(ii).isdir && ~strcmpi(tmp(ii).name,'.') && ~strcmpi(tmp(ii).name,'..') )
      D = [D; rdir([prepath tmp(ii).name postpath])];
    end
  end
end


if (nargin>=2 && ~isempty(varargin{1}))
  date = [D.date];
  datenum = [D.datenum];
  bytes = [D.bytes];

  try
    eval(sprintf('D((%s)==0) = [];',varargin{1})); 
  catch
    warning('Error: Invalid TEST "%s"',varargin{1});
  end
end

if nargout==0
  pp = {'' 'k' 'M' 'G' 'T'};
  for ii=1:length(D)
    sz = D(ii).bytes;
    if sz<=0
      disp(sprintf(' %31s %-64s','',D(ii).name)); 
    else
      ss = min(4,floor(log2(sz)/10));
      disp(sprintf('%4.0f %1sb   %20s   %-64s ',sz/1024^ss,pp{ss+1},D(ii).date,D(ii).name)); 
    end
  end
else
  % send list out
  varargout{1} = D;
end
