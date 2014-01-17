a=[1 3 6 4 5 300];
xlim1=[0 20];
xlim2=[100 300];
ylim=[0 length(a)+1];

% retrieve your default axis pos
clf;
p0=get(gca,'position');
delete(gcf);

% create axis1
a1=axes('position',[p0(1) p0(2) p0(3)/2-.025 p0(4)]);
barh(a);
set(a1,'xlim',xlim1);
box off;

% create axis2
a2=axes('position',[p0(1)+p0(3)/2+.025 p0(2) p0(3)/2-.025 p0(4)]);
barh(a);
set(a2,'xlim',xlim2,'ylim',ylim);
set(a2,'ytick',[]);
%set(a2,'ycolor',get(a2,'color'));
box off
