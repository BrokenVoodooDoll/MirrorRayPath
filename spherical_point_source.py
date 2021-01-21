import matplotlib.pyplot as plt
import numpy as np
from numpy.lib.function_base import angle

radius = 100 # curvature radius of the mirror in mm (must be positive)
angle_d = 30 # maximum angle of incidence of the incident beam in degrees
num_rays = 21 # number of rays
source_pos = 80 # source position in mm (must be positive)

focal_length = radius / 2 # focal length of the mirror
y = np.linspace(-radius, radius, 1000)

# mirror equation z = sqrt(R^2 - y^2) - R
def surface(y):
    return np.sqrt(radius ** 2 - y ** 2) - radius

# angle between the incident ray and the line connecting the point of incidence
# of the ray on the mirror and the center of curvature of the mirror
def epsilon(inc_angle):
    q = radius - source_pos
    return np.arcsin(q / radius * np.sin(inc_angle))

# angle of reflected ray
def ref_angle(inc_angle):
    return inc_angle - 2 * epsilon(inc_angle)

# the z-coordinate of the intersection of the reflected ray with the axis
def ref_z(inc_angle):
    q = radius * np.sin(-epsilon(inc_angle)) / np.sin(ref_angle(inc_angle))
    return radius - q

# the y-coordinate of the intersection of the incident ray with the mirror 
def height(inc_angle):
    phi = ref_angle(inc_angle) + epsilon(inc_angle)
    return radius * np.sin(phi)

# line equation for extension of the reflected ray
def line(inc_angle, z, z0):
    return np.tan(inc_angle) * (z - z0)


plt.figure(figsize=(13, 8))
plt.plot(surface(y), y) # mirror surface visualization
plt.plot([-2 * radius, 0], [0, 0]) # axis of the mirror
plt.plot([-focal_length], [0], 'o') # focal point

for ang in np.linspace(-angle_d, angle_d, num_rays):
    inc_angle = ang * np.pi / 180
    h = height(inc_angle)

    z_inc = np.array([-source_pos, surface(h)])
    y_inc = np.array([0, h])
    plt.plot(z_inc, y_inc, 'k', lw=1) # draw incident beam

    z_0 = ref_z(inc_angle)
    if np.isnan(z_0):
        z_0 = -2 * radius

    if source_pos >= focal_length:
        z_0 = -z_0 if z_0 > 0 else z_0
    else:
        z_0 = z_0 if z_0 > 0 else -z_0
        
    z_ref = np.array([surface(h), -2 * radius])
    y_ref = np.array([h, line(ref_angle(inc_angle), -2 * radius, z_0)])   
    if abs(source_pos) < abs(2 * focal_length) and abs(source_pos) > abs(focal_length) and abs(z_0) > abs(2 * radius):
        z_ref = np.array([surface(h), z_0])
        y_ref = np.array([h, 0])
    plt.plot(z_ref, y_ref, 'r', lw=1)

plt.title("Radius = {:.1f} mm. Focal length = {:.1f} mm. Source position = {:.1f} mm.\nMaximum incident angle = {:.1f} deg. Number of rays = {}".format(radius, focal_length, -source_pos, angle_d, num_rays))
plt.xlabel("z, mm")
plt.ylabel("r, mm")
plt.ylim(-radius, radius)
plt.xlim(-2 * radius, 0)
plt.grid()
plt.show()