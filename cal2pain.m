load match_num.txt
track = double(ncread('./eddy_trajectory_19930101_20170106.nc','track'));
n = double(ncread('./eddy_trajectory_19930101_20170106.nc','observation_number'));
j1 = double(ncread('./eddy_trajectory_19930101_20170106.nc','time'));   % days since 1950-01-01 00:00:00 UTC
cyc = double(ncread('./eddy_trajectory_19930101_20170106.nc','cyclonic_type'));
lon_eddy = double(ncread('./eddy_trajectory_19930101_20170106.nc','longitude'));
lat_eddy = double(ncread('./eddy_trajectory_19930101_20170106.nc','latitude'));
A = double(ncread('./eddy_trajectory_19930101_20170106.nc','amplitude'));  % cm
R = double(ncread('./eddy_trajectory_19930101_20170106.nc','speed_radius'));% km
U = double(ncread('./eddy_trajectory_19930101_20170106.nc','speed_average'));% cm/s
j0 = juliandate([1950,1,1]);

[year,month,day]=JDToDate(j1(index_use2(i))+j0);


it_two = find(match_num>-1);
per_two = length(it_two)/length(match_num)

lat_center = [-89:2:89];
lon_center = [1:2:360];
box_num = [];
for i = 1:90
    for j = 1:180
        it_box = find(match_num>-1 & lat_eddy>=lat_center(i)-1 & lat_eddy<lat_center(i)+1 ...
                                   & lon_eddy>=lon_center(j)-1 & lon_eddy<lon_center(j)+1);
        box_num(j,i) = length(it_box);
    end
end
box_num(box_num==0)=nan;

[ELEV,LONG,LAT]=m_elev([0 359.5 -85 85]);
[xx, yy] = meshgrid(lon_center,lat_center);
elev1 = griddata(LONG,LAT,ELEV,xx,yy);

