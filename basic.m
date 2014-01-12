% basic hybrid copy migration
% memory size in MB
r = 4096

% bandwidth in gbps
b = 1000 

dirtyrate = 4 % percent (%)

pagesize = 4 % in KB
numpages = r * 1024 / pagesize

% delta compression rate
comp = 0.5 

% amount of CPU and device states in KB 
scinfo = 100
% stop-and-copy time in ms
sctime = 10 

% 0: zero, 1: dirtied, 2: read, 3: inactive data
mem = zeros(1, numpages);

totaltime = 0
downtime = 0
totaldata = 0

% precopy phase
% LRU, PFR
% send the pages most likely to be read
reads = numpages * 0.4 

% scan the dirtied pages
% for dirtied pages
% 	mark dirtied (1)
% for read pages
% 	mark read (2)

% for pages
% 	predict read/write

% LRU
% for LRU queue
% 	mark sent
%	insert the pages into cache and perform delta compression

present = reada * pagesize
pretime = present/b
totaltime += pretime
totaldata += present

% stop-and-copy phase
% send the CPU and device states
downtime = scinfo/b

% postcopy phase
postsent = (numpages - reads) * pagesize
posttime = postsent/b
totaltime += posttime
totaldata += postsent

