using DelimitedFiles
using XLSX
using GMT
using ArgParse
using ProgressMeter


function parse_arg(ARGS)
    s = ArgParseSettings()
    @add_arg_table s begin
        "--out_dir", "-o"
            help = "出力ディレクトリ"
            arg_type = String
            required = true
        "--input_dir", "-i"
            help = "元の固定長データが存在するディレクトリ"
            arg_type = String
            required = true
        "--data_type", "-d"
            help = "depth(地形) or sodo(粗度) or line(堤防)"
            arg_type = String
            required = true
        "--target_mesh", "-t"
            help = "対象とする最小メッシュのエリアNo.これより上位の物全てについてgrdファイルを作成する"
            arg_type = String
            required = true
        "--xlsx_file", "-x"
            help = "計算範囲設定のxlsファイル.元はxlsファイルですが, xlsxに変換してください．"
            arg_type = String
            required = true
    end

    parsed_args = parse_args(ARGS, s)

    if (parsed_args["data_type"] != "depth") & (parsed_args["data_type"] != "sodo") & (parsed_args["data_type"] != "line")
        error("data_type must be depth or sodo or line. your input is " * parsed_args["data_type"])
    end

    return parsed_args
end


function main()
    parsed_arg = parse_arg(ARGS)
    println(parsed_arg)
    out_dir = parsed_arg["out_dir"]
    input_dir = parsed_arg["input_dir"]
    cal_area_xl = parsed_arg["xlsx_file"]
    target_mesh = parsed_arg["target_mesh"]
    data_type = parsed_arg["data_type"]
    cal_area = XLSX.readxlsx(cal_area_xl)
    mkpath(out_dir)

    if data_type == "depth"
        make_grid(out_dir, input_dir, cal_area, target_mesh, "depth")
    elseif data_type == "sodo"
        make_grid(out_dir, input_dir, cal_area, target_mesh, "fm")
    elseif data_type == "line"
        make_line(out_dir, input_dir, cal_area, target_mesh)
    end
end

