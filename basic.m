% basic hybrid copy migration
% memory size in MB
r = 512

% bandwidth in gbps
b = 1000 

dirtyrate = 4 % percent (%)

pagesize = 4 % in KB
pages = r * 1024 / pagesize

% amount of CPU and device states in KB 
scinfo = 100
% stop-and-copy time in ms
sctime = 10 

mem = zeros(pages)

totaltime = 0
downtime = 0

% precopy phase
% LRU, PFR
% send the pages most likely to be read
pretime = 100/b
totaltime += pretime

% stop-and-copy phase
% send the CPU and device states
downtime = scinfo/b

% postcopy phase
posttime = 199/b
totaltime += posttime
