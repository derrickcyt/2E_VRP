clear all
close all
clc

addpath('function');
%% read data
setName='set2';
filename='E-n51-k5-s11-19.dat';
source=importdata(strcat('dataset/',setName,'/',filename),'',9999999);
readdata;

refFilename='11_19_mine.txt';
TotalResult=readResult(strcat('result/reference/',refFilename));

plotResult(TotalResult,CusPos,SatPos,CenterPos);