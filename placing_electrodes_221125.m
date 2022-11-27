%% open brainstorm
%
%addpath 'D:\brainstorm3'
%brainstorm

%%
% PARAMETERS

%cortex_vert = piall;
%cortex_vert = cortex_vert(cortex_vert(:,3)>0.01,:);

dev = true;
vis_width = 0.001;
vis_tol = vis_width/20;
max_iter = 100;

% strip of AxB electrodes is --for now-- assumed parallel to medial line
% AxB means each B electrode line is perpendicular
ElecGridNum = [1,4];
ElecGridSep = [1,0.01];
ElectRefStart = [0.01,0.01];


if(dev)
    figure()
    scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
    title('Only cortex surface (mesh vertices)')
    xlabel('x')
    ylabel('y')
    zlabel('z')
end

%%
% IDENTIFICATION OF ANTERIOR EDGE

% finding anterior terminal
% 1. find max
% 2. select pts close to the max
% 3. find quasi-max (~100th percentile)
% 4. repeat 2,3 until convergence
[M,~] = max( cortex_vert(:,1) );
old_M = M+vis_tol*2;
iter = 0;
%M_col = [M];
while ( abs(M-old_M) >= vis_tol ) && ( iter < max_iter )
    strip_idx = abs( cortex_vert(:,1)-M ) < vis_width;
    old_M = M;
    M = quantile(cortex_vert(strip_idx,1), 0.98);
    %M_col = [M_col, M];
    iter = iter +1;
end
if dev
    % DELETE LATER
    figure()
    scatter(cortex_vert(:,1),cortex_vert(:,3),'filled')
    xlabel('x')
    ylabel('z')
    title('Only cortex surface (mesh vertices)')
    subtitle('Sagittal view')
    hold on 
    xline(M,'-','Anterior border','LineWidth',1)
end

% finding the anterior edge
% 1. find most superior point in anterior terminal
% 2. use the xz coordinates as anterior edge
strip_idx = abs( cortex_vert(:,1)-M ) < vis_width;
tmp_vec = cortex_vert(strip_idx,:);
m = quantile( tmp_vec(:,3)-abs(tmp_vec(:,1)-M), 0.98 );
[~,m_idx] = min( abs(tmp_vec(:,1)-M)+abs(tmp_vec(:,3)-m) );
AntEdge_x = tmp_vec(m_idx,1);
AntEdge_z = tmp_vec(m_idx,3);
if dev
    figure()
    scatter(cortex_vert(:,1),cortex_vert(:,3),'filled')
    xlabel('x')
    ylabel('z')
    title('Cortex Surface (Mesh Vertices)')
    subtitle('Sagittal View')
    hold on 
    scatter(AntEdge_x,AntEdge_z,200,'k','filled')
    xline(M,'--','LineWidth',1)
    legend('','Anterior Edge','Anterior Extreme')

    vis_idx = vecnorm( cortex_vert(:,[1,3])-[AntEdge_x,AntEdge_z], 2, 2 ) < 2*vis_width;
    figure()
    scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
    xlabel('x')
    ylabel('y')
    zlabel('z')
    title('Cortex Surface (Mesh Vertices)')
    hold on 
    scatter3(cortex_vert(vis_idx,1),cortex_vert(vis_idx,2),cortex_vert(vis_idx,3),'r','filled')
    legend('','Anterior Edge')
end

%%

% draw the AxB grid electrodes algorithmicalli
% 1. draw medial line, for reference
% 2. mark B regular dots in medial line
% 3. draw lines parallel to medial line
% 4. mark A regular dots on each one
% 5. TODO correction for robustness

% 1.
med_line = cortex_vert( abs(cortex_vert(:,2))<vis_width, :);
med_line = med_line( med_line(:,3)>AntEdge_z, :); % only upper part is relevant
if dev
    figure()
    scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
    xlabel('x')
    ylabel('y')
    zlabel('y')
    hold on
    scatter3(med_line(:,1),med_line(:,2),med_line(:,3),'filled')
end

x_0 = min( med_line(:,1) );
x_f = max( med_line(:,1) );
x_lo = x_0:0.0005:x_f; 
y_lo = x_lo*0 + 0;
model = fit( [x_lo', y_lo'], med_line(:,3), 'lowess' );
z_up = feval( model, XY_lo );

MLcurve = [x_lo', y_lo', z_up]; % medial line, stilyzed curve

