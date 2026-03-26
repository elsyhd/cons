# Regional Nav Sat Constellation Simulation
# Update 24/03/2026

This project simulates a regional satellite navigation constellation for Indonesia using MATLAB.

It includes:
- LEO satellite propagation
- 1 hosted GEO payload
- availability check
- simple cost estimation

# how to use
- run simulateConsttellation.m
- if necessary, adjust the variation parameter

# file overview
- simulateConstellation.m
  main driver script to runs the whole simulation

- orbitProp.m
  propagate LEO satellites and transform coordinates to ECEF

- addGeoHostedPayload.m
  add one GEO hosted payload above Indonesia, currently using N5 at 113 E

- satAvailability.m
  check which satellites are visible from each target location and calculate availability

- satCost.m
  estimates the total constellation cost

- plotConstellation3DVideo.m
  creates the 3D constellation plot
