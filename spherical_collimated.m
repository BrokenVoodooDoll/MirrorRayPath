clc
clear

radius = 100; % curvature radius of the mirror in mm
angle_deg = 0; % angle of incidence of the incident beam in degrees
rays = 21; % number of rays

focal_length = radius / 2; % focal length of the mirror
a = 1.1 * focal_length;  % mirror field
inc_ang = -angle_deg * pi / 180;
if angle_deg < 0.000001
  inc_ang = 0.000001 * pi / 180;  % incident ray angle in radians
end
var = -a:0.1:a;

% mirror equation
function s = surface(y, r)
    s = sqrt(r ^ 2 - y .^ 2) - r;
end

% reflection angle
function angle = refl_ang(y, inc_ang, r)
    angle = inc_ang - 2 * asin((-y / tan(inc_ang) - surface(y, r)) / r * sin(inc_ang));
end

% incident ray vector (y_start, y_end)
% x_vec is vector (x_start, x_end)
function v = inc_vec(y, inc_ang, x_vec, r)
    v = tan(-inc_ang) * (x_vec - surface(y, r)) + y;
end

% reflected ray vector (y_start, y_end)
% x_vec is vector (x_start, x_end)
function v = refl_vec(y, inc_ang, x_vec, r)
    sigma =  refl_ang(y, inc_ang, r);
    v = tan(sigma) .* (x_vec - surface(y, r) + y ./ tan(sigma));
end

figure
hold on
plot(surface(var, radius), var) % mirror surface visualization
plot([-2 * radius 0], [0 0]) % axis of the mirror
plot([-focal_length], [0], 'o') % focal point

y = linspace(-focal_length, focal_length, rays);
for i = 1:length(y)
    x_vec = [-radius surface(y(i), radius)];
    plot(x_vec, inc_vec(y(i), inc_ang, x_vec, radius), 'k')
    
    r = refl_ang(y(i), inc_ang, radius);
    if (r < pi / 2 & r > -pi / 2)
        plot(x_vec, refl_vec(y(i), inc_ang, x_vec, radius), 'r')
    else
        x_vec_out = [surface(y(i)) 0];
        plot(x_vec_out, refl_vec(y(i), inc_ang, x_vec_out, radius), 'r')
    end
end

title(sprintf("Radius = %.1f mm. Focal length = %.1f mm.\nIncident angle = %.1f{\\deg}. Number of rays = %d", radius, focal_length, angle_deg, rays))
xlabel("z, mm")
ylabel("r, mm")
ylim([-a a])
xlim([-radius 0])
grid