using DelimitedFiles
using XLSX
using GMT

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

grd_dir = "../bathymetry_mie_CDMC_grd/"
data_dir  = "../../../中央防災会議_地形データ/06_bathy/地形データ_第06系/"
cal_area_xl = "../../../中央防災会議_地形データ/calcarea/計算範囲設定/計算範囲設定_第06系.xlsx"
cal_area = XLSX.readxlsx(cal_area_xl)
mkpath(grd_dir)

bathies = ["0810-01", "0270-02", "0090-04", "0090-05", "0090-06"]
@progress for i = 1:length(bathies)
    mesh_size_str = bathies[i][1:4]
    tar_sheet = cal_area[mesh_size_str * "m"][:]
    tar_sheet[ismissing.(tar_sheet)] .=""
    dx = 0
    dy = 0
    x0 = 0
    y0 = 0
    nx = 0
    ny = 0
    for j = 1:size(tar_sheet)[1]
        if tar_sheet[j,1] == bathies[i]
            dx = tar_sheet[j,2]
            dy = tar_sheet[j,2]
            x0 = tar_sheet[j,3]
            y0 = tar_sheet[j,4]
            nx = tar_sheet[j,9]
            ny = tar_sheet[j,10]
            break
        end
        if j == size(tar_sheet)[1]
            error(bathies[i] * " was not found.")
        end
    end
    x0 = x0 + dx / 2
    y0 = y0 + dy / 2

    z = Array{Float64}(undef,nx,ny)

    f = open(data_dir * "depth_" * bathies[i] * ".dat")
    f = readlines(f)
    f = [parse(Float64,f[j][n*8-7:n*8]) for j = 1:length(f) for n =1:10]

    for j = 1:length(f)
        z[j] = float(f[j])
    end
    z = transpose(z)
    z = z[end:-1:1,:]

    x = collect(range(x0, length=size(z)[2], step = dx))
    y = collect(range(y0, length=size(z)[1], step = dy))

    if i ≠ 1
        x = x[2:end-1]
        y = y[2:end-1]
        z = z[2:end-1,2:end-1]
    end

    G = make_GMTgrid(dx,dy,x,y,z)

    gmtwrite(grd_dir * bathies[i] * ".grd=cf", G)
end

##################################################
#ここから
#堤防
##################################################

file_names = ["0270-02", "0090-04", "0090-05", "0090-06"]
data_dir  = "../../../中央防災会議_地形データ/06_line/堤防データ_第06系/"
line_files ="ir_" .* file_names .* ".dat"

for i = 1:length(file_names)
    mesh_size_str = file_names[i][1:4]
    tar_sheet = cal_area[mesh_size_str * "m"][:]
    tar_sheet[ismissing.(tar_sheet)] .=""
    dx = 0
    dy = 0
    x0 = 0
    y0 = 0
    nx = 0
    ny = 0
    for j = 1:size(tar_sheet)[1]
        if tar_sheet[j,1] == file_names[i]
            dx = tar_sheet[j,2]
            dy = tar_sheet[j,2]
            x0 = tar_sheet[j,3]
            y0 = tar_sheet[j,4]
            nx = tar_sheet[j,9]
            ny = tar_sheet[j,10]
            break
        end
        if j == size(tar_sheet)[1]
            error(file_names[i] * " was not found.")
        end
    end
    x0 = x0 + dx / 2
    y0 = y0 + dy / 2


    println(i)
    line_f = open(data_dir * line_files[i])
    line_f = readlines(line_f)
    line_f = [parse(Int64,line_f[j][n*8-7:n*8]) for j = 1:length(line_f) for n =1:10]

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
                line_loc = parse(Int64,line_str[1])
                line_hight = parse(Float64, line_str[2:end]) / 100.0
                out = collect((y, x, line_loc, line_hight))
                out_file = vcat(out_file, out')
            end
        end
    end
    if size(out_file)[1] ≠ 0
        writedlm(grd_dir * file_names[i] * "_line.dat", out_file ,' ')
    end
end
