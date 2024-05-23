% 从Excel文件读取数据
filename = '数据.xlsx';
data = xlsread(filename);

% 提取x、y、z坐标
x = double(data(1, :)');
y = double(data(2, :)');
z = double(data(3, :)');

% 使用Delaunay三角剖分来生成三角形网格
DT = delaunayTriangulation(x, y);

% 定义插值点的范围和步长，并创建网格
x1 = 87:0.1:128;
y1 = 20:0.1:46;
[X1, Y1] = meshgrid(x1, y1);

% 根据插值点计算Z1
Z1 = zeros(size(X1));

for i = 1:size(X1, 1)
    for j = 1:size(X1, 2)
        % 获取包含当前插值点的三角形索引
        t_index = pointLocation(DT, X1(i, j), Y1(i, j));
        
        if ~isnan(t_index)
            % 获取当前三角形的顶点
            tri_vertices = DT.Points(DT.ConnectivityList(t_index, :), :);
            
            % 计算重心坐标系下的插值点坐标
            lambda = cartesianToBarycentric(DT, t_index, [X1(i, j), Y1(i, j)]);
            
            % 根据重心坐标系计算插值后的Z1值
            Z1(i, j) = sum(lambda' .* z(DT.ConnectivityList(t_index, :)));
        else
            Z1(i, j) = NaN;
        end
    end
end

% 将NaN值替换为零
Z1(isnan(Z1)) = 0;

% 检查Z1的最小和最大值是否相同，如果相同，则添加微小变化
if min(Z1(:)) == max(Z1(:))
    Z1 = Z1 + rand(size(Z1)) * 1e-6;
end

% 绘制等高线图
meshc(X1, Y1, Z1);
title('linear');
