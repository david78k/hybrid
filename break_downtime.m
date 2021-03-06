prefix = 'break_downtime';
output = strcat(prefix, ".dt");

a=[1 6 4 300];
x = {'', 'PR', 'PO', 'HB', '0', ''};
x = {'PR', 'PO', 'HB', '0', '25', '50', '75', '100'};

fontsize = 18;

xinterval = 2
xintervals = 1:xinterval:(xinterval*length(x));

ylim1=[0 20];
%ylim2=[100 300];
%ylim2=[200 400];
ylim2=[200 350];
xlim=[0 length(a)+1];

figure;

% retrieve your default axis pos
clf;
p0=get(gca,'position')
delete(gcf);

xinterval = 2
xintervals = 1:xinterval:(xinterval*length(x));
yinterval = 2
yintervals = 1:yinterval:(yinterval*length(x));

% create axis1
%a1=axes('position',[p0(1) p0(2) p0(3)/2-.025 p0(4)]);
a1=axes('position',[p0(1) p0(2) p0(3) p0(4)/2]);
%barh(a);
bar(a);
%set(a1,'ylim',ylim1);
set(a1,'ylim',ylim1, 'XTickLabel', x, 'FontSize', fontsize);
xlabel('COPY METHOD', 'FontSize', fontsize);
%ylabel('TIME', 'FontSize', fontsize);

%box off;

% create axis2
%a2=axes('position',[p0(1)+p0(3)/2+.025 p0(2) p0(3)/2-.025 p0(4)]);
a2=axes('position',[p0(1) p0(4)/2+.145 p0(3) p0(4)/2])
%a2=axes('position',[p0(1) p0(2) p0(3) p0(4)/2]);
%barh(a);
bar(a);

%set(a2,'ylim',ylim1);
set(a2,'ylim',ylim2, 'FontSize', fontsize, 'YTick', [200:50:350]);
%ylim(ylim2);
%set(a2,'xlim',xlim,'ylim',ylim2);
set(a2,'xtick',[]);
%set(a2,'xcolor',get(a2,'color'));
ylabel('TIME (sec)', 'FontSize', fontsize);
%box off

%%%%%%%%%%%%%%%% plotting %%%%%%%%%%%%%%%%%%%%%
output = "break_axis";

%figure;
saveas(1, strcat(output, ".png"));
saveas(1, strcat(output, ".emf"));
saveas(1, strcat(output, ".eps"));

%box off
