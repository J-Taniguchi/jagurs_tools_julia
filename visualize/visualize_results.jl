using Distributed
@everywhere using GMT
@everywhere using Plots
@everywhere using DelimitedFiles
@everywhere case_name = $ARGS[1]
@everywhere tar_dir = "../$case_name/"
@everywhere fig_dir = "./$case_name/"
@everywhere tsunpar = readlines(tar_dir * "tsun.par")
@everywhere gridfile_path = tar_dir * "gridfile.dat"
@everywhere function read_tsunpar(keyword, tsunpar)
    for i = 1:length(tsunpar)
        if tsunpar[i][1:length(keyword)] == keyword
            return split(tsunpar[i], "=")[end]
        end
    end
end


@everywhere function read_gridfile(gridfile_path)
    grid_file = readdlm(gridfile_path)
    nc_names = grid_file[:,1] .* ".nc"
    bathty_names = string.(grid_file[:,4])
    return nc_names, bathty_names
end


@everywhere dt = parse(Float64, read_tsunpar("dt",tsunpar))
@everywhere tend = parse(Int64, read_tsunpar("tend",tsunpar))
@everywhere itmap = parse(Int64, read_tsunpar("itmap",tsunpar))


@everywhere n_steps =Int(fld(tend,dt*itmap))
println("n_steps:",n_steps)
#dt_min = dt * itmap / 60

@everywhere nc_names, bathty_names = read_gridfile(gridfile_path)

@everywhere dpi=400
@everywhere lw=0.1
for i = 1:length(nc_names)
    @everywhere nc_name = nc_names[$i]
    @everywhere bathty_name = bathty_names[$i]
    @everywhere save_dir = fig_dir * nc_name[1:end-3] * "/"
    mkpath(save_dir)
    println(save_dir)

    @everywhere grd = gmtread(tar_dir * nc_name * "?max_height", grid=true)
    @everywhere x = grd.x
    @everywhere y = grd.y
    @everywhere z = grd.z

    @everywhere bathy = gmtread(tar_dir * bathty_name, grid=true).z

    @everywhere lim = maximum(abs.(extrema(z[.!isnan.(z)])))
    @everywhere xmin,xmax,ymin,ymax = grd.range

    z = grd.z
    Plots.heatmap(x, y, z, c=:balance, clim=(-lim,lim), aspect_ratio=1, dpi=dpi)
    Plots.contour!(x, y, -bathy,
        levels=[0],
        color=:black,
        lw=lw,
        aspect_ratio=1,
        dpi=dpi
        )
    xx = [xmin,xmin,xmax,xmax,xmin]
    yy = [ymin,ymax,ymax,ymin,ymin]
    Plots.plot!(xx,yy,color=:black,legend=false)
    Plots.title!("maximum height")
    Plots.savefig(fig_dir * nc_name * "maxh.png")

    #@progress for j = 0:n_steps
    pmap(0:n_steps) do j
        grd = gmtread(tar_dir * nc_name * "?wave_height[$j]", grid=true)
        z = grd.z
        Plots.heatmap(x, y, z, c=:balance, clim=(-lim,lim), aspect_ratio=1, dpi=dpi)
        Plots.contour!(x, y, -bathy,
            levels=[0],
            color=:black,
            lw=lw,
            aspect_ratio=1,
            dpi=dpi
            )
        xx = [xmin,xmin,xmax,xmax,xmin]
        yy = [ymin,ymax,ymax,ymin,ymin]
        Plots.plot!(xx,yy,color=:black,legend=false)
        Plots.title!("t = " * lpad(j,6,"0") * " min")
        Plots.savefig(save_dir * lpad(j,6,"0")*".png")
    end
    run(`ffmpeg -y -r 30 -i $save_dir/%06d.png -pix_fmt yuv420p -q 0 $save_dir/../$nc_name.mp4`)
end
