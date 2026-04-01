function r_ECEF = orbitProp(h, i, RAAN, nSat, tspan, f)

if nargin < 6
    f = 1;
end

% constant
Re = 6378e3;
mu = 3.986e14;

r = Re + h; 
n = sqrt(mu / r^3);

Nt = length(tspan);
nPlane = numel(RAAN);

if mod(nSat, nPlane) ~= 0
    error('Walker phasing requires nSat to be divisible by the number of planes.');
end

satsPerPlane = nSat / nPlane;
r_ECEF = zeros(3, Nt, nSat);

% loop for each orbital planet
satIdx = 1;
for p = 1:nPlane
    nThisPlane = satsPerPlane;
    
    % loop for each satellite inside the plane
    for s = 1:nThisPlane
        % Walker phasing from M_ij = 2*pi/S*(j-1) + 2*pi/N*F*(i-1)
        nu0 = 2*pi*(s-1)/nThisPlane + 2*pi*f*(p-1)/nSat;
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
            r_eci = rotz(RAAN(p)) * rotx(i) * rotz(omega) * r_pqw;

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
