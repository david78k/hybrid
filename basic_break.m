% basic hybrid copy migration
	global wss numpages readrate dirtyrate pagesize b scinfo
	global totaltime downtime totaldata

% memory size in MB
r = 4096
r *= 1024 % convert to KB

% page dirty rate in percent (%): against to total memory pages
readrate = 50
prefix = strcat ("M4G_R", num2str(readrate))
readrate /= 100

dirtyrate = 50 
prefix = strcat (prefix, "_W", num2str(dirtyrate))
dirtyrate /= 100

% prediction accuracy 0 through 1
acc = 0

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

run = 1

%prefix = strcat (prefix, "_acc", num2str(acc), "_r", num2str(run))

% bandwidth in gbps
b = 1000 
b = b * 1024/8 % convert to KB

%fontsize = 10
fontsize = 18
%fontsize = 20

totaltime = 0;
downtime = 0;
totaldata = 0;

numrows = 8;
A = zeros(numrows, 3);
row = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% precopy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n')
disp('==================== Precopy migration ====================')
% iterations
present = numpages * pagesize
iter = 0
while present > 50 && iter < 29 && totaldata < 4*r
	pretime = present / b
	totaltime += pretime
	totaldata += present
	present = numpages * pagesize * dirtyrate 
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

A (row, 1) = totaltime;
A (row, 2) = downtime;
A (row, 3) = totaldata;

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

row ++
A (row, 1) = totaltime;
A (row, 2) = downtime;
A (row, 3) = totaldata;

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
bitmapsize = numpages * dirtyrate/8/1024 % KB
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

row ++
A (row, 1) = totaltime;
A (row, 2) = downtime;
A (row, 3) = totaldata;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% proactive hybrid copy migration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp(char(10))
fprintf('\n')
disp('=============== Proactive hybrid copy migration ================')

function [tt, dt, td] = prohybrid(acc)
	global wss numpages readrate dirtyrate pagesize b scinfo
	global totaltime downtime totaldata

	totaltime = 0;
	downtime = 0;
	totaldata = 0;

% precopy phase
% LRU, PFR

% scan the dirtied pages
% for dirtied pages
% 	mark dirtied (1)
% 	mem(random (1, wss * 0.1))	
%randperm(int64(wss * 0.1));
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
	bitmapsize = numpages * dirtyrate / 8 / 1024 % KB
	scsent = scinfo + bitmapsize
	downtime = scsent/b
	totaltime += downtime
	totaldata += scsent

	% postcopy phase
	postsent = (numpages - pred_pages) * pagesize

	% exclude the predicted dirtied pages 
	%pred_dirts = numpages * dirtyrate * acc
	pred_dirts = 0;
	postsent = (numpages - pred_pages - pred_dirts) * pagesize
	posttime = postsent/b
	totaltime += posttime
	totaldata += postsent
end

% network fault rate
NFR = 0.2

prohybrid(acc); row ++;
A (row, 1) = totaltime;
A (row, 2) = downtime;
A (row, 3) = totaldata;

acc = 0.25; row ++;
prohybrid(acc);
A (row, 1) = totaltime;
A (row, 2) = downtime;
A (row, 3) = totaldata;

acc = 0.5
prohybrid(acc); row ++;
A (row, 1) = totaltime;
A (row, 2) = downtime;
A (row, 3) = totaldata;

acc = 0.75
prohybrid(acc); row ++;
A (row, 1) = totaltime;
A (row, 2) = downtime;
A (row, 3) = totaldata;

acc = 1
prohybrid(acc); row ++;
A (row, 1) = totaltime;
A (row, 2) = downtime;
A (row, 3) = totaldata

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     plotting
% precopy
% postcopy
% hybrid
% pro-hybrid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%prefix = "M4G_R14W14_acc100_r1"
%prefix = strcat ("M4G_R", readrate, "W", dirtyrate, "acc", acc, "r", run)
%prefix = strcat (prefix, "W")
%prefix = strcat (prefix, dirtyrate)

% write the matrix to file with delimiter white space
dlmwrite (prefix, A, ' ')

