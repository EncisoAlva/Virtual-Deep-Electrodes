%% open brainstorm
%
%addpath 'D:\brainstorm3'
%brainstorm



%%
% PARAMETERS

%cortex_conn = xport.Faces;
%cortex_vert = xport.Vertices;

dev = true;
vis_width = 0.001;
vis_tol = vis_width/20;
max_iter = 100;

% strip of AxB electrodes is --for now-- assumed parallel to medial line
% AxB means each B electrode line is perpendicular
ElecGridNum = [1,4];
ElecGridSep = [1,0.01];
ElectRefStart = [0.01,0.01];
ElectSide = 'left';

if(dev)
    % DELETE
    figure()
    trisurf(cortex_conn, cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),...
        'FaceColor',[.85 .85 .85])
    title('Only Cortex Surface')
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
    % Delete
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
end
if dev
    vis_idx = vecnorm( cortex_vert(:,[1,3])-[AntEdge_x,AntEdge_z], 2, 2 ) < 2*vis_width;
    figure()
    trisurf(cortex_conn, cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),...
        'FaceColor',[.85 .85 .85])
    %scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
    xlabel('x')
    ylabel('y')
    zlabel('z')
    title('Cortex Surface')
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
    % DELETE
    figure()
    trisurf(cortex_conn, cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),...
        'FaceColor',[.85 .85 .85])
    %scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
    xlabel('x')
    ylabel('y')
    zlabel('y')
    hold on
    scatter3(med_line(:,1),med_line(:,2),med_line(:,3),'filled')
    scatter3(cortex_vert(vis_idx,1),cortex_vert(vis_idx,2),cortex_vert(vis_idx,3),'r','filled')
end

x_0 = min( med_line(:,1) );
x_f = max( med_line(:,1) );
x_lo = x_0:0.0001:x_f; 
y_lo = x_lo*0 + 0;
model = fit( med_line(:,[1,2]), med_line(:,3), 'lowess' );
z_up = feval( model, [x_lo',y_lo'] );

MLcurve = [x_lo', y_lo', z_up]; % medial line, stilyzed curve
guides_idx = MLcurve;

% 2.
lin_int = zeros( 1, size(x_lo,2) );
for ii = 2:size(x_lo,2)
    lin_int(ii) = lin_int(ii-1) + norm( MLcurve(ii,:)-MLcurve(ii-1,:) );
end
lin_int = lin_int(end) - lin_int;

ctr_mark = zeros( ElecGridNum(2) ,3 );
cursor = ElectRefStart(2);
for iter = 1:ElecGridNum(2)
    [~,idx] = min(abs( lin_int-cursor ));
    ctr_mark(iter,:) = MLcurve(idx,:);
    cursor = cursor + ElecGridSep(2);
end

%%%

ElectrodeCoords = zeros( ElecGridNum(1)*ElecGridNum(2), 3 );
ElectrodePositions = zeros( ElecGridNum(1)*ElecGridNum(2), 2 );
lazy_counter = 1;
pos = [1,1];

for iter2 = 1:ElecGridNum(2)
    % 3.
    aux_line = cortex_vert( abs(cortex_vert(:,1)-ctr_mark(iter2,1))<vis_width, :);
    aux_line = aux_line( aux_line(:,3)>AntEdge_z, :); % only upper part is relevant
    
    if strcmp( ElectSide, 'left' )
        y_0 = ctr_mark(iter2,2);
        y_f = max( aux_line(:,2) );
    else
        y_0 = min( aux_line(:,2) );
        y_f = ctr_mark(iter2,2);
    end
    y_lo = y_0:0.0001:y_f; 
    x_lo = y_lo*0 + ctr_mark(iter2,1);
    model = fit( aux_line(:,[1,2]), aux_line(:,3), 'lowess' );
    z_up = feval( model, [x_lo',y_lo'] );

    MLcurve = [x_lo', y_lo', z_up]; % medial line, stilyzed curve
    guides_idx = [guides_idx; MLcurve];

    % 4.
    lin_int = zeros( 1, size(x_lo,2) );
    for ii = 2:size(x_lo,2)
        lin_int(ii) = lin_int(ii-1) + norm( MLcurve(ii,:)-MLcurve(ii-1,:) );
    end
    %lin_int = lin_int(end) - lin_int;

    cursor = ElectRefStart(1);
    pos(2) = 1;
    for iter = 1:ElecGridNum(1)
        [~,idx] = min(abs( lin_int-cursor ));
        ElectrodeCoords(lazy_counter,:) = MLcurve(idx,:);
        ElectrodePositions(lazy_counter,:) = pos;
        cursor = cursor + ElecGridSep(1);
        lazy_counter = lazy_counter+1;
        pos(2) = pos(2)+1;
    end
    pos(1) = pos(1)+1;
end

if(dev)
    figure()
    trisurf(cortex_conn, cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),...
        'FaceColor',[.85 .85 .85],'FaceAlpha',.3)
    %scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
    xlabel('x')
    ylabel('y')
    zlabel('y')
    title('Cortex surface')
    hold on
    %scatter3(ctr_mark(:,1),ctr_mark(:,2),ctr_mark(:,3),200,'filled')
    scatter3(guides_idx(:,1),guides_idx(:,2),guides_idx(:,3),'filled')
    scatter3(ElectrodeCoords(:,1),ElectrodeCoords(:,2),ElectrodeCoords(:,3),200,'filled')
    scatter3(cortex_vert(vis_idx,1),cortex_vert(vis_idx,2),cortex_vert(vis_idx,3),'r','filled')
    legend('','Reference lines','Electrodes','Anterior Edge')
end

%%
% labels

writematrix(ElectrodeCoords)

%% 
% creation of an example
% this select the upper part of the pial

% xport = xport_pre;
% 
% N = size(xport.Vertices,1);
% idx = xport.Vertices(:,3)>0.01;
% 
% xport.Vertices = xport.Vertices(idx,:);
% xport.VertConn = xport.VertConn(idx,idx);
% xport.VertNormals = xport.VertNormals(idx,:);
% xport.Curvature = xport.Curvature(idx,:);
% xport.SulciMap = xport.SulciMap(idx,:);
% 
% idx_rev = zeros(N,1 );
% counter = 1;
% for i = 1:N
%     if idx(i)
%         idx_rev(i) = counter;
%         counter = counter+1;
%     end
% end
% for i = 1:size(xport.Faces,1)
%     xport.Faces(i,1) = idx_rev( xport.Faces(i,1) );
%     xport.Faces(i,2) = idx_rev( xport.Faces(i,2) );
%     xport.Faces(i,3) = idx_rev( xport.Faces(i,3) );
% end
% 
% idx_fac = (xport.Faces(:,1)==0);
% for i = 1:size(idx_fac)
%     if (xport.Faces(i,1)~=0) && (xport.Faces(i,2)~=0) && (xport.Faces(i,3)~=0)
%         idx_fac(i) = true;
%     else
%         idx_fac(i) = false;
%     end
% end
% xport.Faces = xport.Faces(idx_fac,:);
% 
% 
% 
% 
% 
% 
% save('xport.mat','xport')
% 
% cortex_vert = xport.Vertices;
% cortex_conn = xport.Faces;
% if(dev)
%     % DELETE
%     figure()
%     trisurf(cortex_conn, cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3))
%     scatter3(cortex_vert(:,1),cortex_vert(:,2),cortex_vert(:,3),'filled')
%     title('Only cortex surface (mesh vertices)')
%     xlabel('x')
%     ylabel('y')
%     zlabel('z')
% end