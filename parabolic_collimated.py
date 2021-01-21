import matplotlib.pyplot as plt
import numpy as np

focal_length = 100 # focal length in mm
angle_deg = 0 # angle of incidence of the incident beam in degrees
rays = 21 # number of rays

p = 2 * focal_length # parameter of the parabola equation y**2 = 2*p*z
a = 1.1 * focal_length  # mirror field
inc_ang = -angle_deg * np.pi / 180 if angle_deg > 0.000001 else 0.000001 * np.pi / 180  # incident ray angle in radians
var = np.arange(-a, a, 0.1)

# mirror equation
def surface(y):
    return -y ** 2 / (2 * p)

# reflection angle
def refl_ang(y, inc_ang):
    return 2 * np.arctan(y / p) - inc_ang


# incident ray vector (y_start, y_end)
# x_vec is vector (x_start, x_end)
def inc_vec(y, inc_ang, x_vec):
    return np.tan(-inc_ang) * (x_vec - surface(y)) + y


# reflected ray vector (y_start, y_end)
# x_vec is vector (x_start, x_end)
def refl_vec(y, inc_ang, x_vec):
    r = refl_ang(y, inc_ang)
    return np.tan(r) * (x_vec - surface(y) + y / np.tan(r))


plt.figure(figsize=(13, 8))
plt.plot(surface(var), var) # mirror surface visualization
plt.plot([-p, 0], [0, 0]) # axis of the mirror
plt.plot([-focal_length], [0], 'o') # focal point

for y in np.linspace(-focal_length, focal_length, rays):
    x_vec = np.array([-p, surface(y)])
    
    plt.plot(x_vec, inc_vec(y, inc_ang, x_vec), 'k', lw=1)

    r = refl_ang(y, inc_ang)
    if (r < np.pi / 2 and r > -np.pi / 2):
        plt.plot(x_vec, refl_vec(y, inc_ang, x_vec), 'r', lw=1)
    else:
        x_vec_out = np.array([surface(y), 0])
        plt.plot(x_vec_out, refl_vec(y, inc_ang, x_vec_out), 'r', lw=1)

plt.title("Focal length = {:.1f} mm. Incident angle = {:.1f} deg. Number of rays = {}".format(focal_length, angle_deg, rays))
plt.xlabel("z, mm")
plt.ylabel("r, mm")
plt.ylim(-a, a)
plt.xlim(-p, 0)
plt.grid()
plt.show()