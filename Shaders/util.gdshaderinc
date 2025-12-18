const mat3 RGBtoYIQ = mat3(vec3(0.299, 0.5959, 0.2115),
                           vec3(0.587, -0.2746, -0.5227),
                           vec3(0.114, -0.3213, 0.3112));

const mat3 YIQtoRGB = mat3(vec3(1, 1, 1),
                           vec3(0.956, -0.272, -1.106),
                           vec3(0.619, -0.647, 1.703));

vec3 shift_hue(vec3 rgb, float ang) {
    vec3 yiq = RGBtoYIQ * rgb;
    //Rotate I and Q chrominance values and scale for saturation
    yiq.yz *= mat2(vec2(cos(ang), -sin(ang)), vec2(sin(ang), cos(ang)));

    //Convert back to RGB colour space
    return YIQtoRGB * yiq;
}

// random number generator
int pcg(int u)
{
    uint state = uint(u) * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return int((word >> 22u) ^ word) % 1000;
}

/* http://www.jcgt.org/published/0009/03/02/ */
ivec3 pcg3d(vec3 v)
{
  uvec3 u = floatBitsToUint(v);

  u = u * 1664525u + 1013904223u;

  u.x += u.y * u.z;
  u.y += u.z * u.x;
  u.z += u.x * u.y;

  u ^= u >> 16u;

  u.x += u.y * u.z;
  u.y += u.z * u.x;
  u.z += u.x * u.y;

  return floatBitsToInt(vec3(u) / float(0xffffffffU))&ivec3(0xffu);
}
