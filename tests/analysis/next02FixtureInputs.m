function [P,SB,UB]=next02FixtureInputs(k)
% Exact frozen tiny native masks; no detection or source-movie reconstruction.
switch k
case 1
P={[],[1],[],[]};
SB=[2 2];
UB=[2 2];
case 2
P={[1;2],[2;3],[],[]};
SB=[1 3];
UB=[1 2];
case 3
P={[1;2],[2;3],[],[]; ...
[],[3;4],[],[]};
SB=[1 2;2 2];
UB=[1 2;2 2];
case 4
P={[1;2],[2;3],[],[]; ...
[],[3;4],[],[]};
SB=[1 2;2 2];
UB=[1 2;2 2];
case 5
P={[1;2],[1;2],[1;2],[]; ...
[],[],[],[3]};
SB=[1 3;4 4];
UB=[1 3;4 4];
case 6
P=cell(0,4);
SB=[];
UB=[];
case 7
P={[],[1;2],[1;2],[]};
SB=[2 3];
UB=[2 3];
case 8
P={[],[1],[],[]};
SB=[2 2];
UB=[2 2];
otherwise,error('Unknown frozen fixture');
end
end
