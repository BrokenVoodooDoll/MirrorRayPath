clc
clear

focal_length = 100; % focal length in mm
angle_d = 25; % maximum angle of incidence of the incident beam in degrees
num_rays = 21; % number of rays
source_pos = 400; % source position in mm (must be positive)
% there is a bug when source_pos = focal_length because of very small
% angles of reflectance.
% Instead, better to choose source_pos = focal_length + 0.01 or something like
% this

p = 2 * focal_length; % parameter of the parabola equation y**2 = 2*p*z
y = linspace(-p, p, 1000);

% mirror equation z = -y^2 / (2 * p)
function s = surface(y, p)
    s = -y .^ 2 / (2 * p);
end

function angle = phi(y, p)
    angle = atan(y / p);
end

% angle between the incident ray and the line connecting the point of incidence
% of the ray on the mirror and the center of curvature of the mirror
function angle = epsilon(y, inc_angle, p)
    angle = inc_angle - phi(y, p);
end

% angle of reflected ray
function angle = ref_angle(y, inc_angle, p)
    angle = phi(y, p) - epsilon(y, inc_angle, p);
end

% the z-coordinate of the intersection of the reflected ray with the axis
function z = ref_z(y, inc_angle, p, s)
    if inc_angle == 0
        z = 0;
        return
    end
    tg_sigma = tan(inc_angle);
    z_0 = -(y - s * tg_sigma) / tg_sigma;
    z = y ./ tan(ref_angle(y, inc_angle, p)) + z_0;
end

% the y-coordinate of the intersection of the incident ray with the mirror 
function h = height(inc_angle, p, s)
    if inc_angle == 0
        h = 0;
        return
    end
    tg_sigma = tan(inc_angle);
    h = -p / tg_sigma * (1 - sqrt(1 + 2 * s / p * tg_sigma ^ 2));
end

% line equation for extension of the reflected ray
function l = line(ref_angle, z, z0)
    l = tan(ref_angle) * (z - z0);
end

figure
hold on
plot(surface(y, p), y) % mirror surface visualization
plot([-2 * p 0], [0 0]) % axis of the mirror
plot([-focal_length], [0], 'o') % focal point

angles = linspace(-angle_d, angle_d, num_rays);
for i  = 1:length(angles)
    inc_angle = angles(i) * pi / 180;
    h = height(inc_angle, p, source_pos);

    z_inc = [-source_pos surface(h, p)];
    y_inc = [0 h];
    plot(z_inc, y_inc, 'k') % draw incident beam

    z_0 = ref_z(h, inc_angle, p, source_pos);
    if isnan(z_0)
        z_0 = -2 * p;
    end

    if source_pos >= focal_length
        if z_0 > 0
          z_0 = -z_0;
        end
    else
        if z_0 < 0
          z_0 = -z_0;
        end
    end
    
    z_ref = [surface(h, p) -2 * p];
    y_ref = [h line(ref_angle(h, inc_angle, p), -2 * p, z_0)];
    plot(z_ref, y_ref, 'r')
end

title(sprintf("Focal length = %.1f mm. Source position = %.1f mm.\nMaximum incident angle = %.1f{\\deg}. Number of rays = %d", focal_length, -source_pos, angle_d, num_rays))
xlabel("z, mm")
ylabel("y, mm")
ylim([-p p])
xlim([-2 * p 0])
grid on