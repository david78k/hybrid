% basic hybrid copy migration
% memory size in MB
r = 4096
r *= 1024 % convert to KB

% bandwidth in gbps
b = 1000 
b = b * 1024/8 % convert to KB

% page dirty rate in percent (%): against to total memory pages
dirtyrate = 14 
dirtyrate /= 100

readrate = 14
readrate /= 100

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
%acc = 0

fontsize = 18

totaltime = 0;
downtime = 0;
totaldata = 0;

A = zeros(4, 3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% precopy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n')
disp('==================== Precopy migration ====================')
% iterations
present = numpages
iter = 0
while present > 50 && iter < 29 && totaldata < 4*r
	pretime = present / b
	totaltime += pretime
	totaldata += present
	present = numpages * dirtyrate
	%dirts = wss * dirtyrate
	iter += 1
end

% stop-and-copy phase
% stop conditions: 29 iterations, 50 pages, 4 memory size sent
scsent = scinfo + present * pagesize
downtime = scsent / b
totaltime += downtime
totaldata += scsent

% network fault rate
NFR = 0

A (1, 1) = totaltime;
A (1, 2) = downtime;
A (1, 3) = totaldata;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% postcopy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n')
disp('===================== Postcopy migration ======================')
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
totaltime += posttime
totaldata += postsent
% network fault rate
NFR = 0.2

A (2, 1) = totaltime;
A (2, 2) = downtime;
A (2, 3) = totaldata;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hybrid copy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n')
disp('==================== Hybrid copy migration ====================')
totaltime = 0;
downtime = 0;
totaldata = 0;

% precopy phase: single iteration
present = r
pretime = present / b
totaltime += pretime
totaldata += present

% stop-and-copy phase
bitmapsize = 500 % KB
scsent = scinfo + bitmapsize
downtime = scsent / b
totaltime += downtime
totaldata += scsent

% postcopy phase: prepaging (bubbling) and on-demand paging
%dirts = wss * dirtyrate
dirts = numpages * dirtyrate
postsent = dirts * pagesize
posttime = postsent/b
totaltime += posttime
totaldata += postsent
% network fault rate
NFR = 0.2

A (3, 1) = totaltime;
A (3, 2) = downtime;
A (3, 3) = totaldata;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% proactive hybrid copy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp(char(10))
fprintf('\n')
disp('=============== Proactive hybrid copy migration ================')
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
% do not send the pages most likely to be dirtied
% construct queue with the order of p1/p2
%reads = numpages * 0.4 
% total read rate = wss * read_rate = 0.25 * 0.16 = 0.04 (4%)
%read_rate = 0.16
%read_rate = 0.04 % 4% of total memory
% total write rate = wss * write_rate = 0.25 * 0.16 = 0.04 (4%)
%write_rate = 0.16
%write_rate = 0.04 % 4% of total memory
% simple case: readonly pages (RO) - zero dirtied pages 
%RO = 0.3
pred_pages = numpages * readrate * acc

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
totaldata += scsent

% postcopy phase
postsent = (numpages - pred_pages) * pagesize

% exclude the predicted dirtied pages 
pred_dirts = numpages * dirtyrate * acc
postsent = (numpages - pred_pages - pred_dirts) * pagesize
posttime = postsent/b
totaltime += posttime
totaldata += postsent

% network fault rate
NFR = 0.2

A (4, 1) = totaltime;
A (4, 2) = downtime;
A (4, 3) = totaldata

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     plotting
% precopy
% postcopy
% hybrid
% pro-hybrid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prefix = "M4G_R14W14_acc100_r1"

dlmwrite (prefix, A, ' ')

%%%%%%%%%%%%%%%%%%%% total time %%%%%%%%%%%%%%%%%%%%%%
figure;
output = strcat(prefix, ".tt");
%output = prefix
x = ['PRECOPY', 'POSTCOPY', 'HYBRID', 'PRO-HYBRID'];
x = ['', 'PRE', 'POST', 'HYBR', 'PROH', ''];
%x = 1:1:length(A);
%plot(x, A(:,2)/1000000, x, A(:,3)/1000000, '-.*');
%plot(A(:,2));
bar(A(:,1))
set(gca, 'XTickLabel', x, 'FontSize', fontsize)
xlabel('COPY METHOD', 'FontSize', fontsize);
ylabel('TIME (SEC)', 'FontSize', fontsize);
%legend('PRECOPY', 'POSTCOPY', 'HYBRID', 'PRO-HYBRID');
%bar(x, A(:,1))

saveas (1, strcat(output, ".png"));
saveas (1, strcat(output, ".eps"));
saveas (1, strcat(output, ".emf"));

%%%%%%%%%%%%%%%%%%%% downtime %%%%%%%%%%%%%%%%%%%%%%
figure;
output = strcat(prefix, ".dt");

bar(A(:,2))
set(gca, 'XTickLabel', {'', 'PRECOPY', 'POSTCOPY', 'HYBRID', 'PRO-HYBRID', ''}, 'FontSize', fontsize - 2)
xlabel('COPY METHOD', 'FontSize', fontsize);
ylabel('TIME (SEC)', 'FontSize', fontsize);

saveas (1, strcat(output, ".png"));
saveas (1, strcat(output, ".eps"));
saveas (1, strcat(output, ".emf"));

%%%%%%%%%%%%%%%%%%%% total data %%%%%%%%%%%%%%%%%%%%%%
figure;
output = strcat(prefix, ".td");

bar(A(:,3))
set(gca, 'XTickLabel', {'', 'PRECOPY', 'POSTCOPY', 'HYBRID', 'PRO-HYBRID', ''}, 'FontSize', fontsize - 2)
xlabel('COPY METHOD', 'FontSize', fontsize);
ylabel('SIZE (KB)', 'FontSize', fontsize);

saveas (1, strcat(output, ".png"));
saveas (1, strcat(output, ".eps"));
saveas (1, strcat(output, ".emf"));


