using GMT
using Plots

function visualize_bathy(bathy_path, out_dir, c=:topo, dpi=300, fig_type="png", clip_lim=2000)
    grd = gmtread(bathy_path, grd=true)
    x = grd.x
    y = grd.y
    z = grd.z
    lim = minimum([clip_lim, abs(minimum(z)), maximum(z)])

    Plots.heatmap(x, y, -z, c=:topo, clim=(-lim,lim), aspect_ratio=1, dpi=dpi)

    bathy_name = split(bathy_path,"/")[end]
    bathy_name = split(bathy_name,".")[1:end-1]
    bathy_name = join(bathy_name,'.')

    out_fig_name = bathy_name * "." * fig_type

    savefig(joinpath(out_dir, out_fig_name))
end

function visualize_bathy_and_line(bathy_path, line_path, out_dir, c=:topo, dpi=400, fig_type="svg", clip_lim=2000, chikei_lw=0.05, line_lw=0.1)
    grd = gmtread(bathy_path, grd=true)
    x = grd.x
    y = grd.y
    z = grd.z
    dx_half = grd.inc[1]/2
    xmin,xmax,ymin,ymax = grd.range
    lim = minimum([clip_lim, abs(minimum(z)), maximum(z)])
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

    line = readdlm(line_path, ' ')
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
            error("line_file is invalid")
        end
    end

    bathy_name = split(bathy_path,"/")[end]
    bathy_name = split(bathy_name,".")[1:end-1]
    bathy_name = join(bathy_name,'.')

    out_fig_name = bathy_name * "." * fig_type
    savefig(joinpath(out_dir, out_fig_name))
end
