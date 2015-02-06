addpath learning;
addpath detection;
addpath visualization;
addpath evaluation;
addpath cache;
addpath dataset;
addpath dataset/TUD;
addpath dataset/TUD/train-210;
addpath dataset/TUD/train-210-neg;
addpath dataset/INRIA;
addpath dataset/PARSE;
addpath dataset/BUFFY;
addpath dataset/BUFFY/data;
addpath dataset/BUFFY/images/buffy_s5e2_original;
addpath dataset/BUFFY/images/buffy_s5e3_original;
addpath dataset/BUFFY/images/buffy_s5e4_original;
addpath dataset/BUFFY/images/buffy_s5e5_original;
addpath dataset/BUFFY/images/buffy_s5e6_original;
addpath dataset/BUFFY/labels;
addpath dataset/LSP;
addpath dataset/LSP/images;
addpath dataset/LSP/visualized;
addpath dataset/LSP/dpm-neg;
addpath(genpath('/home/ruan/comman/lib/vlfeat-0.9.18'));
addpath Kun_Liu;

if isunix()
    addpath mex_unix;
elseif ispc()
    addpath mex_pc;
end

% directory for caching models, intermediate data, and results
cachedir = 'cache/';
if ~exist(cachedir,'dir')
  mkdir(cachedir);
end
