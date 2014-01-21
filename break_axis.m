a=[1 6 4 300];
x = {'', 'PRECOPY', 'POSTCOPY', 'HYBRID', 'PRO-HYBRID', ''};

fontsize = 18;

ylim1=[0 20];
%ylim2=[100 300];
%ylim2=[200 400];
ylim2=[200 320];
xlim=[0 length(a)+1];

figure;

% retrieve your default axis pos
clf;
p0=get(gca,'position')
delete(gcf);

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
set(a2,'ylim',ylim2, 'FontSize', fontsize);
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
