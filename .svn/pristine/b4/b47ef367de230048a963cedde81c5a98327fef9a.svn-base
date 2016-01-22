clear all
close all
clc

addpath('../function');
addpath('..');
%% read data
setName='set2';
filename='E-n51-k5-s11-19.dat';
source=importdata(strcat('../dataset/',setName,'/',filename),'',9999999);
readdata;

Cus2CusDist=calCus2CusDist(CusPos);
Sat2SatDist=calSat2SatDist(SatPos);
Center2SatDist=calCenter2SatDist(CenterPos,SatPos);
Sat2CusDist=calSatCusDist(SatPos,CusPos);

%% read old result
oldResultFileName='28-Dec-2015_E-n51-k5-s11-19.dat';
OldResult=readResult(strcat('../result/test/',oldResultFileName));

%plotResult(OldResult,CusPos,SatPos,CenterPos);

CVRPABC( OldResult,2,CusPos,SatPos,CenterPos,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts );