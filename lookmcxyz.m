% lookmcxyz.m
%   Looks at myname_F.bin, created by mcxyz.c 
%   where myname is the name of the run: myname_T.bin, myname_H.mci
%
% lookmcxyz_alc2.m, July 23
%       Absorption array is OFF.
%
%   Simulates angiolight catheter within 4-mm-dia. vessel
% with the vessel wall at a particular musp value. 
%   For this run, musp = 200 cm^-1.
%
% Reads 8 mcxyz runs, for 8 catheter positions, zs = 0.2 to 0.6 cm.
% For each run:
%   alc#_H.mci --> header:
%       timin,Nx,Ny,Nz,dy,dx,dz,xs,ys,zx,Nt,muav(),musv(),gv()
%   alc#_F.bin --> F(y,x,z) = relative fluence rate [1/cm^2]
%   alc#_T.bin --> T(y,x,z) = tissue types
%
% Displays
%   Tzx = end-view of tissue structure
%   Fzx = end-view of vessel @ source, ys = -0.15 cm
%   Fzy = side-view along length of vessel
%
% Saves
%   Fzy_data4.mat = Fzy y z zzs Fdet
%       Fzy(400,400,8) = 8 z,y images
%       Fdet(8,1) = signal [1/cm^2] @ detector fiber
%
home
clear
format compact
commandwindow
global tissue

cc = 'rbgm'; % color

%%%% USER CHOICES <---------- you must specify -----
myname = 'example3';
%%%%


disp(sprintf('------ mcxyz %s -------',myname))

% Load header file
filename = sprintf('%s_H.mci',myname);
disp(['loading ' filename])
fid = fopen(filename, 'r');
A = fscanf(fid,'%f',[1 Inf])';
fclose(fid);

%% parameters
time_min = A(1);
Nx = A(2);
Ny = A(3);
Nz = A(4);
dx = A(5);
dy = A(6);
dz = A(7);
mcflag = A(8);
launchflag = A(9);
xs = A(10);
ys = A(11);
zs = A(12);
xfocus = A(13);
yfocus = A(14);
zfocus = A(15);
ux0 = A(16);
uy0 = A(17);
uz0 = A(18);
radius = A(19);
waist = A(20);
Nt = A(21);
j = 21;
for i=1:Nt
    j=j+1;
    muav(i,1) = A(j);
    j=j+1;
    musv(i,1) = A(j);
    j=j+1;
    gv(i,1) = A(j);
end

reportHmci

%% Load Fluence rate F(y,x,z) 
filename = sprintf('%s_F.bin',myname);
disp(['loading ' filename])
tic
    fid = fopen(filename, 'rb');
    [Data count] = fread(fid, Ny*Nx*Nz, 'float');
    fclose(fid);
toc
F = reshape(Data,Ny,Nx,Nz); % F(y,x,z)


% Load tissue structure in voxels, T(y,x,z) 
filename = sprintf('%s_T.bin',myname);
disp(['loading ' filename])
tic
    fid = fopen(filename, 'rb');
    [Data count] = fread(fid, Ny*Nx*Nz, 'uint8');
    fclose(fid);
toc
T = reshape(Data,Ny,Nx,Nz); % T(y,x,z)

clear Data

%%
x = ([1:Nx]-Nx/2-1/2)*dx;
y = ([1:Ny]-Ny/2-1/2)*dx;
z = ([1:Nz]-1/2)*dz;
ux = [2:Nx-1];
uy = [2:Ny-1];
uz = [2:Nz-1];
zmin = min(z);
zmax = max(z);
zdiff = zmax-zmin;
xmin = min(x);
xmax = max(x);
xdiff = xmax-xmin;

%% Look at structure, Tzx
Tzx = reshape(T(Ny/2,:,:),Nx,Nz)';
tissueProps = makeTissueList(532);
Nt = length(tissue);

figure(1);clf
imagesc(x(ux),z(uz),Tzx(uz,ux),[1 Nt])
hold on
cmap = makecmap(Nt);
colormap(cmap)
colorbar
set(gca,'fontsize',18)
set(colorbar,'fontsize',1)
xlabel('x [cm]')
ylabel('z [cm]')
title('Tissue types')
for i=1:Nt
    yy = zmin + (Nt-i)/(Nt-1)*zdiff;
    text(xmin + xdiff*1.13,yy, sprintf('%d %s',i,tissue(i).s),'fontsize',12)
end
axis equal image

% draw launch
N = 10; % # of beam rays drawn
switch mcflag
    case 0 % uniform
        for i=0:N
            for j=-2:2
            plot( [xs+radius*i/N xfocus + waist*j/2],[zs zfocus],'r-')
            plot(-[xs+radius*i/N xfocus + waist*j/2],[zs zfocus],'r-')
            end
        end

    case 1 % Gaussian
        for i=0:N
            for j=-2:2
            plot( [xs+radius*i/N xfocus + waist*j/2],[zs zfocus],'r-')
            plot(-[xs+radius*i/N xfocus + waist*j/2],[zs zfocus],'r-')
            end
        end

    case 2 % iso-point
        for i=1:20
            th = (i-1)/19*2*pi;
            xx = Nx/2*cos(th) + xs;
            zz = Nx/2*sin(th) + zs;
            plot([xs xx],[zs zz],'r-')
        end
end

print -djpeg -r300 'Fig_tissueTypes.jpg'


%% Look at Fluence Fzx @ launch point
Fzx = reshape(F(Ny/2,:,:),Nx,Nz)'; % in z,x plane through source

figure(2);clf
imagesc(x,z,log10(Fzx),[-3 3])
hold on
text(max(x)*0.9,min(z)-0.04*max(z),'log_{10}( \phi )','fontsize',18)
colorbar
set(gca,'fontsize',18)
xlabel('x [cm]')
ylabel('z [cm]')
title('Fluence \phi [W/cm^2/W.delivered] ')
colormap(makec2f)
axis equal image
axis([min(x) max(x) min(z) max(z)])

print -djpeg -r300 'Fig_Fzx.jpg'

%% look Fzy
Fzy = reshape(F(:,Nx/2,:),Ny,Nz)';

iy = round((dy*Ny/2 + 0.15)/dy);
iz = round(zs/dz);
zzs  = zs;
Fdet = mean(reshape(Fzy(iz+[-1:1],iy+[0 1]),6,1));

figure(3);clf
imagesc(y,z,log10(Fzy),[-1 1]*3)
hold on
text(max(x)*0.9,min(z)-0.04*max(z),'log_{10}( \phi )','fontsize',18)
colorbar
set(gca,'fontsize',18)
xlabel('y [cm]')
ylabel('z [cm]')
title('Fluence \phi [W/cm^2/W.delivered] ')
colormap(makec2f)
axis equal image

print -djpeg -r300 'Fig_Fzy.jpg'

drawnow

disp('done')

