include("subs.jl")
using Main.grd_converter
using Proj4
using DelimitedFiles
using GMT
using ArgParse

#out_dirは変換後のgrdファイルを出力するディレクトリ．
#out_dir内にMwごとにディレクトリを作成し，
#その中にシナリオごとにディレクトリを作成，
#各シナリオのディレクトリ内に変換・補間後のgrdファイルを出力する．


function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "input"
            help = "input grid file"
            arg_type = String
            required = true
        "output"
            help = "input grid file name"
            arg_type = String
            required = true
        "in_EPSG"
            help = "EPSG code of input grid"
            arg_type = Int
            required = true
        "out_EPSG"
            help = "EPSG code of output grid"
            arg_type = Int
            required = true
        "grid_size"
            help = "grid size of output grid."
            arg_type = String
            required = true
        "xmin"
            help = "xmin of output grid"
            arg_type = Float64
            required = true
        "xmax"
            help = "xmax of output grid"
            arg_type = Float64
            required = true
        "ymin"
            help = "ymin of output grid"
            arg_type = Float64
            required = true
        "ymax"
            help = "ymax of output grid"
            arg_type = Float64
            required = true
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    in_proj  = Projection(Proj4.epsg[parsed_args["in_EPSG"]])
    out_proj = Projection(Proj4.epsg[parsed_args["out_EPSG"]])
    xyz = convert_grd(parsed_args["input"], in_proj, out_proj)
    Rout = [parsed_args["xmin"],parsed_args["xmax"],parsed_args["ymin"],parsed_args["ymax"]]
    surface(xyz, G=parsed_args["output"], I=parsed_args["grid_size"], R=Rout, T=0.25)
    #nearneighbor(xyz, G=out_f_name, I=domains[domain_loop,2], R=float.(domains[domain_loop,3:end]), S=1000, E=-99999)
end

main()