%x = ['PRECOPY', 'POSTCOPY', 'HYBRID', 'PRO-HYBRID'];
%x = {'PRE', 'POST', 'HYBR', 'PROH100', 'PROH75', 'PROH50', 'PROH25', 'PROH0'};
%x = {'PR', 'PO', 'HB', '100', '75', '50', '25', '0'};
x = {'PR', 'PO', 'HB', '0', '25', '50', '75', '100'};
%x = {'PO', 'HB', '0', '25', '50', '75', '100'};
%x = {'1', '2', '3', '4', '5', '6', '7', '8'};
xinterval = 2
xintervals = 1:xinterval:(xinterval*length(x));
%xintervals = 1:3:3*length(x);
%xintervals = 1:4:4*length(x);

%%%%%%%%%%%%%%%%%%%% downtime %%%%%%%%%%%%%%%%%%%%%%
figure;
output = strcat(prefix, ".dt");

ylim1 = [0 0.0015];
ylim2 = [64 66];

%cla;
clf;
p0 = get (gca, 'position');
delete(gcf);

%cla;

%a1 = axes ('position', [p0(1) p0(2) p0(3) p0(4)/2]);
a1 = axes ('position', [p0(1) p0(2) p0(3) p0(4)*2/3]);

bar(xintervals, A(:,2))
%set(gca, 'XTick', xintervals, 'XTickLabel', x, 'FontSize', fontsize)
set(a1, 'XTick', xintervals, 'XTickLabel', x, 'FontSize', fontsize)
set (a1, 'ylim', ylim1);
%set(a1, 'xtick', []);
xlabel('COPY METHOD', 'FontSize', fontsize);
%ylabel('DOWNTIME (SEC)', 'FontSize', fontsize);

a2 = axes ('position', [p0(1) p0(4)*2/3+.15 p0(3) p0(4)/3]);
bar(xintervals, A(:,2))
set(a2, 'ylim', ylim2, 'FontSize', fontsize);
set(a2, 'xtick', []);
ylabel('DOWNTIME (SEC)', 'FontSize', fontsize);

saveas (1, strcat(output, ".png"));
saveas (1, strcat(output, ".eps"));
saveas (1, strcat(output, ".emf"));

%%%%%%%%%%%%%%%%%%%% total time %%%%%%%%%%%%%%%%%%%%%%
clf;
delete(gcf);

figure;
output = strcat(prefix, ".tt");
%output = prefix
%plot(x, A(:,2)/1000000, x, A(:,3)/1000000, '-.*');
%plot(A(:,2));

%xtics = 1:4:16
%bar(xtics, A(:,1))
%bar(A(:,1), XTicksLabelStyle = Diagonal)
bar(xintervals, A(:,1))
%bar(A(:,1))
%set(gca, 'XTick', 1:4:32, 'XTickLabel', x, 'FontSize', fontsize)
set(gca, 'XTick', xintervals, 'XTickLabel', x, 'FontSize', fontsize)
%set(gca, 'XTickLabel', x, 'FontSize', fontsize)
xlabel('COPY METHOD', 'FontSize', fontsize);
ylabel('TOTAL TIME (SEC)', 'FontSize', fontsize);
%legend('PRECOPY', 'POSTCOPY', 'HYBRID', 'PRO-HYBRID');
%bar(x, A(:,1))

saveas (1, strcat(output, ".png"));
saveas (1, strcat(output, ".eps"));
saveas (1, strcat(output, ".emf"));

%%%%%%%%%%%%%%%%%%%% total data %%%%%%%%%%%%%%%%%%%%%%
clf;
figure;
output = strcat(prefix, ".td");

%bar(A(:,3))
bar(xintervals, A(:,3))
%set(gca, 'XTick', 1:8, 'XTickLabel', x, 'FontSize', fontsize)
set(gca, 'XTick', xintervals, 'XTickLabel', x, 'FontSize', fontsize)
xlabel('COPY METHOD', 'FontSize', fontsize);
ylabel('TOTAL DATA (KB)', 'FontSize', fontsize);

saveas (1, strcat(output, ".png"));
saveas (1, strcat(output, ".eps"));
saveas (1, strcat(output, ".emf"));


