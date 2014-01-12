% basic hybrid copy migration
% memory size in MB
r = 4096

% bandwidth in gbps
b = 1000 
b = b * 1024/8 % convert to KB

dirtyrate = 4 % percent (%)

pagesize = 4 % in KB
numpages = r * 1024 / pagesize

% delta compression rate
comp = 0.5 

% amount of CPU and device states in KB 
scinfo = 100

% working set size
wss = numpages * 0.25

% 0: zero, 1: read, 2: dirtied, 3: inactive data
mem = zeros(1, numpages);

totaltime = 0
downtime = 0
totaldata = 0

% precopy phase
% LRU, PFR

% scan the dirtied pages
% for dirtied pages
% 	mark dirtied (1)
% 	mem(random (1, wss * 0.1))	
% for read pages
% 	mark read (2)
% 	mem (random (wss * 0.1, wss * 0.2))

% for pages
% 	predict read/write

% send the pages most likely to be read
reads = numpages * 0.4 

% LRU
% for LRU queue
% 	mark sent
%	insert the pages into cache and perform delta compression

present = reads * pagesize
pretime = present/b
totaltime += pretime
totaldata += present

% stop-and-copy phase
% send the CPU and device states
bitmapsize = 500 % KB
downtime = (scinfo + bitmapsize)/b

% postcopy phase
postsent = (numpages - reads) * pagesize

% exclude the predicted dirtied pages 
pred_dirts = numpages * 0.1
postsent = (numpages - reads - pred_dirts) * pagesize
posttime = postsent/b
totaltime += posttime
totaldata += postsent

