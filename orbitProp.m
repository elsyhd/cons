function r_ECEF = orbitProp(h, i, RAAN, nSat, tspan)

% constant
Re = 6378e3;
mu = 3.986e14;

r = Re + h; 
n = sqrt(mu / r^3);

Nt = length(tspan);
nPlane = numel(RAAN);
satsPerPlane = distributeSatellites(nSat, nPlane);
r_ECEF = zeros(3, Nt, nSat);

% loop for each orbital plane
satIdx = 1;
for p = 1:nPlane
    nThisPlane = satsPerPlane(p);
    
    % loop for each satellite inside the plane
    for s = 1:nThisPlane
        nu0 = 2*pi*(s-1)/nThisPlane;
        omega = 0;
        
        % loop for each timestep
        for k = 1:Nt
            t_sec = seconds(tspan(k) - tspan(1));

            % true anomaly
            nu = nu0 + n*t_sec;

            % PQW
            r_pqw = [r*cos(nu);
                     r*sin(nu);
                     0];

            % PQW -> ECI
            r_eci = rotz(RAAN(p)) * rotx(i(p)) * rotz(omega) * r_pqw;

            % ECI -> ECEF
            r_ecef = eci2ecef(tspan(k), r_eci');

            r_ECEF(:,k,satIdx) = r_ecef';
        end

        satIdx = satIdx + 1;
    end
end

end


% rotation matrix
% R1
function R = rotx(a)
R = [1 0 0;
     0 cos(a) -sin(a);
     0 sin(a)  cos(a)];
end

% R3
function R = rotz(a)
R = [cos(a) -sin(a) 0;
     sin(a)  cos(a) 0;
     0       0      1];
end

function satsPerPlane = distributeSatellites(nSat, nPlane)
baseCount = floor(nSat / nPlane);
remainder = mod(nSat, nPlane);

satsPerPlane = baseCount * ones(1, nPlane);

for idx = 1:remainder
    satsPerPlane(idx) = satsPerPlane(idx) + 1;
end
end
