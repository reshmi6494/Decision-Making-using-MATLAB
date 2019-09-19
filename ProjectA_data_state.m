addpath('/Applications/GAMS24.8/sysdir')%make sure to change the directory name, if necessary

clear all;
clear workspace;

NParcel = 50;
NTime = 50;
NTime49 = 49;
Ncrop = 4;
NSenario = 3; 

p.name = 'p';
p.type = 'set';
p.val  = [linspace(1,NParcel,NParcel)]';

t.name = 't';
t.type = 'set';
t.val  = [linspace(1,NTime,NTime)]';


c.name = 'c';
c.type = 'set';
c.val  = [linspace(1,Ncrop,Ncrop)]';

s.name = 's';
s.type = 'set';
s.val  = [linspace(1,NSenario,NSenario)]';

% break the parcel capacities into 2 parameter matrix

ParcelCapacitiesTemp.val = csvread('capacity_state.csv');

K.name = 'K';
K.type = 'parameter';
K.val = ParcelCapacitiesTemp.val(:,2)';
K.form = 'full';
K.dim = 1;

prob.name = 'p';
prob.type = 'parameter';
prob.val = ParcelCapacitiesTemp.val(:,1);
prob.form = 'full';
prob.dim = 1;

ParcelState.name = 'ParcelState';
ParcelState.type = 'parameter';
ParcelState.val = ParcelCapacitiesTemp.val(:,1);
ParcelState.form = 'full';
ParcelState.dim = 1;

% convert cost of each state to each parcel

Cost.val = zeros(Ncrop,NParcel);

CostInitialState.val = csvread('cost_initial.csv');
for loopi = 1:NParcel
    for loopj = 1:Ncrop
        Cost.val(loopj,loopi) = CostInitialState.val ( loopj, ParcelState.val(loopi));
    end
end

Cost.name = 'Cost';
Cost.type = 'parameter';
Cost.form = 'full';
Cost.dim = 2;

% calculate USA demand from global demand

d.val=zeros(Ncrop,NTime);

GlobalDemand.val = csvread('demand.csv');
USAShare = [0.54, 0.23, 0.09, 0.02];
for loopi = 1:Ncrop
    for loopj = 1: NTime
    d.val(loopi,loopj) = GlobalDemand.val(loopi,loopj)*USAShare(loopi);
    end
end
d.name = 'd';
d.type = 'parameter';
d.form = 'full';
d.dim = 2;

Q.name = 'Q';
Q.type = 'parameter';
Q.val = csvread('quantities_state.csv');
Q.form = 'full';
Q.dim = 2;

yield1_maize.val = csvread('yield1_maize_state.csv');
yield2_maize.val = csvread('yield2_maize_state.csv');
yield3_maize.val = csvread('yield3_maize_state.csv');

yield1_soybeans.val = csvread('yield1_soybeans_state.csv');
yield2_soybeans.val = csvread('yield2_soybeans_state.csv');
yield3_soybeans.val = csvread('yield3_soybeans_state.csv');

yield1_wheat.val = csvread('yield1_wheat_state.csv');
yield2_wheat.val = csvread('yield2_wheat_state.csv');
yield3_wheat.val = csvread('yield3_wheat_state.csv');

yield1_rice.val = csvread('yield1_rice_state.csv');
yield2_rice.val = csvread('yield2_rice_state.csv');
yield3_rice.val = csvread('yield3_rice_state.csv');

% read 3 senarios and 4 types of corp into one matrix

Yield1Temp = zeros(NParcel,Ncrop,NTime);
Yield2Temp = zeros(NParcel,Ncrop,NTime);
Yield3Temp = zeros(NParcel,Ncrop,NTime);
for loopi = 1: NParcel 
    for loopj = 1: NTime
    Yield1Temp(loopi,1,loopj) = yield1_maize.val (loopi,loopj);
    Yield1Temp(loopi,2,loopj) = yield1_soybeans.val (loopi,loopj);
    Yield1Temp(loopi,3,loopj) = yield1_wheat.val (loopi,loopj);
    Yield1Temp(loopi,4,loopj) = yield1_rice.val (loopi,loopj);
    
    Yield2Temp(loopi,1,loopj) = yield2_maize.val (loopi,loopj);
    Yield2Temp(loopi,2,loopj) = yield2_soybeans.val (loopi,loopj);
    Yield2Temp(loopi,3,loopj) = yield2_wheat.val (loopi,loopj);
    Yield2Temp(loopi,4,loopj) = yield2_rice.val (loopi,loopj);
    
    Yield3Temp(loopi,1,loopj) = yield3_maize.val (loopi,loopj);
    Yield3Temp(loopi,2,loopj) = yield3_soybeans.val (loopi,loopj);
    Yield3Temp(loopi,3,loopj) = yield3_wheat.val (loopi,loopj);
    Yield3Temp(loopi,4,loopj) = yield3_rice.val (loopi,loopj);
    
    end
end

y1.name = 'y1';
y1.type = 'parameter';
y1.form = 'full';
y1.val = Yield1Temp;
y1.dim = 3;

y2.name = 'y2';
y2.type = 'parameter';
y2.form = 'full';
y2.val = Yield2Temp;
y2.dim = 3;

y3.name = 'y3';
y3.type = 'parameter';
y3.form = 'full';
y3.val = Yield3Temp;
y3.dim = 3;

prob.name = 'prob';
prob.type = 'parameter';
prob.form = 'full';
prob.val = [0.3333333333,0.3333333333,0.3333333333];
prob.dim = 1;

wgdx ('ProjectA_inputs', p, t, c, s, K,ParcelState,Cost,d, Q, prob, y1,y2,y3);

gams ('Model-V1.gms')

output_structure = struct('name','Y','form','full');
output = rgdx (strcat('problema_outputs'), output_structure);
Y = output.val;
Y = Y(:,1:4,:);

output_structure = struct('name','z','form','full');
output = rgdx (strcat('problema_outputs'), output_structure);
z = output.val;






