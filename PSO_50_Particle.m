%% Parçacýk sürü optimizasyonu simülasyonu (Particle Swarm Optimization Simulation)
% Amaç fonksiyonun minimumunu bul(Find minimum of  the objective function)
%% Baþlangýç (Initialization)

clear
clc
iterations = 30;
inertia = 1.0;
correction_factor = 2.0;
swarms = 50;

% ---- Ýlk sürü konumu (initial swarm position) -----
swarm=zeros(50,7)
step = 1;
for i = 1 : 50
swarm(step, 1:7) = i;
step = step + 1;
end

swarm(:, 7) = 1000       % Mümkün olan en yüksek degeri (Greater than maximum possible value)
swarm(:, 5) = 0          % baþlangýç hýzý (initial velocity)
swarm(:, 6) = 0          % baþlangýç hýzý (initial velocity)

%% Tekrarlamalar (Iterations)
for iter = 1 : iterations
    
    %-- Sürülerin Konumu (position of Swarms) ---
    for i = 1 : swarms
        swarm(i, 1) = swarm(i, 1) + swarm(i, 5)/1.2     %U konumunun güncellenmesi (update u position)
        swarm(i, 2) = swarm(i, 2) + swarm(i, 6)/1.2     %V konumunun güncellenmesi (update v position)
        u = swarm(i, 1)
        v = swarm(i, 2)
        
        value = (u - 20)^2 + (v - 10)^2          %Amaç fonksiyonu (Objective function)
        
        if value < swarm(i, 7)           % Her zaman doðru ise (Always True)
            swarm(i, 3) = swarm(i, 1)    % U'nun en iyi konumunun güncellenmesi (update best position of u)
            swarm(i, 4) = swarm(i, 2)    % V'nun en iyi konumunun güncellenmesi (update best postions of v)
            swarm(i, 7) = value          % En güncel en düþük deðer (best updated minimum value)
        end
    end

    [temp, gbest] = min(swarm(:, 7))        % gbest Konumu
    
    %--- Hýz vektörlerinin güncellenmesi (updating velocity vectors)
    for i = 1 : swarms
        swarm(i, 5) = rand*inertia*swarm(i, 5) + correction_factor*rand*(swarm(i, 3)...
            - swarm(i, 1)) + correction_factor*rand*(swarm(gbest, 3) - swarm(i, 1))   %U vektörünün parametreleri(u velocity parameters)
        swarm(i, 6) = rand*inertia*swarm(i, 6) + correction_factor*rand*(swarm(i, 4)...
            - swarm(i, 2)) + correction_factor*rand*(swarm(gbest, 4) - swarm(i, 2))   %V vektörünün parametreleri(v velocity parameters)
    end
    
    %% Sürülerin çizimi (Plotting the swarm)    
    clf    
    plot(swarm(:, 1), swarm(:, 2), 'x')   % Sürü hareketlerinin çizimi(drawing swarm movements)
    axis([-2 50 -2 50])
    grid on;
pause(.1)
end