% 2.
lin_int = zeros( 1, size(x_lo,2) );
for ii = 2:size(x_lo,2)
    lin_int(ii) = lin_int(ii-1) + norm( MLcurve(ii,[1,3])-MLcurve(ii-1,[1,3]) );
end
lin_int = lin_int(end) - lin_int;

ctr_mark = zeros( ElecGridNum(2) ,3 );
cursor = ElectRefStart(2);
idx_col = [];
for iter = 1:ElecGridNum(2)
    [~,idx] = min(abs( lin_int-cursor ));
    ctr_mark(iter,:) = MLcurve(idx,:);
    cursor = cursor + ElecGridSep(2);
    idx_col = [idx_col, idx];
end

if(dev)
    figure()
    plot( MLcurve(:,1) -MLcurve(1,1), lin_int(1) -lin_int )
    xlabel('Distance on x')
    ylabel('Distance on Cortex')
    title('Cumulative from Anterior Edge')
    hold on
    plot( MLcurve(idx_col,1) -MLcurve(1,1), lin_int(1) -lin_int(idx_col), 'o')
    legend('','Marks on Medial Line')

    figure()
    scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
    xlabel('x')
    ylabel('y')
    zlabel('y')
    hold on
    scatter3(ctr_mark(:,1),ctr_mark(:,2),ctr_mark(:,3),200,'filled')
end

%
















%%
% step 1
% LEFT

strip = cortex_vert( abs(cortex_vert(:,2)-0.01)<0.001,: );
strip = strip( strip(:,3)>= ccort(j,3), : );
figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(ccort(j,1),ccort(j,2),ccort(j,3),200,'k','filled')

