
%Proje Ba�l���; PSO kullanarak Bin Packing probleminin ��z�m�

clc;
clear;
close all;
%% Problem Tan�m�

model = ModelOlusturma();  % Bin Packing Modelini Olu�turulmas�

CostFunction = @(x) BinPackingMaliyet(x, model);  % Ama� Fonksiyonu

nVar = 2*model.n-1;     % Karar De�i�kenleri Katsay�s�
VarSize = [1 nVar];     % Karar De�i�kenleri Matris Boyutu

VarMin = 0;     % Karar De�i�kenlerinin Alt S�n�r�
VarMax = 1;     % Karar De�i�kenlerinin �st S�n�r�


%% PSO Parametreleri

MaxIt=100;      % Tekrarlanmalar�n Maksimum Say�s�

nPop=20;        % Populasyon Boyutu (S�r� Boyutu)

% PSO Parametreleri
w=1;            % S�redurum A��rl���
wdamp=0.99;     % S�redurum A��rl�k S�n�m Oran�
c1=1.5;         % Ki�isel ��renme Katsay�s�
c2=2.0;         % K�resel ��renme Katsay�s�


% H�z Limitleri
VelMax=0.1*(VarMax-VarMin);
VelMin=-VelMax;

nParticleMutation = 2;      % Her Par�ac�kta Ger�ekle�tirilen Mutasyon Say�s�
nGlobalBestMutation = 5;    % Global En �yi Ger�ekle�tirilen Mutasyon Say�s�

%% Ba�latma

empty_particle.Position=[];
empty_particle.Cost=[];
empty_particle.Sol=[];
empty_particle.Velocity=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];
empty_particle.Best.Sol=[];

particle=repmat(empty_particle,nPop,1);

GlobalBest.Cost=inf;

for i=1:nPop
    
    % Konum Ba�latma
    particle(i).Position=unifrnd(VarMin,VarMax,VarSize);
    
    % H�z�n� Ba�latma
    particle(i).Velocity=zeros(VarSize);
    
    % De�erlendirme
    [particle(i).Cost, particle(i).Sol]=CostFunction(particle(i).Position);
    
    % Ki�isel En �yi G�ncelleme
    particle(i).Best.Position=particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;
    particle(i).Best.Sol=particle(i).Sol;
    
    % Global En �yi G�ncelleme
    if particle(i).Best.Cost<GlobalBest.Cost
        GlobalBest=particle(i).Best;
    end
    
end

BestCost=zeros(MaxIt,1);

%% PSO Ana D�ng�

for it=1:MaxIt
    
    for i=1:nPop
        
        % G�ncelleme H�z�
        particle(i).Velocity = w*particle(i).Velocity ...
            +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
            +c2*rand(VarSize).*(GlobalBest.Position-particle(i).Position);
        
        % H�z Limitlerini Uygulama
        particle(i).Velocity = max(particle(i).Velocity,VelMin);
        particle(i).Velocity = min(particle(i).Velocity,VelMax);
        
        % Pozisyon G�ncelleme
        particle(i).Position = particle(i).Position + particle(i).Velocity;
        
        % H�z aynas� etkisi
        IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
        particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);
        
        % PoZisyon Limitlerini Uygulama
        particle(i).Position = max(particle(i).Position,VarMin);
        particle(i).Position = min(particle(i).Position,VarMax);
        
        % De�erlendirme
        [particle(i).Cost, particle(i).Sol] = CostFunction(particle(i).Position);
        
        % Mutasyon Yapma
        for j=1:nParticleMutation
            NewParticle = particle(i);
            NewParticle.Position = Degisme(particle(i).Position);
            [NewParticle.Cost, NewParticle.Sol] = CostFunction(NewParticle.Position);
            if NewParticle.Cost <= particle(i).Cost
                particle(i) = NewParticle;
            end
        end
        
        % Ki�isel En �yi G�ncelleme
        if particle(i).Cost<particle(i).Best.Cost
            
            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;
            particle(i).Best.Sol=particle(i).Sol;
            
            % Global en iyi g�ncelleme
            if particle(i).Best.Cost<GlobalBest.Cost
                GlobalBest=particle(i).Best;
            end
            
        end
        
    end
    
    % Global En �yi Mutasyon Yapmak
    for i=1:nGlobalBestMutation
        NewParticle = GlobalBest;
        NewParticle.Position = Degisme(GlobalBest.Position);
        [NewParticle.Cost, NewParticle.Sol] = CostFunction(NewParticle.Position);
        if NewParticle.Cost <= GlobalBest.Cost
            GlobalBest = NewParticle;
        end
    end
    
    
    BestCost(it)=GlobalBest.Cost;
    
    disp(['Ad�m ' num2str(it) ': En �yi Maliyet = ' num2str(BestCost(it))]);
    
    w=w*wdamp;
    
end

BestSol = GlobalBest;

%% Sonu�lar

figure;
plot(BestCost,'LineWidth',2);
xlabel('Ad�m');
ylabel('En �yi Maliyet');
grid on;
