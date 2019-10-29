using DelimitedFiles
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

grd_dir = "../bathymetry_mie_grd/"
data_dir  = "../bathymetry_mie/"

bathies = ["810_dep", "270_dep", "090-04_dep", "090-05_dep", "090-06_dep"]
for i = 1:length(bathies)
    f = readdlm(data_dir * bathies[i])
    x0,y0,dx,dy= float.(f[2,1:4])
    x0 = x0 + dx / 2
    y0 = y0 + dy / 2
    z = float.(f[3:end,:])

    #grdフォーマットのzは1行目が南．csvをそのまま書けば地形図になるイメージ
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

file_names = ["810", "270", "090-04", "090-05", "090-06"]
map_files = file_names.* "_map"
line_files = file_names.* ".bdh"

for i = 1:length(file_names)
    println(i)
    map_f = open(data_dir * map_files[i])
    map_f = readlines(map_f)
    line = float.(readdlm(data_dir * line_files[i])[3:end,:])
    nx,ny = [parse(Int64, split(map_f[1])[j]) for j = 1:length(split(map_f[1]))]
    x0,y0,dx,dy = [parse(Float64, split(map_f[2])[j]) for j = 1:length(split(map_f[2]))]
    x0 = x0 + dx / 2
    y0 = y0 + dy / 2

    out_file = Array{Any}(undef,0,4)
    for j = 1:ny
        line_info = [map_f[j+2][n:n+1] for n=1:2:nx*2]
        for k = 1:nx
            if line_info[k][1] ≠ ' '
                if line[j,k] ≤ 0.0
                    println(line_info[k])
                    println(line[j,k])
                    error()
                end
                x = Int(x0 + dx * (k - 1))
                y = Int(y0 + dy * (ny - j))
                line_loc = parse(Int64, line_info[k][1])
                line_hight = line[j,k]
                out = collect((x, y, line_loc, line_hight))
                out_file = vcat(out_file, out')
            end
        end
    end
    if size(out_file)[1] ≠ 0
        writedlm(grd_dir * file_names[i] * "_line.dat", out_file ,' ')
    end
end
