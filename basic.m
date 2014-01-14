% basic hybrid copy migration
% memory size in MB
r = 4096
r *= 1024 % convert to KB

% bandwidth in gbps
b = 1000 
b = b * 1024/8 % convert to KB

% page dirty rate in percent (%): against to total memory pages
dirtyrate = 4 
dirtyrate /= 100

pagesize = 4 % in KB
numpages = r / pagesize

% delta compression rate
comp = 0.5 

% amount of CPU and device states in KB 
scinfo = 100

% working set size in number of pages
wss = numpages * 0.25

% 0: zero, 1: read, 2: dirtied, 3: inactive data
mem = zeros(1, numpages);

% prediction accuracy 0 through 1
acc = 1

totaltime = 0;
downtime = 0;
totaldata = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% precopy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n')
disp('Precopy migration')
% iterations
present = r
pretime = present / b
totaltime += pretime
totaldata += present

% stop-and-copy phase
dirts = wss * dirtyrate
scsent = scinfo + dirts
downtwime = scsent / b
totaltime += downtime
totaldata += scsent

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% postcopy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n')
disp('Postcopy migration')
totaltime = 0;
downtime = 0;
totaldata = 0;

% stop-and-copy phase
scsent = scinfo
downtime = scsent / b
totaltime += downtime
totaldata += scsent

% prepaging (bubbling) and on-demand paging
postsent = r
posttime = postsent/b
totaldata += postsent
% network fault rate
NFR = 0.2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hybrid copy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n')
disp('Hybrid copy migration')
totaltime = 0;
downtime = 0;
totaldata = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% proactive hybrid copy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp(char(10))
fprintf('\n')
disp('Proactive hybrid copy migration')
totaltime = 0;
downtime = 0;
totaldata = 0;

% precopy phase
% LRU, PFR

% scan the dirtied pages
% for dirtied pages
% 	mark dirtied (1)
% 	mem(random (1, wss * 0.1))	
randperm(int64(wss * 0.1));
% for read pages
% 	mark read (2)
% 	mem (random (wss * 0.1, wss * 0.2))

% for pages
% 	predict read/write

% send the pages most likely to be read and least likely to be dirtied
% construct queue with the order of p1/p2
%reads = numpages * 0.4 
% total read rate = wss * read_rate = 0.25 * 0.16 = 0.04 (4%)
read_rate = 0.16
read_rate = 0.04 % 4% of total memory
% total write rate = wss * write_rate = 0.25 * 0.16 = 0.04 (4%)
write_rate = 0.16
write_rate = 0.04 % 4% of total memory
% simple case: readonly pages (RO) - zero dirtied pages 
RO = 0.3
pred_pages = wss * RO

% LRU
% for LRU queue
% 	mark sent
%	insert the pages into cache and perform delta compression

present = pred_pages * pagesize
pretime = present/b
totaltime += pretime
totaldata += present

% stop-and-copy phase
% send the CPU and device states
bitmapsize = 500 % KB
scsent = scinfo + bitmapsize
downtime = scsent/b
totaltime += downtime
totaldat += scsent

% postcopy phase
postsent = (numpages - reads) * pagesize

% exclude the predicted dirtied pages 
pred_dirts = numpages * 0.1
postsent = (numpages - reads - pred_dirts) * pagesize
posttime = postsent/b
totaltime += posttime
totaldata += postsent

