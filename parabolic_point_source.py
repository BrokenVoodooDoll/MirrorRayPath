import matplotlib.pyplot as plt
import numpy as np
from numpy.lib.function_base import angle

focal_length = 100 # focal length in mm
angle_d = 25 # maximum angle of incidence of the incident beam in degrees
num_rays = 21 # number of rays
source_pos = 400 # source position in mm (must be positive)
# there is a bug when source_pos = focal_length because of very small
# angles of reflectance.
# Instead, better to choose source_pos = focal_length + 0.01 or something like
# this

p = 2 * focal_length # parameter of the parabola equation y**2 = 2*p*z
y = np.linspace(-p, p, 1000)

# mirror equation z = -y^2 / (2 * p)
def surface(y):
    return -y ** 2 / (2 * p)

def phi(y):
    return np.arctan(y / p)

# angle between the incident ray and the line connecting the point of incidence
# of the ray on the mirror and the center of curvature of the mirror
def epsilon(y, inc_angle):
    return inc_angle - phi(y)

# angle of reflected ray
def ref_angle(y, inc_angle):
    return phi(y) - epsilon(y, inc_angle)

# the z-coordinate of the intersection of the reflected ray with the axis
def ref_z(y, inc_angle):
    if inc_angle == 0:
        return 0
    tg_sigma = np.tan(inc_angle)
    z = -(y - source_pos * tg_sigma) / tg_sigma
    return y / np.tan(ref_angle(y, inc_angle)) + z

# the y-coordinate of the intersection of the incident ray with the mirror 
def height(inc_angle):
    if inc_angle == 0:
        return 0
    tg_sigma = np.tan(inc_angle)
    return -p / tg_sigma * (1 - np.sqrt(1 + 2 * source_pos / p * tg_sigma**2))

# line equation for extension of the reflected ray
def line(ref_angle, z, z0):
    return np.tan(ref_angle) * (z - z0)


plt.figure(figsize=(13, 8))
plt.plot(surface(y), y) # mirror surface visualization
plt.plot([-2 * p, 0], [0, 0]) # axis of the mirror
plt.plot([-focal_length], [0], 'o') # focal point

for ang in np.linspace(-angle_d, angle_d, num_rays):
    inc_angle = ang * np.pi / 180
    h = height(inc_angle)

    z_inc = np.array([-source_pos, surface(h)])
    y_inc = np.array([0, h])
    plt.plot(z_inc, y_inc, 'k', lw=1) # draw incident beam

    z_0 = ref_z(h,  inc_angle)
    if np.isnan(z_0):
        z_0 = -2 * p

    if source_pos >= focal_length:
        z_0 = -z_0 if z_0 > 0 else z_0
    else:
        z_0 = z_0 if z_0 > 0 else -z_0
    
    z_ref = np.array([surface(h), -2 * p])
    y_ref = np.array([h, line(ref_angle(h, inc_angle), -2 * p, z_0)])   
    plt.plot(z_ref, y_ref, 'r', lw=1)

plt.title("Focal length = {:.1f} mm. Source position = {:.1f} mm.\nMaximum incident angle = {:.1f} deg. Number of rays = {}".format(focal_length, -source_pos, angle_d, num_rays))
plt.xlabel("z, mm")
plt.ylabel("y, mm")
plt.ylim(-p, p)
plt.xlim(-2 * p, 0)
plt.grid()
plt.show()