figure
m_proj('robinson','lon',[0 360],'lat',[-80 80]);
[cs2, h2] = m_contourf(lon_center,lat_center,box_num',[0:1000:3000,3000:500:6500],'linestyle','none');
hold on
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('tickdir','out','linewi',2);
colormap(m_colmap('jet','step',10));
ax=m_contfbar([.3 .7],.05,cs2, h2);
set(ax,'fontsize',12);
[cs1,h1]= m_contour(xx,yy,elev1,[-3000:1000:-2000],'color','w','linewidth',0.8);
print('-dpng','-r800','doubleddy_globalmap')



[a,b] = unique(match_num);
match_eddynum = zeros(length(a),1);

fid2=fopen('unique.txt','w');
for j=1:length(a)
    fprintf(fid2,'%10d ',a(j));
    fprintf(fid2,'\n');
end
fclose(fid2);


%% 配对加速效果
track = track+1;
n=n+1;
[ntrack, idx ]= unique(track,'stable');
track_length = idx(2:end)-idx(1:end-1);
track_length(length(idx))=length(track)-idx(end)+1;
lat_first = lat_eddy(idx);
it_south = find(lat_first<-45);

match_color = {'r','b','g'};% AC,AA,CC
for i = 1:1000:length(it_south)
    track_length(it_south(i));
    it_pos = find(track == ntrack(it_south(i)));
    a_use = A(track == ntrack(it_south(i)));
    v_use = U(track == ntrack(it_south(i)));
    r_use = R(track == ntrack(it_south(i)));
    match_use = match_num(track == ntrack(it_south(i)));
    it_match = find(match_use>-1);
    if length(it_match)>3
        xx = [1:length(match_use)]';
        figure
        subplot(3,1,1)
        plot(xx,v_use,'k-','linewidth',1.2)
        hold on
        for j = 1:length(it_match)
            match_eddy_cache = find(match_num==match_use(it_match(j)));
            cyc_cache = cyc(match_eddy_cache);
            if it_match(j) < max(xx)
                if sum(cyc_cache)==0 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[v_use(it_match(j)),v_use(it_match(j)+1)],'-','linewidth',1.5,'color','r')
                elseif sum(cyc_cache)==2 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[v_use(it_match(j)),v_use(it_match(j)+1)],'-','linewidth',1.5,'color','b')
                elseif sum(cyc_cache)==-2 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[v_use(it_match(j)),v_use(it_match(j)+1)],'-','linewidth',1.5,'color','g')
                else
                    plot([it_match(j),it_match(j)+1],[v_use(it_match(j)),v_use(it_match(j)+1)],'-','linewidth',1.5,'color','m')                    
                end
            else
                if sum(cyc_cache)==0 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[v_use(it_match(j)-1),v_use(it_match(j))],'-','linewidth',1.5,'color','r')
                elseif sum(cyc_cache)==2 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[v_use(it_match(j)-1),v_use(it_match(j))],'-','linewidth',1.5,'color','b')
                elseif sum(cyc_cache)==-2 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[v_use(it_match(j)-1),v_use(it_match(j))],'-','linewidth',1.5,'color','g')
                else
                    plot([it_match(j)-1,it_match(j)],[v_use(it_match(j)-1),v_use(it_match(j))],'-','linewidth',1.5,'color','m')
                end
            end
        end
        xlim([1,max(xx)]);ylabel('Vel');
        
        subplot(3,1,2)
        plot(xx,a_use,'k-','linewidth',1.2)
        hold on
        for j = 1:length(it_match)
            match_eddy_cache = find(match_num==match_use(it_match(j)));
            cyc_cache = cyc(match_eddy_cache);
            if it_match(j) < max(xx)
                if sum(cyc_cache)==0 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[a_use(it_match(j)),a_use(it_match(j)+1)],'-','linewidth',1.5,'color','r')
                elseif sum(cyc_cache)==2 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[a_use(it_match(j)),a_use(it_match(j)+1)],'-','linewidth',1.5,'color','b')
                elseif sum(cyc_cache)==-2 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[a_use(it_match(j)),a_use(it_match(j)+1)],'-','linewidth',1.5,'color','g')
                else
                    plot([it_match(j),it_match(j)+1],[a_use(it_match(j)),a_use(it_match(j)+1)],'-','linewidth',1.5,'color','m')                    
                end
            else
                if sum(cyc_cache)==0 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[a_use(it_match(j)-1),a_use(it_match(j))],'-','linewidth',1.5,'color','r')
                elseif sum(cyc_cache)==2 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[a_use(it_match(j)-1),a_use(it_match(j))],'-','linewidth',1.5,'color','b')
                elseif sum(cyc_cache)==-2 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[a_use(it_match(j)-1),a_use(it_match(j))],'-','linewidth',1.5,'color','g')
                else
                    plot([it_match(j)-1,it_match(j)],[a_use(it_match(j)-1),a_use(it_match(j))],'-','linewidth',1.5,'color','m')
                end
            end
        end
        xlim([1,max(xx)]);ylabel('Amp');
        
        subplot(3,1,3)
        plot(xx,r_use,'k-','linewidth',1.2)
        hold on
        for j = 1:length(it_match)
            match_eddy_cache = find(match_num==match_use(it_match(j)));
            cyc_cache = cyc(match_eddy_cache);
            if it_match(j) < max(xx)
                if sum(cyc_cache)==0 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[r_use(it_match(j)),r_use(it_match(j)+1)],'-','linewidth',1.5,'color','r')
                elseif sum(cyc_cache)==2 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[r_use(it_match(j)),r_use(it_match(j)+1)],'-','linewidth',1.5,'color','b')
                elseif sum(cyc_cache)==-2 & length(cyc_cache)==2
                    plot([it_match(j),it_match(j)+1],[r_use(it_match(j)),r_use(it_match(j)+1)],'-','linewidth',1.5,'color','g')
                else
                    plot([it_match(j),it_match(j)+1],[r_use(it_match(j)),r_use(it_match(j)+1)],'-','linewidth',1.5,'color','m')                    
                end
            else
                if sum(cyc_cache)==0 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[r_use(it_match(j)-1),r_use(it_match(j))],'-','linewidth',1.5,'color','r')
                elseif sum(cyc_cache)==2 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[r_use(it_match(j)-1),r_use(it_match(j))],'-','linewidth',1.5,'color','b')
                elseif sum(cyc_cache)==-2 & length(cyc_cache)==2
                    plot([it_match(j)-1,it_match(j)],[r_use(it_match(j)-1),r_use(it_match(j))],'-','linewidth',1.5,'color','g')
                else
                    plot([it_match(j)-1,it_match(j)],[r_use(it_match(j)-1),r_use(it_match(j))],'-','linewidth',1.5,'color','m')
                end
            end
        end
        xlim([1,max(xx)]);ylabel('Radius');
        print('-dpng','-r600',['D:\twoeddymatch\pics\eddy_proper_',num2str(ntrack(it_south(i)))])
        close
    end
end




