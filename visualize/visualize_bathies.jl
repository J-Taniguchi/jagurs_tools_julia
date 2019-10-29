using GMT
using Plots

grd_dir = "../bathymetry_mie_CDMC_grd/"
fig_dir  = "./figs_CDMC/"
mkpath(fig_dir)

bathies = ["0810-01", "0270-02", "0090-04", "0090-05", "0090-06"]
@progress for i = 1:length(bathies)
    grd = gmtread(grd_dir * bathies[i] * ".grd", grd=true)
    x = grd.x
    y = grd.y
    z = grd.z
    lim = minimum([2000, abs(minimum(z)), maximum(z)])
    if i==1
        #lim=2000
    else
        #lim=200
    end

    heatmap(x, y, -z, c=:topo, clim=(-lim,lim), aspect_ratio=1)
    savefig(fig_dir * bathies[i] * ".png")
end

file_names = ["0270-02", "0090-04", "0090-05", "0090-06"]
line_files = file_names.* "_line.dat"

line_lw   = 0.1
chikei_lw = 0.05
dpi=400
@progress for i = 1:length(file_names)
    grd = gmtread(grd_dir * file_names[i] * ".grd", grd=true)
    x = grd.x
    y = grd.y
    z = grd.z
    dx_half = grd.inc[1]/2
    xmin,xmax,ymin,ymax = grd.range
    lim = minimum([2000, abs(minimum(z)), maximum(z)])
    Plots.heatmap(x, y, -z, c=:topo, clim=(-lim,lim), aspect_ratio=1, dpi=dpi)
    Plots.contour!(x, y, -z,
        levels=[0],
        color=:black,
        lw=chikei_lw,
        aspect_ratio=1,
        dpi=dpi
        )
    xx = [xmin,xmin,xmax,xmax,xmin]
    yy = [ymin,ymax,ymax,ymin,ymin]
    Plots.plot!(xx,yy,color=:black,legend=false)

    line = readdlm(grd_dir * line_files[i], ' ')
    zmin,zmax = extrema(line[:,4])

    @progress for j = 1: size(line)[1]
        if line[j,3] == 1
            xx = [line[j,1] + dx_half, line[j,1] + dx_half]
            yy = [line[j,2] - dx_half, line[j,2] + dx_half]
            zz = [line[j,4], line[j,4]]
            Plots.plot!(xx,yy, c=:red, lw=line_lw, legend=false)
        elseif line[j,3] == 2
            xx = [line[j,1] - dx_half, line[j,1] + dx_half]
            yy = [line[j,2] + dx_half, line[j,2] + dx_half]
            zz = [line[j,4], line[j,4]]
            Plots.plot!(xx,yy, c=:red, lw=line_lw, legend=false)
        elseif line[j,3] == 3
            xx = [line[j,1] + dx_half, line[j,1] + dx_half]
            yy = [line[j,2] - dx_half, line[j,2] + dx_half]
            zz = [line[j,4], line[j,4]]
            Plots.plot!(xx,yy, c=:red, lw=line_lw, legend=false)

            xx = [line[j,1] - dx_half, line[j,1] + dx_half]
            yy = [line[j,2] + dx_half, line[j,2] + dx_half]
            zz = [line[j,4], line[j,4]]
            Plots.plot!(xx,yy, c=:red, lw=line_lw, legend=false)
        else
            error()
        end
    end
    Plots.savefig(fig_dir * file_names[i] * "line_loc.svg")
end


#i=1
#grdimage(grd_dir * bathies[i] * ".grd",J="x0.00001", fmt=:png ,savefig="A")
