using DelimitedFiles
using Printf

using ArgParse
using GMT; gmtread
using Plots
using ProgressMeter
ENV["GKSwstype"]="nul"
default(show=false)

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "gridfile"
            help = "gridfile.dat"
            arg_type = String
            required = true
        "output_dir"
            help = "output directory"
            arg_type = String
            required = true
        "--write_line", "-l"
            help = "write line data"
            action = :store_true
        "--image_type", "-i"
            help = "output image type. png or svg"
            default = "png"
        "--yes_all", "-y"
            help = "make output_dir if it dose not exist, and output files to output_dir."
            action = :store_true

    end
    return parse_args(s)
end


function visualize_bathy(bathy_path, out_dir; c=:oleron, dpi=300, fig_type="png", clip_lim=2000, out_fig_name=missing)
    grd = gmtread(bathy_path, grd=true)
    x = grd.x
    y = grd.y
    z = grd.z
    lim = minimum([clip_lim, abs(minimum(z)), maximum(z)])

    Plots.heatmap(x, y, -z, c=c, clim=(-lim,lim), aspect_ratio=1, dpi=dpi)

    if ismissing(out_fig_name)
        bathy_name = split(bathy_path,"/")[end]
        bathy_name = split(bathy_name,".")[1:end-1]
        bathy_name = join(bathy_name,'.')

        out_fig_name = bathy_name * "." * fig_type
    else
        out_fig_name = out_fig_name * "." * fig_type
    end

    savefig(joinpath(out_dir, out_fig_name))
end

function visualize_bathy_and_line(bathy_path, line_path, out_dir; c=:oleron, dpi=300, fig_type="png", clip_lim=2000, chikei_lw=0.05, line_lw=0.1, out_fig_name=missing)
    grd = gmtread(bathy_path, grd=true)
    x = grd.x
    y = grd.y
    z = grd.z
    dx_half = grd.inc[1]/2
    xmin,xmax,ymin,ymax = grd.range
    lim = minimum([clip_lim, abs(minimum(z)), maximum(z)])
    Plots.heatmap(x, y, -z, c=c, clim=(-lim,lim), aspect_ratio=1, dpi=dpi)
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

    for j = 1: size(line)[1]
        if line[j,3] == 1
            xx = [line[j,2] + dx_half, line[j,2] + dx_half]
            yy = [line[j,1] - dx_half, line[j,1] + dx_half]
            zz = [line[j,4], line[j,4]]
            Plots.plot!(xx,yy, c=:red, lw=line_lw, legend=false)
        elseif line[j,3] == 2
            xx = [line[j,2] - dx_half, line[j,2] + dx_half]
            yy = [line[j,1] + dx_half, line[j,1] + dx_half]
            zz = [line[j,4], line[j,4]]
            Plots.plot!(xx,yy, c=:red, lw=line_lw, legend=false)
        elseif line[j,3] == 3
            xx = [line[j,2] + dx_half, line[j,2] + dx_half]
            yy = [line[j,1] - dx_half, line[j,1] + dx_half]
            zz = [line[j,4], line[j,4]]
            Plots.plot!(xx,yy, c=:red, lw=line_lw, legend=false)

            xx = [line[j,2] - dx_half, line[j,2] + dx_half]
            yy = [line[j,1] + dx_half, line[j,1] + dx_half]
            zz = [line[j,4], line[j,4]]
            Plots.plot!(xx,yy, c=:red, lw=line_lw, legend=false)
        else
            error("line_file is invalid")
        end
    end

    if ismissing(out_fig_name)
        bathy_name = split(bathy_path,"/")[end]
        bathy_name = split(bathy_name,".")[1:end-1]
        bathy_name = join(bathy_name,'.')

        out_fig_name = bathy_name * "." * fig_type
    else
        out_fig_name = out_fig_name * "." * fig_type
    end
    savefig(joinpath(out_dir, out_fig_name))
end

function read_gridfile(fpath)
    grid_file = readdlm(fpath)
    n_grid, n_col = size(grid_file)

    bathy_paths = Array{String, 1}(undef, n_grid)
    out_names = Array{String, 1}(undef, n_grid)
    line_paths = Array{String, 1}(undef, n_grid)
    for i = 1: n_grid
        bathy_paths[i] = grid_file[i, 4]
        out_names[i] = grid_file[i, 1]
        if n_col == 8
            line_path = grid_file[i,8]
            if line_path == "NO_BANK_FILE_GIVEN"
                line_path=""
            end
            line_paths[i] = line_path
        else
            line_paths[i] = ""
        end
    end
    return bathy_paths, out_names, line_paths
end

function main()
    parsed_args = parse_commandline()
    out_dir = parsed_args["output_dir"]
    if parsed_args["yes_all"]
        mkpath(out_dir)
    else
        if isdir(out_dir)
            println(out_dir * " exsist. Is it OK to write files to this directory? [y/n]")
            n = readline()
            if n == "y"
            else
                println("program end")
                return
            end
        else
            println(out_dir + " dose not exsist. Is it OK to make directory? [y/n]")
            n = readline()
            if n == "y"
                mkpath(out_dir)
            else
                println("program end")
                return
            end
        end    
    end
    gridfile_path = parsed_args["gridfile"]
    gridfile_dir = dirname(gridfile_path)
    bathy_paths, out_names, line_paths = read_gridfile(gridfile_path)
    for i = 1:length(bathy_paths)
        bathy_path = joinpath(gridfile_dir, bathy_paths[i])
        tmp = joinpath(out_dir, out_names[i] * "." * parsed_args["image_type"])
        if parsed_args["write_line"] == true && line_paths[i] != ""
            line_path = joinpath(gridfile_dir, line_paths[i])
            @printf("writing %s from %s and %s \n", tmp, bathy_path, line_path)
            visualize_bathy_and_line(bathy_path, line_path, out_dir, fig_type=parsed_args["image_type"], out_fig_name=out_names[i])
        else
            @printf("writing %s from %s \n", tmp, bathy_path)
            visualize_bathy(bathy_path, out_dir, fig_type=parsed_args["image_type"], out_fig_name=out_names[i])
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
    println("program end")
end