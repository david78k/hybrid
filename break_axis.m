a=[1 3 6 4 5 300];

ylim1=[0 20];
ylim2=[100 300];
xlim=[0 length(a)+1];

figure;

% retrieve your default axis pos
clf;
p0=get(gca,'position')
delete(gcf);

% create axis1
%a1=axes('position',[p0(1) p0(2) p0(3)/2-.025 p0(4)]);
a1=axes('position',[p0(1) p0(2) p0(3) p0(4)/2]);
%a2=axes('position',[p0(1) p0(4)/2+.145 p0(3) p0(4)/2])
%barh(a);
bar(a);
set(a1,'ylim',ylim1);
%set(a2,'xlim',xlim,'ylim',ylim2);
%set(a2,'xtick',[]);
%box off;

% create axis2
%a2=axes('position',[p0(1)+p0(3)/2+.025 p0(2) p0(3)/2-.025 p0(4)]);
%a2=axes('position',[p0(1) p0(4)/2+.145 p0(3) p0(4)/2])
a2=axes('position',[p0(1) p0(4)/2+.145 p0(3) p0(4)/3])
%a2=axes('position',[p0(1) p0(4)/2+.145 p0(3) p0(4)/2])
%a2=axes('position',[p0(1) p0(2) p0(3) p0(4)/2]);
%barh(a);
bar(a);

%set(a2,'ylim',ylim1);
%set(a2,'ylim',ylim2);
set(a2,'xlim',xlim,'ylim',ylim2);
set(a2,'xtick',[]);
%set(a2,'xcolor',get(a2,'color'));
%box off

%%%%%%%%%%%%%%%% plotting %%%%%%%%%%%%%%%%%%%%%
output = "break_axis";

%figure;
saveas(1, strcat(output, ".png"));

%box off
