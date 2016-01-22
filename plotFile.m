clear all
close all
clc

addpath('function');
%% read data
setName='set2';
filename='E-n33-k4-s14-22.dat';
source=importdata(strcat('dataset/',setName,'/',filename),'',9999999);
readdata;

%% read old result
oldResultFileName='31-Dec-2015_2_300_E-n33-k4-s14-22.dat';
OldResult=readResult(strcat('result/set2/',oldResultFileName));

plotResult(OldResult,CusPos,SatPos,CenterPos);