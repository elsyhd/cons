function [A, Ctot, r_all] = simulateConstellation()

% set start time
startTime = datetime(2026, 3, 21, 0, 0, 0, 'TimeZone', 'UTC');
tspan = startTime + minutes(0:5:24*60);

% set variation parameters
h = 800e3;
i = deg2rad(15);
RAAN = deg2rad(linspace(0, 359, 8));
nSat = 24;

users = [ ...
    deg2rad(5.5),    deg2rad(95.3),   0;
    deg2rad(-2.5),   deg2rad(140.7),  0;
    deg2rad(1.67),   deg2rad(125.0),  0;
    deg2rad(-10.0),  deg2rad(120.5),  0;
    deg2rad(-7.5),   deg2rad(107.5),  0];

siteNames = { ...
    'Banda Aceh', ...
    'Jayapura', ...
    'Minahasa Utara', ...
    'Sumba Timur', ...
    'Garut'};

% propagate each satellites
r_leo = orbitProp(h, i, RAAN, nSat, tspan);
r_all = addGeoHostedPayload(r_leo, tspan, deg2rad(117));

% check availability
[A, visibleSat] = satAvailability(r_all, users);

% check cost
Ctot = satCost(r_all, 1);

visibleAny = any(visibleSat, 3);
visibleCount = sum(visibleAny, 2);

for idx = 1:numel(siteNames)
    fprintf('%s Availability = %.3f\n', siteNames{idx}, A(idx));
end
fprintf('Total Cost   = %.2f\n', Ctot);
fprintf('Mean Visible = %.2f\n', mean(visibleCount));
fprintf('Max Visible  = %d\n', max(visibleCount));

plotConstellation3DVideo(r_all, visibleSat, users, siteNames, tspan, 'constellation_simulation.mp4');
end