function make_grid(out_dir, data_dir, cal_area, target_mesh, prefix)
    target_list = make_target_list(target_mesh, cal_area)
    for i = 1:length(target_list)
        println("processing :" * target_list[i])
        mesh_size_str = target_list[i][1:4]
        tar_sheet = cal_area[mesh_size_str * "m"][:]
        tar_sheet[ismissing.(tar_sheet)] .=""
        dx = 0
        dy = 0
        x0 = 0
        y0 = 0
        nx = 0
        ny = 0
        for j = 1:size(tar_sheet)[1]
            if tar_sheet[j,1] == target_list[i]
                dx = tar_sheet[j,2]
                dy = tar_sheet[j,2]
                x0 = tar_sheet[j,3]
                y0 = tar_sheet[j,4]
                nx = tar_sheet[j,9]
                ny = tar_sheet[j,10]
                break
            end
            if j == size(tar_sheet)[1]
                error(target_list[i] * " was not found.")
            end
        end
        x0 = x0 + dx / 2
        y0 = y0 + dy / 2

        z = Array{Float64}(undef,nx,ny)
        fpath = joinpath(data_dir, prefix * "_" * target_list[i] * ".dat")
        if ispath(fpath) == false
            println(fpath * " is not exist")
            continue
        end
        f = open(fpath)
        f = readlines(f)
        f = [parse(Float64,f[j][n*8-7:n*8]) for j = 1:length(f) for n =1:10]

        for j = 1:length(f)
            z[j] = float(f[j])
        end
        z = convert(Array, z')
        z = z[end:-1:1, :]

        x = collect(range(x0, length=size(z)[2], step = dx))
        y = collect(range(y0, length=size(z)[1], step = dy))

        if i ≠ 1
            x = x[2:end-1]
            y = y[2:end-1]
            z = z[2:end-1,2:end-1]
        end

        # G = make_GMTgrid(dx,dy,x,y,z)
        xmin, xmax = extrema(x)
        ymin, ymax = extrema(y)
        zmin, zmax = extrema(z)
        reg = 0 # gridline node format
        xinc = dx
        yinc = dy

        hdr = [x0 xmax y0 ymax zmin zmax reg xinc yinc]
        grd = mat2grid(z, hdr=hdr)

        gmtwrite(joinpath(out_dir, prefix * "_" * target_list[i] * ".grd=cf"), grd)
    end
end


function make_line(out_dir, data_dir, cal_area, target_mesh)
    target_list = make_target_list(target_mesh, cal_area)

    for i = 1:length(target_list)
        println("processing :" * target_list[i])
        mesh_size_str = target_list[i][1:4]
        tar_sheet = cal_area[mesh_size_str * "m"][:]
        tar_sheet[ismissing.(tar_sheet)] .=""
        dx = 0
        dy = 0
        x0 = 0
        y0 = 0
        nx = 0
        ny = 0
        for j = 1:size(tar_sheet)[1]
            if tar_sheet[j,1] == target_list[i]
                dx = tar_sheet[j,2]
                dy = tar_sheet[j,2]
                x0 = tar_sheet[j,3]
                y0 = tar_sheet[j,4]
                nx = tar_sheet[j,9]
                ny = tar_sheet[j,10]
                break
            end
            if j == size(tar_sheet)[1]
                error(target_list[i] * " was not found.")
            end
        end
        x0 = x0 + dx / 2
        y0 = y0 + dy / 2

        fpath = joinpath(data_dir, "ir_" * target_list[i] * ".dat")
        if ispath(fpath) == false
            println(fpath * " is not exist")
            continue
        end
        line_f = open(fpath)
        line_f = readlines(line_f)
        line_f = [parse(Int64, line_f[j][n*8-7:n*8]) for j = 1:length(line_f) for n =1:10]

        x = collect(range(x0, length=nx, step = dx))
        y = collect(range(y0, length=ny, step = dy))

        line = Array{Int64}(undef,nx,ny)

        for j = 1:length(line_f)
            line[j] = Int(line_f[j])
        end

        line = transpose(line)

        out_file = Array{Any}(undef,0,4)
        for j = 1:ny
            for k = 1:nx
                if line[j,k] ≠ 0
                    x = Int(x0 + dx * (k - 1))
                    y = Int(y0 + dy * (ny - j))
                    line_str = string(line[j,k])
                    minus_flag = false
                    if line_str[1] == '-'
                        line_str = line_str[2:end]
                        minus_flag = true
                    end
                    line_loc = parse(Int64,line_str[1])
                    line_hight = parse(Float64, line_str[2:end]) / 100.0
                    if minus_flag
                        line_hight = - line_hight
                    end
                    out = collect((y, x, line_loc, line_hight))
                    out_file = vcat(out_file, out')
                end
            end
        end
        if size(out_file)[1] ≠ 0
            writedlm(joinpath(out_dir, "ir_" * target_list[i] * "_line.dat"), out_file ,' ')
        end
    end
end


function make_GMTgrid(dx, dy, x, y, z)
    proj4 = ""
    wkt = ""
    range = [collect(extrema(x)); collect(extrema(y)); collect(extrema(z))]
    inc = [dx, dy]
    registration = 0
    nodata = NaN
    title = ""
    remark = ""
    command = ""
    datatype = ""
    x = x
    y = y
    z = z
    x_unit = ""
    y_unit = ""
    z_unit = ""
    layout = ""

    return GMT.GMTgrid(proj4, wkt, range, inc, registration, nodata, title, remark, command, datatype, x, y, z, x_unit, y_unit, z_unit, layout)
end


function make_target_list(target_area, cal_area)
    target_list = [target_area]
    while true
        parent_area = ""
        target_area = target_list[1]
        mesh_size = target_area[1:4] * "m"
        i = 5
        while true
            area_no = cal_area[mesh_size][i, 2]
            if area_no == target_area
                parent_area = cal_area[mesh_size][i, 14]
                break
            end
            if ismissing(area_no)
                error(target_area * " is not found in xlsx file.")
            end
            i+=1
        end

        if parent_area == "-"
            break
        else
            target_list = vcat(parent_area, target_list)
        end
    end
    return target_list
end

main()