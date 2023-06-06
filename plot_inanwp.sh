#!/bin/bash
#SBATCH --job-name=wrf_inanwp       #passed by script
#SBATCH --nodes=1                #passed by script
#SBATCH --ntasks-per-node=72
#SBATCH --time=72:00:00
#SBATCH --output=wrf_inanwp.log #passed by script
#SBATCH --export=ALL
source ~/.bashrc

cat << EOF > n.py
from netCDF4 import Dataset,date2num,num2date
#from xgrads  import open_CtlDataset
import matplotlib.pyplot as pl
from matplotlib.colors import LinearSegmentedColormap
from multiprocessing import Pool, TimeoutError
import numpy as np
import pytz, sys
import glob
import datetime
from PIL import Image
import os
os.environ['PROJ_LIB'] = r'/home/den/.libraries/anaconda3/share/proj'
from mpl_toolkits.basemap import Basemap
from wrf import getvar, vinterp, interplevel, to_np, get_basemap, latlon_coords, extract_times, ALL_TIMES
from timeit import default_timer as timer
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
warnings.filterwarnings("ignore")

start = timer()
degree='degC'
unit1='per 100000 s'
def peta_indo(lons,lats,bound,data1,data2,data3,data4,parameters,path,fnam,step,init,pred,ver):     
    import matplotlib.pyplot as pl   
    import cartopy.crs as ccrs
    import cartopy.feature as cfeature
    from cartopy.util import add_cyclic_point
    from cartopy.vector_transform import vector_scalar_to_grid
    from cartopy.io.shapereader import Reader
    from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter
    from matplotlib.axes import Axes
    from matplotlib.cm import get_cmap
    import matplotlib.pyplot as plt
    import matplotlib.ticker as mticker
    from mpl_toolkits.axes_grid1 import make_axes_locatable
    if not os.path.isdir(path):
        os.makedirs(path)
    degree='degC'
    unit1='per 100000 s'
    fig = pl.figure(figsize=(10,6))
    crs_latlon = ccrs.PlateCarree()
    ax = fig.add_subplot(1, 1, 1, projection=crs_latlon)
    ax.set_extent([bound[2],bound[3],bound[0],bound[1]], crs=crs_latlon)
    # ax.coastlines('50m')
    ax.grid(False)
    ax.set_xticks([95, 100, 105, 110, 115, 120, 125, 130, 135, 140], crs=crs_latlon)
    ax.set_yticks([-10, -5, 0, 5], crs=crs_latlon)
    lon_formatter = LongitudeFormatter(zero_direction_label=True)
    lat_formatter = LatitudeFormatter()
    ax.xaxis.set_major_formatter(lon_formatter)
    ax.yaxis.set_major_formatter(lat_formatter)
    ax.tick_params(axis='both', which='major', labelsize=15)
    if parameters[-21:]=='Relative Humidity (%)':
        clevs=[50,55,60,65,70,75,80,85,90,95]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet_r', transform=crs_latlon, extend='both')
    elif parameters=='2-m Temperature ('+degree+')':
        clevs=[18,20,22,24,26,28,30,32,34,36]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='950 mb Temperature ('+degree+')':
        clevs=[13,15,17,19,21,23,25,27,29,31]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='900 mb Temperature ('+degree+')':
        clevs=[13,15,17,19,21,23,25,27,29,31]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='850 mb Temperature ('+degree+')':
        clevs=[14,15,16,17,18,19,20,21,22,23]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='700 mb Temperature ('+degree+')':
        clevs=[8,8.5,9,9.5,10,10.5,11,11.5,12,12.5]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='500 mb Temperature ('+degree+')':
        clevs=[-9,-8,-7,-6,-5,-4,-3,-2,-1,0]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='200 mb Temperature ('+degree+')':
        clevs=[-55,-54,-53,-52,-51,-50,-49,-48,-47,-46]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters[-19:]=='Wind & isotach(m/s)':
        # clevs=[8,10,12,14,16,18,20,22,24]
        clevs=[8,12,16,18,20,30,40,50,60]
        ccols=['white','palegreen','lime','limegreen','forestgreen','orange','orangered','red','firebrick','darkred']
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    elif parameters[-25:]=='divergence ('+unit1+')':
        # clevs=[0,0.5,1,1.5,2,2.5,3,4,5]
        clevs=[0,2,4,6,8,10,15,20,25]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='OrRd', transform=crs_latlon, extend='both')
    elif parameters[-26:]=='convergence ('+unit1+')':
        # clevs=[-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,0]
        clevs=[-25,-20,-15,-10,-8,-6,-4,-2,0]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='Greens_r', transform=crs_latlon, extend='both')
    elif parameters[-33:]=='relative vorticity ('+unit1+')':
        clevs=[-20,-15,-10,-5,-2,2,5,10,15,20]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='RdBu_r', transform=crs_latlon, extend='both')
    elif parameters=='10-m Wind(vector, m/s), 24hr Prec(shaded, mm), MSLP (contour, mb)':
        clevs=[0.5, 1, 5, 10, 15, 20, 40, 50, 65, 80, 100, 150]
        ccols=['#BEBEBE','#E8E8E7','#BDF2BA','#88F487','#68F422','#A4EE1B','#F2F220','#EFD216','#EBA91C','#ED8E1D','#EA661F','#EE251E','#E719B5'] 
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    else:
        clevs=[0.5, 1, 2, 3, 5, 10, 15, 20, 25, 30, 40, 50]
        ccols=['#BEBEBE','#E8E8E7','#BDF2BA','#88F487','#68F422','#A4EE1B','#F2F220','#EFD216','#EBA91C','#ED8E1D','#EA661F','#EE251E','#E719B5'] 
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    if np.logical_and(np.logical_and(data2!='none',data3=='none'),data4=='none').all()==True:
        ct=ax.contour(lons, lats, data2,colors='slategrey',linewidths=.9, transform=crs_latlon)   
        pl.gca().clabel(ct, inline=1, fontsize=8,fmt='%1.0i')
    elif np.logical_and(np.logical_and(data2!='none',data3!='none'),data4=='none').all()==True:
        new_x, new_y, new_u, new_v, = vector_scalar_to_grid(crs_latlon,crs_latlon,15,lons,lats,data2,data3)
        if parameters.find('vector')==-1:
            # Axes.streamplot(ax,new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
            ax.streamplot(new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
        else:
            Q=ax.quiver(new_x,new_y,new_u,new_v, transform=ccrs.PlateCarree(), regrid_shape=20, color='grey') 
            qk = pl.quiverkey(Q, 0.1, 0.1, 10, r'10 m/s', labelpos='E', coordinates='figure')
    elif data4!='none':
        ct=ax.contour(lons, lats, data4,colors='slategrey',linewidths=.9, transform=crs_latlon)   
        pl.gca().clabel(ct, inline=1, fontsize=8,fmt='%1.0i')
        new_x, new_y, new_u, new_v, = vector_scalar_to_grid(crs_latlon,crs_latlon,15,lons,lats,data2,data3)
        if parameters.find('vector')==-1:
            # Axes.streamplot(ax,new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
            ax.streamplot(new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
        else:
            Q=ax.quiver(new_x,new_y,new_u,new_v, transform=ccrs.PlateCarree(), regrid_shape=20, color='grey') 
            qk = pl.quiverkey(Q, 0.1, 0.1, 10, r'10 m/s', labelpos='E', coordinates='figure')
            # qk = pl.quiverkey(Q, 0.1, 0.1, 10, r'0 \frac{m}{s}$', labelpos='E', coordinates='figure')
    fname = '/scratch/bmkg_4/WRF/INPUT/shp/INDONESIA_PROP1.shp'
    ax.add_geometries(Reader(fname).geometries(),
                      crs_latlon,facecolor = (1, 1, 1, 0), 
                                   edgecolor = (0.1, 0.1, 0.1, 1),linewidth=0.35)
    ax.add_feature(cfeature.BORDERS,linewidth=0.35)
    ax.add_feature(cfeature.COASTLINE,linewidth=0.35)
    # ax.outline_patch.set_linewidth(0.35)
    cb=fig.colorbar(cs,ticks=clevs,orientation='horizontal',cax=fig.add_axes([0.07,0.051,0.9,0.03]))
    cb.ax.tick_params(labelsize=15) 
    plane = np.array(Image.open('/scratch/bmkg_4/WRF/INPUT/shp/Logo-BMKG-new.png'))
    ax = pl.axes([0.06,0.2, 0.06, 0.06], frameon=True)  
    ax.imshow(plane)
    ax.axis('off') 
    pl.gcf().text(0.06, 0.96, parameters, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.06, 0.91, 'Forecast: '+pred+' (T+'+step+')', rotation='horizontal',fontsize=15)
    pl.gcf().text(0.80, 0.86, ver, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.06, 0.86, '$\it{Initial :}$ '+init, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.58, 0.11, '@ $\it{Center}$ $\it{for}$ $\it{Research}$ $\it{and}$ $\it{Development}$ $\it{BMKG}$', rotation='horizontal',fontsize=12)
    # fig.tight_layout()
    fig.subplots_adjust(hspace=0,wspace=0,left=0.06,right=0.98,bottom=0.06,top=0.96)
    pl.savefig(path+fnam, format='png', dpi=90, bbox_inches='tight')
    pl.cla()
    pl.clf()
    pl.close()
def peta_jawa(lons,lats,bound,data1,data2,data3,data4,parameters,path,fnam,step,init,pred,ver):
    import matplotlib.pyplot as pl           
    import cartopy.crs as ccrs
    import cartopy.feature as cfeature
    from cartopy.util import add_cyclic_point
    from cartopy.vector_transform import vector_scalar_to_grid
    from cartopy.io.shapereader import Reader
    from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter
    from matplotlib.axes import Axes
    from matplotlib.cm import get_cmap
    import matplotlib.pyplot as plt
    import matplotlib.ticker as mticker
    from mpl_toolkits.axes_grid1 import make_axes_locatable
    if not os.path.isdir(path):
        os.makedirs(path)
    degree='degC'
    unit1='per 100000 s'
    fig = pl.figure(figsize=(10,5.4))
    crs_latlon = ccrs.PlateCarree()
    ax = fig.add_subplot(1, 1, 1, projection=crs_latlon)
    ax.set_extent([bound[2],bound[3],bound[0],bound[1]], crs=crs_latlon)
    # ax.coastlines('50m')
    ax.grid(False)
    ax.set_xticks([103, 105, 107, 109, 111, 113, 115], crs=crs_latlon)
    ax.set_yticks([-9, -8, -7, -6, -5], crs=crs_latlon)
    lon_formatter = LongitudeFormatter(zero_direction_label=True)
    lat_formatter = LatitudeFormatter()
    ax.xaxis.set_major_formatter(lon_formatter)
    ax.yaxis.set_major_formatter(lat_formatter)
    ax.tick_params(axis='both', which='major', labelsize=15)
    if parameters[-21:]=='Relative Humidity (%)':
        clevs=[50,55,60,65,70,75,80,85,90,95]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet_r', transform=crs_latlon, extend='both')
    elif parameters=='2-m Temperature ('+degree+')':
        clevs=[18,20,22,24,26,28,30,32,34,36]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='950 mb Temperature ('+degree+')':
        clevs=[13,15,17,19,21,23,25,27,29,31]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='900 mb Temperature ('+degree+')':
        clevs=[13,15,17,19,21,23,25,27,29,31]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='850 mb Temperature ('+degree+')':
        clevs=[14,15,16,17,18,19,20,21,22,23]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='700 mb Temperature ('+degree+')':
        clevs=[8,8.5,9,9.5,10,10.5,11,11.5,12,12.5]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='500 mb Temperature ('+degree+')':
        clevs=[-9,-8,-7,-6,-5,-4,-3,-2,-1,0]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='200 mb Temperature ('+degree+')':
        clevs=[-55,-54,-53,-52,-51,-50,-49,-48,-47,-46]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters[-19:]=='Wind & isotach(m/s)':
        # clevs=[8,10,12,14,16,18,20,22,24]
        clevs=[8,12,16,18,20,30,40,50,60]
        ccols=['white','palegreen','lime','limegreen','forestgreen','orange','orangered','red','firebrick','darkred']
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    elif parameters[-25:]=='divergence ('+unit1+')':
        # clevs=[0,0.5,1,1.5,2,2.5,3,4,5]
        clevs=[0,2,4,6,8,10,15,20,25]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='OrRd', transform=crs_latlon, extend='both')
    elif parameters[-26:]=='convergence ('+unit1+')':
        # clevs=[-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,0]
        clevs=[-25,-20,-15,-10,-8,-6,-4,-2,0]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='Greens_r', transform=crs_latlon, extend='both')
    elif parameters[-33:]=='relative vorticity ('+unit1+')':
        clevs=[-20,-15,-10,-5,-2,2,5,10,15,20]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='RdBu_r', transform=crs_latlon, extend='both')
    elif parameters=='10-m Wind(vector, m/s), 24hr Prec(shaded, mm), MSLP (contour, mb)':
        clevs=[0.5, 1, 5, 10, 15, 20, 40, 50, 65, 80, 100, 150]
        ccols=['#BEBEBE','#E8E8E7','#BDF2BA','#88F487','#68F422','#A4EE1B','#F2F220','#EFD216','#EBA91C','#ED8E1D','#EA661F','#EE251E','#E719B5'] 
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    else:
        clevs=[0.5, 1, 2, 3, 5, 10, 15, 20, 25, 30, 40, 50]
        ccols=['#BEBEBE','#E8E8E7','#BDF2BA','#88F487','#68F422','#A4EE1B','#F2F220','#EFD216','#EBA91C','#ED8E1D','#EA661F','#EE251E','#E719B5'] 
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    if np.logical_and(np.logical_and(data2!='none',data3=='none'),data4=='none').all()==True:
        ct=ax.contour(lons, lats, data2,colors='slategrey',linewidths=.9, transform=crs_latlon)   
        pl.gca().clabel(ct, inline=1, fontsize=8,fmt='%1.0i')
    elif np.logical_and(np.logical_and(data2!='none',data3!='none'),data4=='none').all()==True:
        new_x, new_y, new_u, new_v, = vector_scalar_to_grid(crs_latlon,crs_latlon,15,lons,lats,data2,data3)
        if parameters.find('vector')==-1:
            # Axes.streamplot(ax,new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
            ax.streamplot(new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
        else:
            Q=ax.quiver(new_x,new_y,new_u,new_v, transform=ccrs.PlateCarree(), regrid_shape=20, color='grey') 
            qk = pl.quiverkey(Q, 0.1, 0.1, 10, r'10 m/s', labelpos='E', coordinates='figure')
    elif data4!='none':
        ct=ax.contour(lons, lats, data4,colors='slategrey',linewidths=.9, transform=crs_latlon)      
        pl.gca().clabel(ct, inline=1, fontsize=8,fmt='%1.0i')
        new_x, new_y, new_u, new_v, = vector_scalar_to_grid(crs_latlon,crs_latlon,15,lons,lats,data2,data3)
        if parameters.find('vector')==-1:
            # Axes.streamplot(ax,new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
            ax.streamplot(new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
        else:
            Q=ax.quiver(new_x,new_y,new_u,new_v, transform=ccrs.PlateCarree(), regrid_shape=20, color='grey') 
            qk = pl.quiverkey(Q, 0.1, 0.1, 10, r'10 m/s', labelpos='E', coordinates='figure')
            # qk = pl.quiverkey(Q, 0.1, 0.1, 10, r'0 \frac{m}{s}$', labelpos='E', coordinates='figure')
    fname = '/scratch/bmkg_4/WRF/INPUT/shp/INDONESIA_PROP1.shp'
    ax.add_geometries(Reader(fname).geometries(),
                      crs_latlon,facecolor = (1, 1, 1, 0), 
                                   edgecolor = (0.1, 0.1, 0.1, 1),linewidth=0.35)
    #ax.add_feature(cfeature.BORDERS,linewidth=0.35)
    #ax.add_feature(cfeature.COASTLINE,linewidth=0.35)
    # ax.outline_patch.set_linewidth(0.35)
    cb=fig.colorbar(cs,ticks=clevs,orientation='horizontal',cax=fig.add_axes([0.07,0.045,0.9,0.03]))
    cb.ax.tick_params(labelsize=15) 
    plane = np.array(Image.open('/scratch/bmkg_4/WRF/INPUT/shp/Logo-BMKG-new.png'))
    ax = pl.axes([0.06,0.2, 0.06, 0.06], frameon=True)  
    ax.imshow(plane)
    ax.axis('off') 
    pl.gcf().text(0.06, 0.96, parameters, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.06, 0.91, 'Forecast: '+pred+' (T+'+step+')', rotation='horizontal',fontsize=15)
    pl.gcf().text(0.80, 0.86, ver, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.06, 0.86, '$\it{Initial :}$ '+init, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.58, 0.1, '@ $\it{Center}$ $\it{for}$ $\it{Research}$ $\it{and}$ $\it{Development}$ $\it{BMKG}$', rotation='horizontal',fontsize=12)
    # fig.tight_layout()
    fig.subplots_adjust(hspace=0,wspace=0,left=0.06,right=0.98,bottom=0.06,top=0.96)
    pl.savefig(path+fnam, format='png', dpi=90, bbox_inches='tight')
    pl.cla()
    pl.clf()
    pl.close()
def peta_jkt(lons,lats,bound,data1,data2,data3,data4,parameters,path,fnam,step,init,pred,ver):      
    import matplotlib.pyplot as pl     
    import cartopy.crs as ccrs
    import cartopy.feature as cfeature
    from cartopy.util import add_cyclic_point
    from cartopy.vector_transform import vector_scalar_to_grid
    from cartopy.io.shapereader import Reader
    from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter
    from matplotlib.axes import Axes
    from matplotlib.cm import get_cmap
    import matplotlib.pyplot as plt
    import matplotlib.ticker as mticker
    from mpl_toolkits.axes_grid1 import make_axes_locatable
    if not os.path.isdir(path):
        os.makedirs(path)
    degree='degC'
    unit1='per 100000 s'
    fig = pl.figure(figsize=(8.9,10))
    crs_latlon = ccrs.PlateCarree()
    ax = fig.add_subplot(1, 1, 1, projection=crs_latlon)
    ax.set_extent([bound[2],bound[3],bound[0],bound[1]], crs=crs_latlon)
    # ax.coastlines('50m')
    ax.grid(False)
    ax.set_xticks([106.3, 106.5, 106.7, 106.9, 107.1, 107.3], crs=crs_latlon)
    ax.set_yticks([-6.9, -6.7, -6.5, -6.3, -6.1, -5.9], crs=crs_latlon)
    lon_formatter = LongitudeFormatter(zero_direction_label=True)
    lat_formatter = LatitudeFormatter()
    ax.xaxis.set_major_formatter(lon_formatter)
    ax.yaxis.set_major_formatter(lat_formatter)
    ax.tick_params(axis='both', which='major', labelsize=15)
    if parameters[-21:]=='Relative Humidity (%)':
        clevs=[50,55,60,65,70,75,80,85,90,95]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet_r', transform=crs_latlon, extend='both')
    elif parameters=='2-m Temperature ('+degree+')':
        clevs=[18,20,22,24,26,28,30,32,34,36]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='950 mb Temperature ('+degree+')':
        clevs=[13,15,17,19,21,23,25,27,29,31]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='900 mb Temperature ('+degree+')':
        clevs=[13,15,17,19,21,23,25,27,29,31]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='850 mb Temperature ('+degree+')':
        clevs=[14,15,16,17,18,19,20,21,22,23]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='700 mb Temperature ('+degree+')':
        clevs=[8,8.5,9,9.5,10,10.5,11,11.5,12,12.5]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='500 mb Temperature ('+degree+')':
        clevs=[-9,-8,-7,-6,-5,-4,-3,-2,-1,0]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='200 mb Temperature ('+degree+')':
        clevs=[-55,-54,-53,-52,-51,-50,-49,-48,-47,-46]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters[-19:]=='Wind & isotach(m/s)':
        # clevs=[8,10,12,14,16,18,20,22,24]
        clevs=[8,12,16,18,20,30,40,50,60]
        ccols=['white','palegreen','lime','limegreen','forestgreen','orange','orangered','red','firebrick','darkred']
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    elif parameters[-25:]=='divergence ('+unit1+')':
        # clevs=[0,0.5,1,1.5,2,2.5,3,4,5]
        clevs=[0,2,4,6,8,10,15,20,25]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='OrRd', transform=crs_latlon, extend='both')
    elif parameters[-26:]=='convergence ('+unit1+')':
        # clevs=[-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,0]
        clevs=[-25,-20,-15,-10,-8,-6,-4,-2,0]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='Greens_r', transform=crs_latlon, extend='both')
    elif parameters[-33:]=='relative vorticity ('+unit1+')':
        clevs=[-20,-15,-10,-5,-2,2,5,10,15,20]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='RdBu_r', transform=crs_latlon, extend='both')
    elif parameters=='10-m Wind(vector, m/s), 24hr Prec(shaded, mm), MSLP (contour, mb)':
        clevs=[0.5, 1, 5, 10, 15, 20, 40, 50, 65, 80, 100, 150]
        ccols=['#BEBEBE','#E8E8E7','#BDF2BA','#88F487','#68F422','#A4EE1B','#F2F220','#EFD216','#EBA91C','#ED8E1D','#EA661F','#EE251E','#E719B5'] 
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    else:
        clevs=[0.5, 1, 2, 3, 5, 10, 15, 20, 25, 30, 40, 50]
        ccols=['#BEBEBE','#E8E8E7','#BDF2BA','#88F487','#68F422','#A4EE1B','#F2F220','#EFD216','#EBA91C','#ED8E1D','#EA661F','#EE251E','#E719B5'] 
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    if np.logical_and(np.logical_and(data2!='none',data3=='none'),data4=='none').all()==True:
        ct=ax.contour(lons, lats, data2,colors='slategrey',linewidths=.9, transform=crs_latlon)   
        pl.gca().clabel(ct, inline=1, fontsize=8,fmt='%1.0i')
    elif np.logical_and(np.logical_and(data2!='none',data3!='none'),data4=='none').all()==True:
        new_x, new_y, new_u, new_v, = vector_scalar_to_grid(crs_latlon,crs_latlon,15,lons,lats,data2,data3)
        if parameters.find('vector')==-1:
            # Axes.streamplot(ax,new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
            ax.streamplot(new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
        else:
            Q=ax.quiver(new_x,new_y,new_u,new_v, transform=ccrs.PlateCarree(), regrid_shape=20, color='grey',width=0.006, scale=60) 
            qk = pl.quiverkey(Q, 0.92, 0.92, 5, r'5 m/s', labelpos='E', coordinates='figure')
    elif data4!='none':
        ct=ax.contour(lons, lats, data4,colors='slategrey',linewidths=.9, transform=crs_latlon)     
        pl.gca().clabel(ct, inline=1, fontsize=8,fmt='%1.0i')
        new_x, new_y, new_u, new_v, = vector_scalar_to_grid(crs_latlon,crs_latlon,15,lons,lats,data2,data3)
        if parameters.find('vector')==-1:
            # Axes.streamplot(ax,new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
            ax.streamplot(new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
        else:
            Q=ax.quiver(new_x,new_y,new_u,new_v, transform=ccrs.PlateCarree(), regrid_shape=20, color='grey',width=0.006, scale=60) 
            qk = pl.quiverkey(Q, 0.92, 0.92, 5, r'5 m/s', labelpos='E', coordinates='figure')
            # qk = pl.quiverkey(Q, 0.1, 0.1, 10, r'0 \frac{m}{s}$', labelpos='E', coordinates='figure')
    fname = '/scratch/bmkg_4/WRF/INPUT/shp/Indo_Kab_Kot1.shp'
    ax.add_geometries(Reader(fname).geometries(),
                      crs_latlon,facecolor = (1, 1, 1, 0), 
                                   edgecolor = (0.1, 0.1, 0.1, 1),linewidth=0.35)
    # ax.add_feature(cfeature.BORDERS,linewidth=0.35)
    # ax.add_feature(cfeature.COASTLINE,linewidth=0.35)
    # ax.outline_patch.set_linewidth(0.35)
    cb=fig.colorbar(cs,ticks=clevs,orientation='vertical',cax=fig.add_axes([0.93,0.1,0.03,0.79]))
    cb.ax.tick_params(labelsize=15) 
    plane = np.array(Image.open('/scratch/bmkg_4/WRF/INPUT/shp/Logo-BMKG-new.png'))
    ax = pl.axes([0.10,0.12, 0.06, 0.06], frameon=True)  
    ax.imshow(plane)
    ax.axis('off') 
    pl.gcf().text(0.07, 0.97, parameters, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.07, 0.94, 'Forecast: '+pred+' (T+'+step+')', rotation='horizontal',fontsize=15)
    pl.gcf().text(0.65, 0.91, ver, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.07, 0.91, '$\it{Initial :}$ '+init, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.44, 0.05, '@ $\it{Center}$ $\it{for}$ $\it{Research}$ $\it{and}$ $\it{Development}$ $\it{BMKG}$', rotation='horizontal',fontsize=12)
    # fig.tight_layout()
    fig.subplots_adjust(hspace=0,wspace=0,left=0.08,right=0.9,bottom=0.1,top=0.9)
    pl.savefig(path+fnam, format='png', dpi=90, bbox_inches='tight')
    pl.cla()
    pl.clf()
    pl.close()

def peta_bali(lons,lats,bound,data1,data2,data3,data4,parameters,path,fnam,step,init,pred,ver):      
    import matplotlib.pyplot as pl     
    import cartopy.crs as ccrs
    import cartopy.feature as cfeature
    from cartopy.util import add_cyclic_point
    from cartopy.vector_transform import vector_scalar_to_grid
    from cartopy.io.shapereader import Reader
    from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter
    from matplotlib.axes import Axes
    from matplotlib.cm import get_cmap
    import matplotlib.pyplot as plt
    import matplotlib.ticker as mticker
    from mpl_toolkits.axes_grid1 import make_axes_locatable
    if not os.path.isdir(path):
        os.makedirs(path)
    degree='degC'
    unit1='per 100000 s'
    fig = pl.figure(figsize=(8.9,10))
    crs_latlon = ccrs.PlateCarree()
    ax = fig.add_subplot(1, 1, 1, projection=crs_latlon)
    ax.set_extent([bound[2],bound[3],bound[0],bound[1]], crs=crs_latlon)
    # ax.coastlines('50m')
    ax.grid(False)
    ax.set_xticks([119., 120, 121.], crs=crs_latlon)
    ax.set_yticks([-9.5, -9., -8.5, -8.], crs=crs_latlon)
    lon_formatter = LongitudeFormatter(zero_direction_label=True)
    lat_formatter = LatitudeFormatter()
    ax.xaxis.set_major_formatter(lon_formatter)
    ax.yaxis.set_major_formatter(lat_formatter)
    ax.tick_params(axis='both', which='major', labelsize=15)
    if parameters[-21:]=='Relative Humidity (%)':
        clevs=[50,55,60,65,70,75,80,85,90,95]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet_r', transform=crs_latlon, extend='both')
    elif parameters=='2-m Temperature ('+degree+')':
        clevs=[18,20,22,24,26,28,30,32,34,36]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='950 mb Temperature ('+degree+')':
        clevs=[13,15,17,19,21,23,25,27,29,31]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='900 mb Temperature ('+degree+')':
        clevs=[13,15,17,19,21,23,25,27,29,31]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='850 mb Temperature ('+degree+')':
        clevs=[14,15,16,17,18,19,20,21,22,23]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='700 mb Temperature ('+degree+')':
        clevs=[8,8.5,9,9.5,10,10.5,11,11.5,12,12.5]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='500 mb Temperature ('+degree+')':
        clevs=[-9,-8,-7,-6,-5,-4,-3,-2,-1,0]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters=='200 mb Temperature ('+degree+')':
        clevs=[-55,-54,-53,-52,-51,-50,-49,-48,-47,-46]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='jet', transform=crs_latlon, extend='both')
    elif parameters[-19:]=='Wind & isotach(m/s)':
        # clevs=[8,10,12,14,16,18,20,22,24]
        clevs=[8,12,16,18,20,30,40,50,60]
        ccols=['white','palegreen','lime','limegreen','forestgreen','orange','orangered','red','firebrick','darkred']
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    elif parameters[-25:]=='divergence ('+unit1+')':
        # clevs=[0,0.5,1,1.5,2,2.5,3,4,5]
        clevs=[0,2,4,6,8,10,15,20,25]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='OrRd', transform=crs_latlon, extend='both')
    elif parameters[-26:]=='convergence ('+unit1+')':
        # clevs=[-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,0]
        clevs=[-25,-20,-15,-10,-8,-6,-4,-2,0]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='Greens_r', transform=crs_latlon, extend='both')
    elif parameters[-33:]=='relative vorticity ('+unit1+')':
        clevs=[-20,-15,-10,-5,-2,2,5,10,15,20]
        cs=ax.contourf(lons, lats, data1, clevs,cmap='RdBu_r', transform=crs_latlon, extend='both')
    elif parameters=='10-m Wind(vector, m/s), 24hr Prec(shaded, mm), MSLP (contour, mb)':
        clevs=[0.5, 1, 5, 10, 15, 20, 40, 50, 65, 80, 100, 150]
        ccols=['#BEBEBE','#E8E8E7','#BDF2BA','#88F487','#68F422','#A4EE1B','#F2F220','#EFD216','#EBA91C','#ED8E1D','#EA661F','#EE251E','#E719B5'] 
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    else:
        clevs=[0.5, 1, 2, 3, 5, 10, 15, 20, 25, 30, 40, 50]
        ccols=['#BEBEBE','#E8E8E7','#BDF2BA','#88F487','#68F422','#A4EE1B','#F2F220','#EFD216','#EBA91C','#ED8E1D','#EA661F','#EE251E','#E719B5'] 
        cs=ax.contourf(lons, lats, data1, clevs,colors=ccols, transform=crs_latlon, extend='both')
    if np.logical_and(np.logical_and(data2!='none',data3=='none'),data4=='none').all()==True:
        ct=ax.contour(lons, lats, data2,colors='slategrey',linewidths=.9, transform=crs_latlon)   
        pl.gca().clabel(ct, inline=1, fontsize=8,fmt='%1.0i')
    elif np.logical_and(np.logical_and(data2!='none',data3!='none'),data4=='none').all()==True:
        new_x, new_y, new_u, new_v, = vector_scalar_to_grid(crs_latlon,crs_latlon,15,lons,lats,data2,data3)
        if parameters.find('vector')==-1:
            Axes.streamplot(ax,new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
        else:
            Q=ax.quiver(new_x,new_y,new_u,new_v, transform=ccrs.PlateCarree(), regrid_shape=20, color='grey',width=0.006, scale=60) 
            qk = pl.quiverkey(Q, 0.92, 0.92, 5, r'5 m/s', labelpos='E', coordinates='figure')
    elif data4!='none':
        ct=ax.contour(lons, lats, data4,colors='slategrey',linewidths=.9, transform=crs_latlon)     
        pl.gca().clabel(ct, inline=1, fontsize=8,fmt='%1.0i')
        new_x, new_y, new_u, new_v, = vector_scalar_to_grid(crs_latlon,crs_latlon,15,lons,lats,data2,data3)
        if parameters.find('vector')==-1:
            Axes.streamplot(ax,new_x,new_y,new_u,new_v, density=(3,3), linewidth =1, color='grey',transform=crs_latlon)
        else:
            Q=ax.quiver(new_x,new_y,new_u,new_v, transform=ccrs.PlateCarree(), regrid_shape=20, color='grey',width=0.006, scale=60) 
            qk = pl.quiverkey(Q, 0.92, 0.92, 5, r'5 m/s', labelpos='E', coordinates='figure')
            # qk = pl.quiverkey(Q, 0.1, 0.1, 10, r'0 \frac{m}{s}$', labelpos='E', coordinates='figure')
    fname = '/scratch/bmkg_4/WRF/INPUT/shp/Indo_Kab_Kot1.shp'
    ax.add_geometries(Reader(fname).geometries(),
                      crs_latlon,facecolor = (1, 1, 1, 0), 
                                   edgecolor = (0.1, 0.1, 0.1, 1),linewidth=0.35)
    # ax.add_feature(cfeature.BORDERS,linewidth=0.35)
    # ax.add_feature(cfeature.COASTLINE,linewidth=0.35)
    # ax.outline_patch.set_linewidth(0.35)
    cb=fig.colorbar(cs,ticks=clevs,orientation='vertical',cax=fig.add_axes([0.93,0.1,0.03,0.79]))
    cb.ax.tick_params(labelsize=15) 
    plane = np.array(Image.open('/scratch/bmkg_4/WRF/INPUT/shp/Logo-BMKG-new.png'))
    ax = pl.axes([0.10,0.15, 0.06, 0.06], frameon=True)  
    ax.imshow(plane)
    ax.axis('off') 
    pl.gcf().text(0.07, 0.97, parameters, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.07, 0.94, 'Forecast: '+pred+' (T+'+step+')', rotation='horizontal',fontsize=15)
    pl.gcf().text(0.65, 0.91, ver, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.07, 0.91, '$\it{Initial :}$ '+init, rotation='horizontal',fontsize=15)
    pl.gcf().text(0.44, 0.05, '@ $\it{Center}$ $\it{for}$ $\it{Research}$ $\it{and}$ $\it{Development}$ $\it{BMKG}$', rotation='horizontal',fontsize=12)
    # fig.tight_layout()
    fig.subplots_adjust(hspace=0,wspace=0,left=0.08,right=0.9,bottom=0.1,top=0.9)
    pl.savefig(path+fnam, format='png', dpi=90, bbox_inches='tight')
    pl.cla()
    pl.clf()
    pl.close()
	
def plot_meteogram(rr,tt,uu,vv,ws,lons,lats,ch,u10,v10,ws10m,t2,td2,rh2,clfl,clfm,clfh,slp,uu1,vv1,ws1,rh1,tm1,di1,vo1,pred1,init1,id,str_pos,str_lon,str_lat,path,fname,fnam,xxx):
    
    from matplotlib.colors import BoundaryNorm, ListedColormap
    import cartopy.crs as ccrs
    from geocat.viz import util as gvutil
    import geocat.viz as gv
    import pandas as pd
    if not os.path.isdir(path):
        os.makedirs(path)
    # # # url = "http://182.16.248.173:8080/dods/INA-NWP/"+xxx+"/"+xxx+"-d02-asim"
    # # #url = '/scratch/bmkg_4/WRF/OUTPUT/bajo/2023050912/wrfout_d02_2023-05-09_12:00:00'
    # # ds = Dataset(url)
# # #    print('Plotting meteogram for '+ str_pos + ' (lon = ' + str_lon + ', lat = ' + str_lat + ')' )

    # # ch=ds.variables['RAINC'][:]+ds.variables['RAINNC'][:]+ds.variables['RAINSH'][:]
    # # lons = to_np(getvar(ds, "lon"))[0,:]
    # # lats = to_np(getvar(ds, "lat"))[:,0]
    # # #levels = ds.variables['lev'][:]
    # # slp = to_np(getvar(ds, "slp", timeidx=ALL_TIMES, method="cat"))
    # # p = to_np(getvar(ds, "pressure", timeidx=ALL_TIMES, method="cat"))
    # # clfl = to_np(getvar(ds, "low_cloudfrac", timeidx=ALL_TIMES, method="cat"))
    # # clfm = to_np(getvar(ds, "mid_cloudfrac", timeidx=ALL_TIMES, method="cat"))
    # # clfh = to_np(getvar(ds, "high_cloudfrac", timeidx=ALL_TIMES, method="cat"))
    # # t2 = to_np(getvar(ds, "T2", timeidx=ALL_TIMES, method="cat"))-273.16
    # # td2 = to_np(getvar(ds, "td2", timeidx=ALL_TIMES, method="cat"))
    # # rh2 = to_np(getvar(ds, "rh2", timeidx=ALL_TIMES, method="cat"))
    # # tc = to_np(getvar(ds, "tc", timeidx=ALL_TIMES, method="cat"))
    # # rh = to_np(getvar(ds, "rh", timeidx=ALL_TIMES, method="cat"))
    # # ws10m = to_np(getvar(ds, "wspd_wdir10", units="m/s", timeidx=ALL_TIMES, method="cat"))[0,...]
    # # u10 = to_np(getvar(ds, "uvmet10", units="m/s", timeidx=ALL_TIMES, method="cat"))[0,...]
    # # v10 = to_np(getvar(ds, "uvmet10", units="m/s", timeidx=ALL_TIMES, method="cat"))[1,...]
    # # ua = to_np(getvar(ds, "uvmet", units="m/s", timeidx=ALL_TIMES, method="cat"))[0,...]
    # # va = to_np(getvar(ds, "uvmet", units="m/s", timeidx=ALL_TIMES, method="cat"))[1,...]
    # # str_times=[]
    # # for i in range(73):
        # # wkt = str(extract_times(ds,i))[:13]
        # # str_times.append(datetime.datetime(int(wkt[:4]),int(wkt[5:7]),int(wkt[8:10]),int(wkt[11:])).replace(tzinfo=pytz.utc).astimezone(pytz.timezone('Asia/Jakarta')).strftime('%HWIB %d %b %Y'))
#    print(ua.shape)
#    str_times = []
#    idx_times = range(len(times))
#    for i in idx_times:
#        wkt = str(times[i])
#        local_wkt = datetime.datetime(int(wkt[:4]),int(wkt[5:7]),int(wkt[8:10]),int(wkt[11:13]),int(wkt[14:16]),int(wkt[17:19])).replace(tzinfo=pytz.utc).astimezone(pytz.timezone('Asia/Jakarta')).strftime('%HWIB %d %b %Y')
#        str_times.append(local_wkt)
    if (id==1):
        model = '9km InaNWPv0.8'
    elif(id==2):
        model = '3km InaNWPv1.0'
    elif(id==3):
        model = '1km InaNWPv1.2'

    # # set maintitle

    # # Extract variables from the data
    # uu=[];vv=[];rr=[];tt=[]
    lv = [1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.]
    levels = np.array(lv)
    # for i in range(len(lv)):
        # u = interplevel(ua, p, lv[i])
        # v = interplevel(va, p, lv[i])
        # r = interplevel(rh, p, lv[i])
        # t = interplevel(tc, p, lv[i])
        # uu.append(u);vv.append(v);rr.append(r);tt.append(t)
    # tt=np.array(tt);rr=np.array(rr);uu=np.array(uu);vv=np.array(vv)
	
    # ijj='bajo3'
    # yyy='Bajo(3km)'
    # ver='3km InaNWPv1.2'
    # bound=[-9.5,-8.,119.,121.]
    # # if xxx[-2:]=='00':
        # # np1=23
    # # else:
        # # np1=35
    # # # xxx=init
    # # # ii=0
    # # m1,m2,m3=ch.shape
    # # for i in range(np1,m1,24):
        # # pred=str_times[i-23]+' - '+str_times[i+1]
        # # ch1=ch[i+1,...]-ch[i-23]
        # # # if i==np and xxx[-2:]=='00':
            # # # pred=str_times[0]+' - '+str_times[i+1]
        # # # else:
            # # # pred=str_times[i-23]+' - '+str_times[i+1]
        # # step=str((i+1)*1)
        # # if int(step)<10:
            # # fnam1=xxx+'(0'+step+').png'
        # # else:
            # # fnam1=xxx+'('+step+').png'
        # # fname1=ijj+'24h-prec_'+fnam1
        # # parameters='10-m Wind(vector, m/s), 24hr Prec(shaded, mm), MSLP (contour, mb)'
        # # pathn='/scratch/bmkg_4/WRF/PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/Surface/24hr-Prec-mslp-wind/'
        # # peta_jawa(lons,lats,bound,ch1,u10[i,...],v10[i,...],slp[i,...],parameters,pathn,fname1,step,str_times[0],pred,ver)

    for i in range(len(str_pos)):
        print('Plotting meteogram for '+ str_pos[i] + ' (lon = ' + str_lon[i] + ', lat = ' + str_lat[i] + ')' )
        area_name = str_pos[i]
        lat = round(float(str_lat[i]), 3)
        lon = round(float(str_lon[i]), 3)
        str_title = area_name + '\n 0~3day hourly Forecast Meteogram for (' + str(lon) + '; ' + str(lat) + ') by ' + model + '\n@ Center for Research and Development BMKG'   
        idxlat = np.where(np.abs(lats-lat) == np.nanmin(np.abs(lats-lat)))[0][0]
        idxlon = np.where(np.abs(lons-lon) == np.nanmin(np.abs(lons-lon)))[0][0]
        tempisobar = tt[:,:,idxlat,idxlon];tempisobar=tempisobar.T
        rh = rr[:,:,idxlat,idxlon]#;rh=rh.T
        ugrid = uu[:,:,idxlat,idxlon]#;ugrid=ugrid.T
        vgrid = vv[:,:,idxlat,idxlon]#;vgrid=vgrid.T
#    print(t2.shape)
        mslp = slp[:,idxlat,idxlon]
        tempht = t2[:,idxlat,idxlon]
        dewtempht = td2[:,idxlat,idxlon]
        rhht = rh2[:,idxlat,idxlon]
        ws10 = ws10m[:,idxlat,idxlon]
        u10m = u10[:,idxlat,idxlon]
        v10m = v10[:,idxlat,idxlon]
 #   rainc = ds.variables['rainc'][:,0,idxlat,idxlon]
 #   rainsh = ds.variables['rainsh'][:,0,idxlat,idxlon]
 #   rainnc = ds.variables['rainnc'][:,0,idxlat,idxlon]
        rain03 = ch[1:,idxlat,idxlon] - ch[:-1,idxlat,idxlon] 
        rain03 = np.ma.append(0, rain03)
        clflo = clfl[:,idxlat,idxlon]
        clfmi = clfm[:,idxlat,idxlon]
        clfhi = clfh[:,idxlat,idxlon]

        idx_times = range(len(pred1))
        taus = idx_times

    ###############################################################################
    # Plot:

    # Generate figure (set its size (width, height) in inches)
    # fig = plt.figure(figsize=(15, 20))
        fig = pl.figure(figsize=(8, 14))
        spec = fig.add_gridspec(ncols=1, nrows=7, height_ratios=[4, 1, 1, 1, 1, 1, 1], hspace=0.1)

    # Create axis for contour/wind barb plot
        ax1 = fig.add_subplot(spec[0, 0], projection=ccrs.PlateCarree())

    # Add coastlines to first axis
        ax1.coastlines(linewidths=0.5)

    # Set aspect ratio of the first axis
        ax1.set_aspect('auto')

    # Create a color map with a combination of matplotlib colors and hex values
        colors = ListedColormap(
            np.array([
                'white', 'white', 'white', 'mintcream', "#DAF6D3",
                "#DAF6D3", "#B2FAB9", 'springgreen', 'lime', "#54A63F"
            ]))
		# colors1 = ListedColormap(
			# np.array([
				# 'white', 'white', 'white', 'white', 'white', 'mintcream', "#DAF6D3",
				# "#B2FAB9", "#B2FAB9", 'springgreen', 'lime', "#54A63F"
			# ]))
        contour_levels = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
		# contour_levels1 = [-20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        normalized_levels = BoundaryNorm(boundaries=contour_levels, ncolors=10)
		# normalized_levels1 = BoundaryNorm(boundaries=contour_levels1, ncolors=12)

        level_to_plot = 100
        idx_lvl = np.where(levels==level_to_plot)[0][0]

    # Plot filled contours for the rh variable
        contour1 = ax1.contourf(rh[:idx_lvl,:],
                                transform=ccrs.PlateCarree(),
                                cmap=colors,
                                norm=normalized_levels,
                                levels=contour_levels,
                                zorder=2)

    # Plot black outlines on top of the filled rh contours
        contour2 = ax1.contour(rh[:idx_lvl,:],
                               transform=ccrs.PlateCarree(),
                               colors='black',
                               levels=contour_levels,
                               linewidths=0.1,
                               zorder=3)

    # Plot contours for the tempisobar variable
        contour3 = ax1.contour(tempisobar[:idx_lvl,:],
                               transform=ccrs.PlateCarree(),
                               cmap=pl.get_cmap('gist_rainbow'), 
                               levels=np.append(np.arange(-80,-10,10), np.arange(-10,40,5)),
                               linewidths=0.7,
                               linestyles='solid', zorder=4)

        contour3.collections[9].set_linestyle('dashed')
        contour3.collections[9].set_linewidth(1)
        contour3.collections[9].set_color('black')
    # Manually plot contour labels
        cont2labels = ax1.clabel(contour2,
                             # manual=cont2Labels,
                             fmt='%d',
                             inline=True,
                             fontsize=7)
        cont3labels = ax1.clabel(contour3,
                             # manual=cont3Labels,
                             fmt='%d',
                             inline=True,
                             fontsize=7)
                             # colors='black')

    # Set contour label backgrounds white
        [
        txt.set_bbox(dict(facecolor='none', edgecolor='none', pad=.5))
        for txt in contour2.labelTexts
        ]
        [
        txt.set_bbox(dict(facecolor='none', edgecolor='none', pad=.5))
        for txt in contour3.labelTexts
        ]

    # Determine the labels for each tick on the x and y axes
        yticklabels = np.array(levels, dtype=np.int)
    # Make an axis to overlay on top of the contour plot
        axin = fig.add_subplot(spec[0, 0])

    # Use the geocat.viz function to set the main title of the plot
        gv.set_titles_and_labels(axin,
                                 maintitle=str_title,
                                 maintitlefontsize=16,
                                 ylabel='RH (shaded,%) Temp (line,\N{DEGREE SIGN}C) Wind (barbs, m/s)'
                                 '\n (millibars)',
                                 labelfontsize=12)

    # Add a pad between the y axis label and the axis spine
        axin.yaxis.labelpad = 3

    # Use the geocat.viz function to set axes limits and ticks
        gv.set_axes_limits_and_ticks(axin,
                                      xlim=[taus[0], taus[-1]],
                                      ylim=[levels[0], levels[idx_lvl]],
                                      xticks=np.array(taus),
                                      yticks=np.array(levels),
                                      xticklabels=[],
                                      yticklabels=yticklabels)

    # Make axis invisible
        axin.patch.set_alpha(0.0)

    # Make ticks point inwards
        axin.tick_params(axis="x", direction="out", length=5)
        axin.tick_params(axis="y", direction="out", length=5, labelsize=9)
        axin.tick_params(bottom=True, left=True, right=True, top=False)
    # Rotate the labels on the x axis so they are vertical
        for tick in axin.get_xticklabels():
            tick.set_rotation(90)

    # Set aspect ratio of axin so it lines up with axis underneath (ax1)
        axin.set_aspect('auto')

    # Plot wind barbs
        barbs = axin.barbs(idx_times,
                       levels[:idx_lvl],
                       ugrid[:idx_lvl,:],
                       vgrid[:idx_lvl,:],
                       color='black',
                       lw=0.3,
                       length=5)

    # Create two more axes, one for the bar chart and one for the line graph
        axin0 = fig.add_subplot(spec[1, 0])
        axin1 = fig.add_subplot(spec[2, 0])
        axin2 = fig.add_subplot(spec[3, 0])
        axin3 = fig.add_subplot(spec[4, 0])
        axin4 = fig.add_subplot(spec[5, 0])
        axin5 = fig.add_subplot(spec[6, 0])

    # Plot line chart

    # Plot lines depicting the wind10m variable
        axin0.plot(taus, ws10, color='orange', marker='o', markerfacecolor='white')
        axin0.grid(color = 'grey', linestyle = '--', linewidth = 0.2)
        Xq,Yq = np.meshgrid(taus, (np.nanmin(ws10)+np.nanmax(ws10))/2)
        axin0.barbs(Xq,Yq,u10m,v10m,color='black',lw=0.3,length=5)

    # Use the geocat.viz function to set the y axis label
        gv.set_titles_and_labels(axin0, ylabel='10m Wind \nSpeed & Barbs \n(m/s)', labelfontsize=12)

    # Determine the labels for each tick on the x and y axes
        w10m_levels = np.arange(np.nanmin(ws10),np.nanmax(ws10),5)

    # Use the geocat.viz function to set inset axes limits and ticks
        gv.set_axes_limits_and_ticks(axin0,
                                     xlim=[taus[0], taus[-1]],
                                     ylim=[w10m_levels[0], np.nanmax(ws10)],
                                     xticks=np.array(taus),
                                     # yticks=t2m_levels,
                                     xticklabels=[],
                                     # yticklabels=t2m_levels
                                     )
    # Use the geocat.viz function to add minor ticks
        gv.add_major_minor_ticks(axin0, y_minor_per_major=5, labelsize="small")

    # Make ticks only show up on bottom, right, and left of inset axis
        axin0.tick_params(bottom=True, left=True, right=True, top=False)
        axin0.tick_params(which='minor', top=False, bottom=False)

    # Rotate the labels on the x axis so they are vertical
        for tick in axin0.get_xticklabels():
            tick.set_rotation(90)
    # Plot mslp
        axin1.plot(taus, mslp, color='blue', marker='o', markerfacecolor='white')
        axin1.grid(color = 'grey', linestyle = '--', linewidth = 0.2)
        gv.set_titles_and_labels(axin1, ylabel='MSLP \n(mb)', labelfontsize=12)
        mslp_levels = np.arange(np.nanmin(mslp),np.nanmax(mslp),0.1)
        gv.set_axes_limits_and_ticks(axin1,
                                     xlim=[taus[0], taus[-1]],
                                     ylim=[np.nanmin(mslp), np.nanmax(mslp)],
                                     xticks=np.array(taus),
                                     xticklabels=[],
                                     )
        gv.add_major_minor_ticks(axin1, y_minor_per_major=5, labelsize="small")
        axin1.tick_params(bottom=True, left=True, right=True, top=False)
        axin1.tick_params(which='minor', top=False, bottom=False)

    # Plot lines depicting the tempht variable
        axin2.plot(taus, tempht, color='red')
        axin2.plot(taus, dewtempht, color='red', linestyle = '--')
        axin2.grid(color = 'grey', linestyle = '--', linewidth = 0.2)

    # Use the geocat.viz function to set the y axis label
        gv.set_titles_and_labels(axin2, ylabel='2m Temp \n2m DewPt \n(\N{DEGREE SIGN}C)', labelfontsize=12)

    # Determine the labels for each tick on the x and y axes
        t2m_levels = np.arange(np.nanmin(dewtempht),np.nanmax(tempht),0.1)

    # Use the geocat.viz function to set inset axes limits and ticks
        gv.set_axes_limits_and_ticks(axin2,
                                     xlim=[taus[0], taus[-1]],
                                     ylim=[np.nanmin(dewtempht), np.nanmax(tempht)],
                                     #ylim=[t2m_levels[0], t2m_levels[-1]],
                                     xticks=np.array(taus),
                                     # yticks=t2m_levels,
                                     xticklabels=[],
                                     # yticklabels=t2m_levels
                                     )

    # Use the geocat.viz function to add minor ticks
        gv.add_major_minor_ticks(axin2, y_minor_per_major=5, labelsize="small")

    # Make ticks only show up on bottom, right, and left of inset axis
        axin2.tick_params(bottom=True, left=True, right=True, top=False)
        axin2.tick_params(which='minor', top=False, bottom=False)

    # Plot lines depicting the rhht variable
        axin3.plot(taus, rhht, color='green', marker='o', markerfacecolor='white')
        axin3.grid(color = 'grey', linestyle = '--', linewidth = 0.2)

    # Use the geocat.viz function to set the y axis label
        gv.set_titles_and_labels(axin3, ylabel='2m RH \n(%)', labelfontsize=12)
    # Determine the labels for each tick on the x and y axes
        rh2m_levels = np.arange(np.nanmin(rhht),np.nanmax(rhht),10)

    # Use the geocat.viz function to set inset axes limits and ticks
        gv.set_axes_limits_and_ticks(axin3,
                                     xlim=[taus[0], taus[-1]],
                                     ylim=[np.nanmin(rhht), np.nanmax(rhht)],
                                     xticks=np.array(taus),
                                     # yticks=t2m_levels,
                                     xticklabels=[],
                                     # yticklabels=t2m_levels
                                     )

    # Use the geocat.viz function to add minor ticks
        gv.add_major_minor_ticks(axin3, y_minor_per_major=5, labelsize="small")

    # Make ticks only show up on bottom, right, and left of inset axis
        axin3.tick_params(bottom=True, left=True, right=True, top=False)
        axin3.tick_params(which='minor', top=False, bottom=False)
    # Plot bars depicting the cloud fraction variable
        barWidth = 0.15
        br1 = taus
        br2 = [x + barWidth for x in br1]
        br3 = [x + barWidth for x in br2]

    # Make the plot
        axin4.bar(br1, clflo*100, color ='darkblue', width = barWidth,
            edgecolor ='darkblue', label ='low')
        axin4.bar(br2, clfmi*100, color ='blue', width = barWidth,
            edgecolor ='blue', label ='middle')
        axin4.bar(br3, clfhi*100, color ='lightblue', width = barWidth,
            edgecolor ='lightblue', label ='high')

        axin4.grid(color = 'grey', linestyle = '--', linewidth = 0.2)
        axin4.legend(fontsize = 5, ncol = 3, loc = 'upper right')

    # Use the geocat.viz function to set the y axis label
        gv.set_titles_and_labels(axin4, ylabel='Cloud Cover \n(%)', labelfontsize=12)

    # Determine the labels for each tick on the x and y axes
        clf_levels = np.arange(0,101,20)
    # Use the geocat.viz function to set axes limits and ticks
        gv.set_axes_limits_and_ticks(axin4,
                                     xlim=[taus[0], taus[-1]],
                                     ylim=[0, 120],
                                     xticks=np.array(taus),
                                     yticks=clf_levels,
                                      xticklabels=[],
                                     # yticklabels=rain3h_levels
                                     )

    # Use the geocat.viz function to add minor ticks
        gv.add_major_minor_ticks(axin4, y_minor_per_major=5, labelsize="small")

    # Make ticks only show up on bottom, right, and left of inset axis
        axin4.tick_params(bottom=True, left=True, right=True, top=False)
        axin4.tick_params(which='minor', top=False, bottom=False)
    
    # Plot bars depicting the rain03 variable
        axin5.bar(taus,
              rain03,
              width=1.0,
              color='limegreen',
              edgecolor='black',
              linewidth=.2)
        axin5.bar(taus[0], np.nanmax(rain03),width=1,color='lightgrey',edgecolor='lightgrey',linewidth=.2)
        axin5.grid(color = 'grey', linestyle = '--', linewidth = 0.2)
    # Use the geocat.viz function to set the y axis label
        gv.set_titles_and_labels(axin5, ylabel='3hr rain total \n(mm)', labelfontsize=12)

    # Determine the labels for each tick on the x and y axes
        rain3h_levels = np.arange(0,np.nanmax(rain03), 0.1)
        if np.nanmax(rain03) < 0.1:
            ymax = 0.1
        else:
            ymax = rain3h_levels[-1]

        axin5.text(len(taus) - 17, 0.8*ymax, r'3-Day Total = ' + str(round(np.nansum(rain03), 3)))


    # Use the geocat.viz function to set axes limits and ticks
        gv.set_axes_limits_and_ticks(axin5,
                                     xlim=[taus[0], taus[-1]],
                                     ylim=[0, ymax],
                                     xticks=np.array(taus),#[np.arange(0,73,3).astype(int)],
                                     # yticks=rain3h_levels,
                                      xticklabels=np.array(pred1),#[np.arange(0,73,3)],
                                     # yticklabels=rain3h_levels
                                     )
    # Use the geocat.viz function to add minor ticks
        gv.add_major_minor_ticks(axin5, y_minor_per_major=10, labelsize="small")

    # Make ticks only show up on bottom, right, and left of inset axis
        axin5.tick_params(bottom=True, left=True, right=True, top=False)
        axin5.tick_params(which='minor', top=False, bottom=False)

    # Rotate the labels on the x axis so they are vertical
        for tick in axin5.get_xticklabels():
            tick.set_rotation(90)

    # Adjust space between the first and second axes on the plot
        pl.subplots_adjust(hspace=-0.1);print(path+fnam)
        fig.savefig(path+fname+str_pos[i]+fnam, format='png', dpi=100, bbox_inches='tight')
        pl.cla()
        contents = {'datetime':pred1,'mslp':mslp,'t2m':tempht,'td2m':dewtempht,'rh2':rhht,'ws10':ws10,'u10':u10m,'v10':v10m,'rain03':rain03,'clflo':clflo,'clfmi':clfmi,'clfhi':clfhi}
        df = pd.DataFrame(contents,columns=['datetime','mslp','t2m','td2m','rh2','ws10','u10','v10','rain03','clflo','clfmi','clfhi'])
        df.to_csv(path + '/meteogram_'+fname+str_pos[i]+fnam[:-4]+'.csv') 

def initpred(wk):
    pred=[]
    for i in wk:
        wkt=str(i)[:13]
        pred.append(datetime.datetime(int(wkt[:4]),int(wkt[5:7]),int(wkt[8:10]),int(wkt[11:])).replace(tzinfo=pytz.utc).astimezone(pytz.timezone('Asia/Jakarta')).strftime('%HWIB %d %b %Y'))
    return(pred)
        
def buka_file(fn):
	ds = Dataset(fn)
	ch=ds.variables['RAINC'][:]+ds.variables['RAINNC'][:]+ds.variables['RAINSH'][:]
	lons = to_np(getvar(ds, "lon"))[0,:]
	lats = to_np(getvar(ds, "lat"))[:,0]
	mslp = to_np(getvar(ds, "slp", timeidx=ALL_TIMES, method="cat"))
	p = to_np(getvar(ds, "pressure", timeidx=ALL_TIMES, method="cat"))
	clfl = to_np(getvar(ds, "low_cloudfrac", timeidx=ALL_TIMES, method="cat"))
	clfm = to_np(getvar(ds, "mid_cloudfrac", timeidx=ALL_TIMES, method="cat"))
	clfh = to_np(getvar(ds, "high_cloudfrac", timeidx=ALL_TIMES, method="cat"))
	t2 = to_np(getvar(ds, "T2", timeidx=ALL_TIMES, method="cat"))-273.16
	td2 = to_np(getvar(ds, "td2", timeidx=ALL_TIMES, method="cat"))
	rh2 = to_np(getvar(ds, "rh2", timeidx=ALL_TIMES, method="cat"))
	tc = to_np(getvar(ds, "tc", timeidx=ALL_TIMES, method="cat"))
	rh = to_np(getvar(ds, "rh", timeidx=ALL_TIMES, method="cat"))
	ws1 = to_np(getvar(ds, "wspd_wdir", units="m/s", timeidx=ALL_TIMES, method="cat"))[0,...]
	ws10m = to_np(getvar(ds, "wspd_wdir10", units="m/s", timeidx=ALL_TIMES, method="cat"))[0,...]
	u10 = to_np(getvar(ds, "uvmet10", units="m/s", timeidx=ALL_TIMES, method="cat"))[0,...]
	v10 = to_np(getvar(ds, "uvmet10", units="m/s", timeidx=ALL_TIMES, method="cat"))[1,...]
	ua = to_np(getvar(ds, "uvmet", units="m/s", timeidx=ALL_TIMES, method="cat"))[0,...]
	va = to_np(getvar(ds, "uvmet", units="m/s", timeidx=ALL_TIMES, method="cat"))[1,...]
	str_times=[]
	[d1,d2,d3,d4]=p.shape
	for i in range(d1):
		wkt = str(extract_times(ds,i))[:13]
		str_times.append(datetime.datetime(int(wkt[:4]),int(wkt[5:7]),int(wkt[8:10]),int(wkt[11:])).replace(tzinfo=pytz.utc).astimezone(pytz.timezone('Asia/Jakarta')).strftime('%HWIB %d %b %Y'))

	uu=[];vv=[];rr=[];tt=[];ws=[]
	lv = [1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.]
	levels = np.array(lv)
	# for i in range(d1):
		# ws.append(vinterp(ds,field=ws1[i,...],vert_coord="eth",
				   # interp_levels=lv,extrapolate=True,timeidx=i,log_p=True))
		# uu.append(vinterp(ds,field=ua[i,...],vert_coord="eth",
				   # interp_levels=lv,extrapolate=True,timeidx=i,log_p=True))
		# vv.append(vinterp(ds,field=va[i,...],vert_coord="eth",
				   # interp_levels=lv,extrapolate=True,timeidx=i,log_p=True))
		# rr.append(vinterp(ds,field=rh[i,...],vert_coord="eth",
				   # interp_levels=lv,extrapolate=True,timeidx=i,log_p=True))
		# tt.append(vinterp(ds,field=tc[i,...],vert_coord="eth",
				   # interp_levels=lv,extrapolate=True,field_type="tc",timeidx=i,log_p=True))
	#	for i in range(len(lv)):
	wsm = interplevel(ws1, p, lv)
	uum = interplevel(ua, p, lv)
	vvm = interplevel(va, p, lv)
	rrm = interplevel(rh, p, lv)
	ttm = interplevel(tc, p, lv)
	#		ws.append(w);uu.append(u);vv.append(v);rr.append(r);tt.append(t)
	#	wsm=np.array(ws);ttm=np.array(tt);rrm=np.array(rr);uum=np.array(uu);vvm=np.array(vv)
	#	wsm=np.rollaxis(wsm,0,1);uum=np.rollaxis(uum,0,1);vvm=np.rollaxis(vvm,0,1);ttm=np.rollaxis(ttm,0,1)
	#	wsm=wsm[:,::-1,...];ttm=ttm[:,::-1,...];rrm=rrm[:,::-1,...];rrm=rrm[:,::-1,...];rrm=rrm[:,::-1,...];
	# dset = open_CtlDataset(fn)
	# lats =dset['XLAT'].values[0,-1,...]
	# lons =dset['XLONG'].values[0,-1,...] 
	# ch = dset['RAINC'].values[1:,-1,...]+dset['RAINNC'].values[1:,-1,...]-dset['RAINC'].values[:-1,-1,...]-dset['RAINNC'].values[:-1,-1,...]
	# mslp = dset['slp'].values[:,-1,...]
	# u = dset['umet'].values[:]
	# v = dset['vmet'].values[:]
	# ws = dset['wspd'].values[:]
	# tc = dset['tc'].values[:]
	# u10 = dset['u10m'].values[:,-1,...]
	# v10 = dset['v10m'].values[:,-1,...]
	# ws10 = dset['ws10'].values[:,-1,...]
	# rh = dset['rh'].values[:]
	# t2 = dset['T2'].values[:]-273.16
	# wk = dset['time'].values[:]
	pred=str_times
	init=pred[0]
	lv=[0, 1, 2, 3, 6, 10, 16]
	div=[];vort=[];uu=[];vv=[];ww=[];rr=[];tt=[]
	for i in range(len(lv)):
		dX = np.array(np.gradient(lons))*111139. 
		dY = np.array(np.gradient(lats))*111139.
		dV = np.array(np.gradient(vvm[:,lv[i],...]))
		Vgradient =  dV[2]/dX[1];Vgrad = dV[2]/dY[0]
		dU = np.array(np.gradient(uum[:,lv[i],...]))
		Ugradient =  dU[2]/dY[0];Ugrad = dU[2]/dX[1]
		div.append((Ugradient + Vgradient)*100000)
		vort.append((Vgradient - Ugradient)*100000)
		uu.append(uum[:,lv[i],...])
		vv.append(vvm[:,lv[i],...])
		ww.append(wsm[:,lv[i],...])
		tt.append(ttm[:,lv[i],...])
		rr.append(rrm[:,lv[i],...])
	div=np.array(div);vort=np.array(vort);uu=np.array(uu);vv=np.array(vv);ww=np.array(ww);rr=np.array(rr);tt=np.array(tt)
	return(rrm,ttm,uum,vvm,wsm,lons,lats,ch,u10,v10,ws10m,t2,td2,rh2,clfl,clfm,clfh,mslp,uu,vv,ww,rr,tt,div,vort,pred,init)

def plot_ch(lons,lats,ch1,u11,v11,mp1,pil,init,pred1,xxx,path):    
	if pil==1:
		ijj='indo9'
		yyy='Indonesia(9km)'
		ver='9km InaNWPv0.8'
		bound=[-13.,7.,94.,142.5]
	elif pil==2:
		ijj='jawa3'
		yyy='Jawa(3km)'
		ver='3km InaNWPv1.0'
		bound=[-9.5,-4.,102.,116.]
		# bound=[-11.3,-5.,109.,122.]
	elif pil==3:
		ijj='jkt1'
		yyy='Jabodetabek(1km)'
		ver='1km InaNWPv1.2'
		bound=[-7.,-5.7,106.2,107.4]
	elif pil==4:
		ijj='bali3'
		yyy='Bali(3km)'
		ver='3km InaNWPv1.0'
		bound=[-9.5,-7.5,114.,116.]
	elif pil==5:
		ijj='bajo3'
		yyy='Bajo(3km)'
		ver='3km InaNWPv1.2'
		bound=[-9.5,-8.,119.,121.]
	if xxx[-2:]=='00':
		if pil==3:
			np=23
			npp=24
		else:
			np=7
			npp=8
	else:
		if pil==3:
			np=35
			npp=24
		else:
			np=11
			npp=8
	# xxx=init
	# ii=0
	m1,m2,m3=ch1.shape
	for i in range(np,m1-1,npp):
		if i==np and xxx[-2:]=='00':
			pred=init+' - '+pred1[i+1]
		else:
			pred=pred1[i-npp+1]+' - '+pred1[i+1]
		if pil==3:
			step=str((i+1))
		else:
			step=str((i+1)*3)
		if int(step)<10:
			fnam=xxx+'(0'+step+').png'
		else:
			fnam=xxx+'('+step+').png'
		fname=ijj+'24h-prec_'+fnam
		parameters='10-m Wind(vector, m/s), 24hr Prec(shaded, mm), MSLP (contour, mb)'
		pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/Surface/24hr-Prec-mslp-wind/'
		if pil==1:
			peta_indo(lons,lats,bound,ch1[i+1,...]-ch1[i-npp+1,...],u11[i,...],v11[i,...],mp1[i,...],parameters,pathn,fname,step,init,pred,ver)
		elif pil==2:
			peta_jawa(lons,lats,bound,ch1[i+1,...]-ch1[i-npp+1,...],u11[i,...],v11[i,...],mp1[i,...],parameters,pathn,fname,step,init,pred,ver)
		elif pil==3:
			peta_jkt(lons,lats,bound,ch1[i+1,...]-ch1[i-npp+1,...],u11[i,...],v11[i,...],mp1[i,...],parameters,pathn,fname,step,init,pred,ver)
		elif pil==5:
			peta_bali(lons,lats,bound,ch1[i+1,...]-ch1[i-npp+1,...],u11[i,...],v11[i,...],mp1[i,...],parameters,pathn,fname,step,init,pred,ver)
        # ii=ii+8
def plot_all(lons,lats,ch,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,pil,init,pred1,xxx,i,path):    
	if pil==1:
		ijj='indo9'
		yyy='Indonesia(9km)'
		ver='9km InaNWPv0.8'
		bound=[-13.,7.,94.,142.5]
	elif pil==2:
		ijj='jawa3'
		yyy='Jawa(3km)'
		ver='3km InaNWPv1.0'
		bound=[-9.5,-4.,102.,116.]
		# bound=[-11.3,-5.,109.,122.]
	elif pil==3:
		ijj='jkt1'
		yyy='Jabodetabek(1km)'
		ver='1km InaNWPv1.2'
		bound=[-7.,-5.7,106.2,107.4]
	elif pil==4:
		ijj='bali3'
		yyy='Bali(3km)'
		ver='3km InaNWPv1.0'
		bound=[-9.5,-7.5,114.,116.]
	ch1=ch[1:,...]-ch[:-1,...]
	pred=pred1[i+1]
	if pil==3:
		step=str((i+1))
	else:
		step=str((i+1)*3)
	if int(step)<10:
		fnam=xxx+'(0'+step+').png'
	else:
		fnam=xxx+'('+step+').png'
	fname=ijj+'km_wind10m-prec_'+fnam
	parameters='10-m Wind(vector, m/s), Prec(shaded, mm)'
	pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/Surface/wind10m-Precipitation/'
	if pil==1:
		peta_indo(lons,lats,bound,ch1[i,...],u11[i+1,...],v11[i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
	elif pil==2:
		peta_jawa(lons,lats,bound,ch1[i,...],u11[i+1,...],v11[i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
	elif pil==3:
		peta_jkt(lons,lats,bound,ch1[i,...],u11[i+1,...],v11[i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
	elif pil==4:
		peta_bali(lons,lats,bound,ch1[i,...],u11[i+1,...],v11[i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
	lv=[1000,950,900,850,700,500,200]
	for j in range(len(lv)):
		if j==0:
			lev='Surface'
			levv='Surface'
			levt='2-m'
			fname=ijj+'km_mslp-prec_'+fnam
			pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/'+lev+'/mslp-Precipitation/'
			parameters='MSLP(contour, mb), Prec(shaded, mm)'
			if pil==1:
				peta_indo(lons,lats,bound,ch1[i,...],mp1[i+1,...],'none','none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==2:
				peta_jawa(lons,lats,bound,ch1[i,...],mp1[i+1,...],'none','none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==3:
				peta_jkt(lons,lats,bound,ch1[i,...],mp1[i+1,...],'none','none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==4:
				peta_bali(lons,lats,bound,ch1[i,...],mp1[i+1,...],'none','none',parameters,pathn,fname,step,init,pred,ver)
		else:
			lev=str(lv[j])
			levv=str(lv[j])+' mb'
			levt=str(lv[j])+' mb'
		fname=ijj+'km_streamline_'+fnam
		pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/'+lev+'/streamline/'
		parameters=levv+' Wind & isotach(m/s)'
		if pil==1:
			peta_indo(lons,lats,bound,ws1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==2:
			peta_jawa(lons,lats,bound,ws1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==3:
			peta_jkt(lons,lats,bound,ws1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==4:
			peta_bali(lons,lats,bound,ws1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
		fname=ijj+'km_rh_'+fnam
		pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/'+lev+'/rh/'
		parameters=levv+' Relative Humidity (%)'
		if pil==1:
			peta_indo(lons,lats,bound,rh1[j,i+1,...],'none','none','none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==2:
			peta_jawa(lons,lats,bound,rh1[j,i+1,...],'none','none','none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==3:
			peta_jkt(lons,lats,bound,rh1[j,i+1,...],'none','none','none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==4:
			peta_bali(lons,lats,bound,rh1[j,i+1,...],'none','none','none',parameters,pathn,fname,step,init,pred,ver)
		
		if j==0:
			lev='Surface'
			levv='Surface'
			levt='2-m'
		else:
			lev=str(lv[j])
			levv=str(lv[j])+' mb'
			levt=str(lv[j])+' mb'
		fname=ijj+'km_temp_'+fnam
		pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/'+lev+'/temp/'
		parameters=levt+' Temperature ('+degree+')'
		if pil==1:
			peta_indo(lons,lats,bound,tm1[j,i+1,...],'none','none','none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==2:
			peta_jawa(lons,lats,bound,tm1[j,i+1,...],'none','none','none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==3:
			peta_jkt(lons,lats,bound,tm1[j,i+1,...],'none','none','none',parameters,pathn,fname,step,init,pred,ver)
		elif pil==4:
			peta_bali(lons,lats,bound,tm1[j,i+1,...],'none','none','none',parameters,pathn,fname,step,init,pred,ver)

		if np.logical_or(lv[j]==1000,lv[j]==200):
			fname=ijj+'km_divergence_'+fnam
			pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/'+lev+'/divergence/'
			parameters=levv+' divergence ('+unit1+')'
			if pil==1:
				peta_indo(lons,lats,bound,di1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==2:
				peta_jawa(lons,lats,bound,di1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==3:
				peta_jkt(lons,lats,bound,di1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==4:
				peta_bali(lons,lats,bound,di1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
		
		if np.logical_or(lv[j]==1000,lv[j]==850):
			fname=ijj+'km_convergence_'+fnam
			pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/'+lev+'/convergence/'
			parameters=levv+' convergence ('+unit1+')'
			if pil==1:
				peta_indo(lons,lats,bound,di1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==2:
				peta_jawa(lons,lats,bound,di1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==3:
				peta_jkt(lons,lats,bound,di1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
			elif pil==4:
				peta_bali(lons,lats,bound,di1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)
		
		fname=ijj+'km_vorticity_'+fnam
		pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/'+lev+'/vorticity/'
		parameters=levv+' relative vorticity ('+unit1+')'
		if pil==1:
			peta_indo(lons,lats,bound,vo1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)   
		elif pil==2:     
			peta_jawa(lons,lats,bound,vo1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)   
		elif pil==3:     
			peta_jkt(lons,lats,bound,vo1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)  
		elif pil==4:   
			peta_bali(lons,lats,bound,vo1[j,i+1,...],uu1[j,i+1,...],vv1[j,i+1,...],'none',parameters,pathn,fname,step,init,pred,ver)      
                         
    # # xxx='2021060800'
    # # path='/home/wrfadmin/install-wrf/'
    # # fn=path+'OUTPUT/'+xxx+'/'+xxx+'-d01-asim.ctl'
    # # lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,pred1,init=buka_file(fn)
    # # fn=path+'OUTPUT/'+xxx+'/'+xxx+'-d02-asim.ctl'
    # # lons2,lats2,ch2,u12,v12,mp2,uu2,vv2,ws2,rh2,tm2,di2,vo2,pred2,init=buka_file(fn)
    # # # plot_ch(lons1,lats1,ch1,u11,v11,mp1,1,init,pred1,xxx)
    # # # plot_ch(lons2,lats2,ch2,u12,v12,mp2,2,init,pred2,xxx)
    # # # plot_ch(lons2,lats2,ch2,u12,v12,mp2,3,init,pred2,xxx)
    # # plot_all(lons2,lats2,ch2,u12,v12,mp2,uu2,vv2,ws2,rh2,tm2,di2,vo2,3,init,pred2,xxx)
    # # plot_all(lons2,lats2,ch2,u12,v12,mp2,uu2,vv2,ws2,rh2,tm2,di2,vo2,2,init,pred2,xxx)
    # # plot_all(lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,1,init,pred1,xxx)
       
def plot_mtgrm(rrm1,ttm1,uum1,vvm1,wsm1,lons1,lats1,ch1,u11,v11,ws11,t21,td21,rh21,clfl1,clfm1,clfh1,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,pred1,init1):
    ijj='bajo3'
    yyy='Bajo(3km)'
    ver='3km InaNWPv1.2'
    bound=[-9.5,-7.5,114.,116.]
    path='/scratch/inanwp/'
    xxx=sys.argv[1]+sys.argv[2]+sys.argv[3]+sys.argv[4] #str(2022111412)
    
    st=['Meruorah_Komodo','Ayana Komodo','Plataran_Komodo','Bandara_Komodo','Pulau_Komodo','Pulau_Komodo','Pulau_Rinca','Bintang_Flores','Sudamala','Pulau_Bidadari','Bukit_Waringin']
    lo=['119.875568','119.874358','119.872778','119.888109','119.526870','119.526870','119.677456','119.8769089605487','119.8725505504666','119.83831897153134','119.87957756721215']
    la=['-8.490430','-8.467899','-8.453923','-8.480795','-8.528837','-8.722440','-8.722440','-8.510829280842483','-8.522592432633575','-8.482773537512816','-8.494958499808144']
#    for i in range(len(st)):
    fnam=').png'
    fname=ijj+'mtgrm_('
    pathn=path+'PRODUCT/GFS0.25deg+Ground+Radar+Sat/'+xxx+'/'+yyy+'/Surface/METEOGRAM/'
    plot_meteogram(rrm1,ttm1,uum1,vvm1,wsm1,lons1,lats1,ch1,u11,v11,ws11,t21,td21,rh21,clfl1,clfm1,clfh1,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,pred1,init1,2,st,lo,la,pathn,fname,fnam,xxx)       

def mocosik():    
	xxx=sys.argv[1]+sys.argv[2]+sys.argv[3]+sys.argv[4] #str(2022111412)
	path='/scratch/inanwp/'
	fn=[]
	fn.append(path+'OUTPUT/'+xxx+'/wrfout_d01_'+sys.argv[1]+'-'+sys.argv[2]+'-'+sys.argv[3]+'_'+sys.argv[4]+':00:00')
	fn.append(path+'OUTPUT/'+xxx+'/wrfout_d02_'+sys.argv[1]+'-'+sys.argv[2]+'-'+sys.argv[3]+'_'+sys.argv[4]+':00:00')
	fn.append(path+'OUTPUT/'+xxx+'/wrfout_d03_'+sys.argv[1]+'-'+sys.argv[2]+'-'+sys.argv[3]+'_'+sys.argv[4]+':00:00')
	return(fn,path,xxx)
    
def ok(lons3,lats3,ch3,u13,v13,mp3,uu3,vv3,ws3,rh3,tm3,di3,vo3,init3,pred3,lons2,lats2,ch2,u12,v12,mp2,uu2,vv2,ws2,rh2,tm2,di2,vo2,init2,pred2,xxx,path,lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,init1,pred1,i):
# def okk(pil,xxx,path,lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,init1,pred1,i):
	plot_all(lons3,lats3,ch3,u13,v13,mp3,uu3,vv3,ws3,rh3,tm3,di3,vo3,3,init3,pred3,xxx,i,path);print(i)
	if i<=24:
		plot_all(lons2,lats2,ch2,u12,v12,mp2,uu2,vv2,ws2,rh2,tm2,di2,vo2,2,init2,pred2,xxx,i,path)
		plot_all(lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,1,init1,pred1,xxx,i,path)
    # plot_all(lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,pil,init1,pred1,xxx,i,path)
    # plot_all(lons2,lats2,ch2,u12,v12,mp2,uu2,vv2,ws2,rh2,tm2,di2,vo2,4,init2,pred2,xxx,i,path)
# def ok(fn,path,xxx,i):
	# rrm1,ttm1,uum1,vvm1,wsm1,lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,pred1,init1=buka_file(fn[i])
	# plot_ch(lons1,lats1,ch1,u11,v11,mp1,i,init1,pred1,xxx,path)
	# nn=len(pred1)
	# for j in range(nn):
		# plot_all(lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,i,init1,pred1,xxx,j,path)
	# # nn=len(pred1)
	# # pool2 = Pool(processes=nn)
	# # it1=[ik for ik in range(0,nn-1)]
	# # func2 = partial(okk, i,xxx,path,lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,init1,pred1)
	# # # print('Processing...')
	# # pool2.map(func2, it1)
	# # pool2.close()
	# # pool2.join()
    
def test():
	from functools import partial
	fn,path,xxx=mocosik()
	# pool = Pool(processes=3)
	# it=[i for i in range(0,3)]
	# func = partial(ok, fn,path,xxx)
	# print('Processing...')
	# pool.map(func, it)
	# pool.close()
	# pool.join()
	print('Reading...')
	rrm1,ttm1,uum1,vvm1,wsm1,lons1,lats1,ch1,u11,v11,ws11,t21,td21,rh21,clfl1,clfm1,clfh1,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,pred1,init1=buka_file(fn[0])
	rrm2,ttm2,uum2,vvm2,wsm2,lons2,lats2,ch2,u12,v12,ws12,t22,td22,rh22,clfl2,clfm2,clfh2,mp2,uu2,vv2,ws2,rh2,tm2,di2,vo2,pred2,init2=buka_file(fn[1])
	rrm3,ttm3,uum3,vvm3,wsm3,lons3,lats3,ch3,u13,v13,ws13,t23,td23,rh23,clfl3,clfm3,clfh3,mp3,uu3,vv3,ws3,rh3,tm3,di3,vo3,pred3,init3=buka_file(fn[2])
	plot_ch(lons3,lats3,ch3,u13,v13,mp3,3,init3,pred3,xxx,path)
	plot_ch(lons2,lats2,ch2,u12,v12,mp2,2,init2,pred2,xxx,path) 
	plot_ch(lons1,lats1,ch1,u11,v11,mp1,1,init1,pred1,xxx,path)
	print('Plotting...')
	nn=len(pred3)
	pool = Pool(processes=nn)
	it=[i for i in range(0,nn)]
	func = partial(ok, lons3,lats3,ch3,u13,v13,mp3,uu3,vv3,ws3,rh3,tm3,di3,vo3,init3,pred3,lons2,lats2,ch2,u12,v12,mp2,uu2,vv2,ws2,rh2,tm2,di2,vo2,init2,pred2,xxx,path,lons1,lats1,ch1,u11,v11,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,init1,pred1)
	# func = partial(ok, 3,xxx,path,lons3,lats3,ch3,u13,v13,mp3,uu3,vv3,ws3,rh3,tm3,di3,vo3,init3,pred3)
	print('Processing...')
	pool.map(func, it)
	pool.close()
	pool.join()
	# plot_mtgrm(rrm1,ttm1,uum1,vvm1,wsm1,lons1,lats1,ch1,u11,v11,ws11,t21,td21,rh21,clfl1,clfm1,clfh1,mp1,uu1,vv1,ws1,rh1,tm1,di1,vo1,pred1,init1)
	# ok(1)   

	end = timer()
	print(str((end - start)/60)+' minutes')
    

if __name__ == '__main__':
    test()

EOF

/home/inanwp/libraries/.anaconda3/bin/python n.py $1 $2 $3 $4
echo 'ok'
#rm n.py
# ssh litbangweb@202.90.199.54 mv litbangweb@202.90.199.54:/mnt/wdd1/www/htdocs/wrf/latest/GFS0.25deg+Ground+Radar+Sat/* litbangweb@202.90.199.54:/mnt/wdd1/www/htdocs/wrf/archive/GFS0.25deg+Ground+Radar+Sat
# scp -r /scratch/inanwp/PRODUCT/GFS0.25deg+Ground+Radar+Sat/$1$2$3$4 litbangweb@202.90.199.54:/mnt/wdd1/www/htdocs/wrf/latest/GFS0.25deg+Ground+Radar+Sat
exit
