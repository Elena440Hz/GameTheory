
% Parameters
p = 3/5; % Parameter value 
T = 10;   
M = 4;   
x_range = [0, 1]; % Range for x-axis
y_range = [0, 1]; % Range for y-axis
grid_density = 50; % Number of arrows in each direction

% Payoff Matrix (apo to paper)
C = [T*M, 3*(1-p)*T, T*M;
     3*p*T, T, 3*p + T - 1;
     T*M, 3*(1-p)+(T-1), T*M];

% Define the replicator dynamics equations (indos sto youtube)
f_1 = @(x,y) C(1,1)*x + C(1,2)*y + C(1,3)*(1 - x - y);
f_2 = @(x,y) C(2,1)*x + C(2,2)*y + C(2,3)*(1 - x - y);
f_3 = @(x,y) C(3,1)*x + C(3,2)*y + C(3,3)*(1 - x - y);

phi = @(x, y) x*f_1(x, y) + y*f_2(x, y) + (1-x-y)*f_3(x, y); % ypologizo to xTCx

dx_dt = @(x, y) x * (f_1(x, y) - phi(x, y)); %synarthsh (5.1) sto paper
dy_dt = @(x, y) y * (f_2(x, y) - phi(x, y));

replicator = @(t, xy) [dx_dt(xy(1), xy(2)); dy_dt(xy(1), xy(2))]; %(indos sto youtube)

% Create a grid of points for the vector field
[x, y] = meshgrid(linspace(x_range(1), x_range(2), grid_density), ...
                   linspace(y_range(1), y_range(2), grid_density));

% Evaluate the derivatives at each point
u = zeros(size(x));
v = zeros(size(y));

for i = 1:numel(x)
    xy_dot = replicator(0, [x(i), y(i)]);
    u(i) = xy_dot(1);
    v(i) = xy_dot(2);
end

% Normalize the vectors to have unit lenght
magnitude = sqrt(u.^2 + v.^2);
u = u ./ magnitude;
v = v ./ magnitude;

% Plot the vector field
figure;
quiver(x, y, u, v, 'r'); % 'r' for red 
hold on;

% Plot the line x + y = 1
x_line = linspace(x_range(1), x_range(2), 100);
y_line = 1 - x_line;
plot(x_line, y_line, 'k-', 'LineWidth', 1.5); % 'k-' for black line

% Set axis limits and labels
xlim(x_range);
ylim(y_range);
xlabel('x_1');
ylabel('x_2');
title(['Phase Portrait of Replicator Dynamics (Payoff Matrix C, p=1/2)']);
axis equal; % Make sure x and y axes have the same scale
hold off;