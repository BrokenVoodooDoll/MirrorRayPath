clc
clear

radius = 100; % curvature radius of the mirror in mm (must be positive)
angle_d = 30; % maximum angle of incidence of the incident beam in degrees
num_rays = 21; % number of rays
source_pos = 80; % source position in mm (must be positive)

focal_length = radius / 2; % focal length of the mirror
y = linspace(-radius, radius, 1000);

% mirror equation z = sqrt(R^2 - y^2) - R
function s = surface(y, r)
    s = sqrt(r ^ 2 - y .^ 2) - r;
end

% angle between the incident ray and the line connecting the point of incidence
% of the ray on the mirror and the center of curvature of the mirror
function e = epsilon(inc_angle, r, s)
    q = r - s;
    e = asin(q / r * sin(inc_angle));
end

% angle of reflected ray
function r = ref_angle(inc_angle, r, s)
    r = inc_angle - 2 * epsilon(inc_angle, r, s);
end

% the z-coordinate of the intersection of the reflected ray with the axis
function z = ref_z(inc_angle, r, s)
    q = r * sin(-epsilon(inc_angle, r, s)) / sin(ref_angle(inc_angle, r, s));
    z = r - q;
end

% the y-coordinate of the intersection of the incident ray with the mirror 
function h = height(inc_angle, r, s)
    phi = ref_angle(inc_angle, r, s) + epsilon(inc_angle, r, s);
    h = r * sin(phi);
end    

% line equation for extension of the reflected ray
function l = line(inc_angle, z, z0)
    l = tan(inc_angle) * (z - z0);
end    

figure
hold on
plot(surface(y, radius), y) % mirror surface visualization
plot([-2 * radius 0], [0 0]) % axis of the mirror
plot([-focal_length], [0], 'o') % focal point

angles = linspace(-angle_d, angle_d, num_rays);
for i = 1:length(angles)
    inc_angle = angles(i) * pi / 180;
    h = height(inc_angle, radius, source_pos);

    z_inc = [-source_pos surface(h, radius)];
    y_inc = [0 h];
    plot(z_inc, y_inc, 'k') % draw incident beam

    z_0 = ref_z(inc_angle, radius, source_pos);
    if isnan(z_0)
        z_0 = -2 * radius;
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
        
    z_ref = [surface(h, radius) -2 * radius];
    y_ref = [h line(ref_angle(inc_angle, radius, source_pos), -2 * radius, z_0)];
    if abs(source_pos) < abs(2 * focal_length) & abs(source_pos) > abs(focal_length) & abs(z_0) > abs(2 * radius)
        z_ref = [surface(h, radius) z_0]
        y_ref = [h 0]
    end
    plot(z_ref, y_ref, 'r')
end

title(sprintf("Radius = %.1f mm. Focal length = %.1f mm. Source position = %.1f mm.\nMaximum incident angle = %.1f{\\deg}. Number of rays = %d", radius, focal_length, -source_pos, angle_d, num_rays))
xlabel("z, mm")
ylabel("r, mm")
ylim([-radius radius])
xlim([-2 * radius 0])
grid on