figure()
scatter(cortex_vert(:,1),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('3')
hold on
scatter(strip(:,1),strip(:,3),'filled')
scatter(ccort(j,1),ccort(j,3),200,'k','filled')

mini = min(strip(:,1));
maxi = max(strip(:,1));

x1 = mini:0.0005:maxi;
x2 = x1*0+0.01;
X = [x1',x2'];

model = fit( strip(:,1:2), strip(:,3), 'lowess' );

figure()
plot(model, strip(:,1:2), strip(:,3))

curve = feval(model, X);

figure()
scatter(cortex_vert(:,1),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('3')
hold on
scatter(strip(:,1),strip(:,3),'filled')
scatter(X(:,1),curve,'filled')

figure()
scatter(-cortex_vert(:,1),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('3')
hold on
scatter(-strip(:,1),strip(:,3),'filled')
scatter(-X(:,1),curve,'filled')
scatter(-ccort(j,1),ccort(j,3),200,'k','filled')

figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(X(:,1),X(:,2),curve,'filled')

X = [X, curve];

lin_int = zeros(1,length(x1));
for ii = 2:length(x1)
    lin_int(ii) = lin_int(ii-1) + norm( X(ii,[1,3])-X(ii-1,[1,3]) );
end
lin_int = lin_int(length(x1)) - lin_int;

figure()
plot(lin_int)
xlabel('1')
ylabel('Line integral')

elec_pos1 = zeros(4,3);
for ii = 1:4
    w = (ii+1)/100;
    [~,jj] = min(abs( lin_int-w ));
    elec_pos1(ii,:) = X(jj,:);
end

figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(X(:,1),X(:,2),X(:,3),'filled')
scatter3(elec_pos1(:,1),elec_pos1(:,2),elec_pos1(:,3),200,'k','filled')
% LEFT

%%
% one of the strips
ii = 2.5;
w = (ii+1)/100;
[~,jj] = min(abs( lin_int-w ));
punch1 = X(jj,:);

figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(X(:,1),X(:,2),X(:,3),'filled')
scatter3(elec_pos1(:,1),elec_pos1(:,2),elec_pos1(:,3),200,'k','filled')
scatter3(punch1(1),punch1(2),punch1(3),200,'r','filled')

strip_pos1      = zeros(8,3);
strip_pos1(1,:) = punch1;
strip_pos1(1,3) = strip_pos1(1,3) - 0.001;
for ii = 2:8
    strip_pos1(ii,:) = strip_pos1(ii-1,:)- [0,0,0.005];
end
% 8 - 1
figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(X(:,1),X(:,2),X(:,3),'filled')
scatter3(elec_pos1(:,1),elec_pos1(:,2),elec_pos1(:,3),200,'k','filled')
scatter3(strip_pos1(:,1),strip_pos1(:,2),strip_pos1(:,3),200,'r','filled')

%%
% step 2
% RIGHT

strip = cortex_vert( abs(cortex_vert(:,2)+0.01)<0.001,: );
strip = strip( strip(:,3)>= ccort(j,3), : );
figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(ccort(j,1),ccort(j,2),ccort(j,3),200,'k','filled')

figure()
scatter(cortex_vert(:,1),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('3')
hold on
scatter(strip(:,1),strip(:,3),'filled')
scatter(ccort(j,1),ccort(j,3),200,'k','filled')

mini = min(strip(:,1));
maxi = max(strip(:,1));

x1 = mini:0.0005:maxi;
x2 = x1*0-0.01;
X = [x1',x2'];

model = fit( strip(:,1:2), strip(:,3), 'lowess' );

figure()
plot(model, strip(:,1:2), strip(:,3))

curve = feval(model, X);

figure()
scatter(cortex_vert(:,1),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('3')
hold on
scatter(strip(:,1),strip(:,3),'filled')
scatter(X(:,1),curve,'filled')

figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(X(:,1),X(:,2),curve,'filled')

X = [X, curve];

lin_int = zeros(1,length(x1));
for ii = 2:length(x1)
    lin_int(ii) = lin_int(ii-1) + norm( X(ii,[1,3])-X(ii-1,[1,3]) );
end
lin_int = lin_int(length(x1)) - lin_int;

figure()
plot(lin_int)
xlabel('1')
ylabel('Line integral')

elec_pos2 = zeros(4,3);
for ii = 1:4
    w = (ii+1)/100;
    [~,jj] = min(abs( lin_int-w ));
    elec_pos2(ii,:) = X(jj,:);
end

figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(X(:,1),X(:,2),X(:,3),'filled')
scatter3(elec_pos2(:,1),elec_pos2(:,2),elec_pos2(:,3),200,'k','filled')
% RIGHT

%%
% other strip
ii = 2.5;
w = (ii+1)/100;
[~,jj] = min(abs( lin_int-w ));
punch1 = X(jj,:);

figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(X(:,1),X(:,2),X(:,3),'filled')
scatter3(elec_pos2(:,1),elec_pos2(:,2),elec_pos2(:,3),200,'k','filled')
scatter3(punch1(1),punch1(2),punch1(3),200,'r','filled')

strip_pos2      = zeros(8,3);
strip_pos2(1,:) = punch1;
strip_pos2(1,3) = strip_pos2(1,3) - 0.001;
for ii = 2:8
    strip_pos2(ii,:) = strip_pos2(ii-1,:)- [0,0,0.005];
end
% 8 - 1

figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(strip(:,1),strip(:,2),strip(:,3),'filled')
scatter3(X(:,1),X(:,2),X(:,3),'filled')
scatter3(elec_pos2(:,1),elec_pos2(:,2),elec_pos2(:,3),200,'k','filled')
scatter3(strip_pos2(:,1),strip_pos2(:,2),strip_pos2(:,3),200,'r','filled')


%%
% final check

figure()
scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
xlabel('1')
ylabel('2')
zlabel('3')
hold on
scatter3(elec_pos1(:,1),elec_pos1(:,2),elec_pos1(:,3),200,'k','filled')    % L ECOG: 1-4
%scatter3(elec_pos1(1,1),elec_pos1(1,2),elec_pos1(1,3),200,'p','filled')
%scatter3(elec_pos2(1,1),elec_pos2(1,2),elec_pos2(1,3),200,'p','filled')
scatter3(elec_pos2(:,1),elec_pos2(:,2),elec_pos2(:,3),200,'g','filled')    % R ECOG: 1-4
%scatter3(elec_pos3(:,1),elec_pos3(:,2),elec_pos3(:,3),200,'k','filled')
%scatter3(elec_pos4(:,1),elec_pos4(:,2),elec_pos4(:,3),200,'k','filled')
scatter3(strip_pos1(:,1),strip_pos1(:,2),strip_pos1(:,3),200,'r','filled') % L SEEG: 8-1
scatter3(strip_pos2(:,1),strip_pos2(:,2),strip_pos2(:,3),200,'y','filled') % R SEEG: 8-1

%%
% labels
elec_pos_in = [elec_pos1; elec_pos2; strip_pos1; strip_pos2];
% L ECOG 1-4
% R ECOG 1-4
% L SEEG 8-1
% R SEEG 8-1

elec_pos_in = elec_pos_in(:,[2,1,3]);
elec_pos_in

writematrix(elec_pos_in)