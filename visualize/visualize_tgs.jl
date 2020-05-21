using DelimitedFiles
using Printf

using ArgParse
using Plots
using Glob
ENV["GKSwstype"]="nul"
default(show=false)

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "input_dir"
            help = "directory where tgs?????? exist."
            arg_type = String
            required = true
        "output_dir"
            help = "output directory"
            arg_type = String
            required = true
        "--yes_all", "-y"
            help = "make output_dir if it dose not exist, and output files to output_dir."
            action = :store_true
    end

    return parse_args(s)
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
    c = 0
    while true
        c += 1
        fname = lpad(c, 6, "0")
        fname = "tgs" * fname
        if isfile(fname)
            println("writing ", fname)
            tgs = readdlm(fname, '=', skipstart=1)
            n_data = size(tgs)[1]
            t = [parse(Float64, tgs[i, 3][1:end-2]) for i = 1:n_data]
            z = [parse(Float64, tgs[i, 4][1:end-2]) for i = 1:n_data]
            plot(t, z, dpi=300)
            savefig(joinpath(out_dir, fname * ".png"))
        else
            break
        end
    end
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
    println("program end")
end