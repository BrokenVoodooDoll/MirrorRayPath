clc
clear

focal_length = 100; % focal length in mm
angle_deg = 0; % angle of incidence of the incident beam in degrees
rays = 21; % number of rays

p = 2 * focal_length; % parameter of the parabola equation y**2 = 2*p*z
a = 1.1 * focal_length;  % mirror field
inc_ang = -angle_deg * pi / 180;
if angle_deg < 0.000001
  inc_ang = 0.000001 * pi / 180;  % incident ray angle in radians
end
var = -a:0.1:a;

% mirror equation z = -y^2 / (2 * p)
function s = surface(y, p)
    s = -y .^ 2 / (2 * p);
end

% reflection angle
function angle = refl_ang(y, inc_ang, p)
    angle = 2 * atan(y / p) - inc_ang;
end


% incident ray vector (y_start, y_end)
% x_vec is vector (x_start, x_end)
function v = inc_vec(y, inc_ang, x_vec, p)
    v = tan(-inc_ang) * (x_vec - surface(y, p)) + y;
end


% reflected ray vector (y_start, y_end)
% x_vec is vector (x_start, x_end)
function v = refl_vec(y, inc_ang, x_vec, p)
    sigma = refl_ang(y, inc_ang, p);
    v = tan(sigma) * (x_vec - surface(y, p) + y / tan(sigma));
end


figure
hold on
plot(surface(var, p), var) % mirror surface visualization
plot([-p 0], [0 0]) % axis of the mirror
plot([-focal_length], [0], 'o') % focal point

y = linspace(-focal_length, focal_length, rays);
for i = 1:length(y)
    x_vec = [-p surface(y(i), p)];
    
    plot(x_vec, inc_vec(y(i), inc_ang, x_vec, p), 'k')

    r = refl_ang(y, inc_ang, p);
    if (r < pi / 2 & r > -pi / 2)
        plot(x_vec, refl_vec(y(i), inc_ang, x_vec, p), 'r')
    else
        x_vec_out = [surface(y(i), p) 0];
        plot(x_vec_out, refl_vec(y(i), inc_ang, x_vec_out, p), 'r')
    end
end

title(sprintf("Focal length = %.1f mm. Incident angle = %.1f{\\deg}. Number of rays = %d", focal_length, angle_deg, rays))
xlabel("z, mm")
ylabel("r, mm")
ylim([-a a])
xlim([-p 0])
grid on