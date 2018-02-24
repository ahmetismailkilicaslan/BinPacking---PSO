
%Proje Baþlýðý; PSO kullanarak Bin Packing probleminin çözümü

clc;
clear;
close all;
%% Problem Tanýmý

model = ModelOlusturma();  % Bin Packing Modelini Oluþturulmasý

CostFunction = @(x) BinPackingMaliyet(x, model);  % Amaç Fonksiyonu

nVar = 2*model.n-1;     % Karar Deðiþkenleri Katsayýsý
VarSize = [1 nVar];     % Karar Deðiþkenleri Matris Boyutu

VarMin = 0;     % Karar Deðiþkenlerinin Alt Sýnýrý
VarMax = 1;     % Karar Deðiþkenlerinin Üst Sýnýrý


%% PSO Parametreleri

MaxIt=100;      % Tekrarlanmalarýn Maksimum Sayýsý

nPop=20;        % Populasyon Boyutu (Sürü Boyutu)

% PSO Parametreleri
w=1;            % Süredurum Aðýrlýðý
wdamp=0.99;     % Süredurum Aðýrlýk Sönüm Oraný
c1=1.5;         % Kiþisel Öðrenme Katsayýsý
c2=2.0;         % Küresel Öðrenme Katsayýsý


% Hýz Limitleri
VelMax=0.1*(VarMax-VarMin);
VelMin=-VelMax;

nParticleMutation = 2;      % Her Parçacýkta Gerçekleþtirilen Mutasyon Sayýsý
nGlobalBestMutation = 5;    % Global En Ýyi Gerçekleþtirilen Mutasyon Sayýsý

%% Baþlatma

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
    
    % Konum Baþlatma
    particle(i).Position=unifrnd(VarMin,VarMax,VarSize);
    
    % Hýzýný Baþlatma
    particle(i).Velocity=zeros(VarSize);
    
    % Deðerlendirme
    [particle(i).Cost, particle(i).Sol]=CostFunction(particle(i).Position);
    
    % Kiþisel En Ýyi Güncelleme
    particle(i).Best.Position=particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;
    particle(i).Best.Sol=particle(i).Sol;
    
    % Global En Ýyi Güncelleme
    if particle(i).Best.Cost<GlobalBest.Cost
        GlobalBest=particle(i).Best;
    end
    
end

BestCost=zeros(MaxIt,1);

%% PSO Ana Döngü

for it=1:MaxIt
    
    for i=1:nPop
        
        % Güncelleme Hýzý
        particle(i).Velocity = w*particle(i).Velocity ...
            +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
            +c2*rand(VarSize).*(GlobalBest.Position-particle(i).Position);
        
        % Hýz Limitlerini Uygulama
        particle(i).Velocity = max(particle(i).Velocity,VelMin);
        particle(i).Velocity = min(particle(i).Velocity,VelMax);
        
        % Pozisyon Güncelleme
        particle(i).Position = particle(i).Position + particle(i).Velocity;
        
        % Hýz aynasý etkisi
        IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
        particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);
        
        % PoZisyon Limitlerini Uygulama
        particle(i).Position = max(particle(i).Position,VarMin);
        particle(i).Position = min(particle(i).Position,VarMax);
        
        % Deðerlendirme
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
        
        % Kiþisel En Ýyi Güncelleme
        if particle(i).Cost<particle(i).Best.Cost
            
            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;
            particle(i).Best.Sol=particle(i).Sol;
            
            % Global en iyi güncelleme
            if particle(i).Best.Cost<GlobalBest.Cost
                GlobalBest=particle(i).Best;
            end
            
        end
        
    end
    
    % Global En Ýyi Mutasyon Yapmak
    for i=1:nGlobalBestMutation
        NewParticle = GlobalBest;
        NewParticle.Position = Degisme(GlobalBest.Position);
        [NewParticle.Cost, NewParticle.Sol] = CostFunction(NewParticle.Position);
        if NewParticle.Cost <= GlobalBest.Cost
            GlobalBest = NewParticle;
        end
    end
    
    
    BestCost(it)=GlobalBest.Cost;
    
    disp(['Adým ' num2str(it) ': En Ýyi Maliyet = ' num2str(BestCost(it))]);
    
    w=w*wdamp;
    
end

BestSol = GlobalBest;

%% Sonuçlar

figure;
plot(BestCost,'LineWidth',2);
xlabel('Adým');
ylabel('En Ýyi Maliyet');
grid on;
