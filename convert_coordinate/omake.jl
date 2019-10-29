include("subs.jl")
using Main.grd_converter
using GMT
using Plots
pyplot()
mkpath("img")

tar_mesh="810"

#変換前の断層モデルのディレクトリ
deg_dir = "../results/Mw80/member.000001/"
deg_faults = get_grd_list(deg_dir)

#変換後の断層モデルのディレクトリ
cartesian_dir = "./out/Mw80/member.000001/"
tmp = readdir(cartesian_dir)
cartesian_faults = []
for i = 1:length(tmp)
    if tmp[i][1:3]==tar_mesh
        push!(cartesian_faults,tmp[i])
    end
end
cartesian_faults = string.(cartesian_faults)

#dispに重ねて書く地形ファイルの読み込み
#変換後の初期水位分布のgrdファイルに対応する地形ファイル
grd = gmtread("../chikei/xy/chikei_0$tar_mesh-01.grd", grd=true)
cart_x = grd.x
cart_y = grd.y
cart_z = grd.z

#変換前の初期水位分布のgrdファイルに対応する地形ファイル
grd = gmtread("../chikei/deg_chikei_0$tar_mesh-01.grd", grd=true)
deg_x = grd.x
deg_y = grd.y
deg_z = grd.z

for i = 1:length(deg_faults)
    print(i)
    grd = gmtread(cartesian_dir*cartesian_faults[i], grd=true)
    x = grd.x
    y = grd.y
    z = grd.z
    lim = maximum(abs.(z))

    heatmap(x, y, z, c=:balance, clim=(-lim,lim))
    Plots.contour!(cart_x, cart_y, -1 * cart_z, levels=0, c=:black, legend=:none)
    xlims!(minimum(cart_x),maximum(cart_x))
    ylims!(minimum(cart_y),maximum(cart_y))
    title!("cart$i")

    fname = "./img/$(tar_mesh)_cart$i.png"
    rm(fname, force=true)
    savefig(fname)

    grd = gmtread(deg_dir * deg_faults[i], grd=true)
    x = grd.x
    y = grd.y
    z = grd.z
    #lim = maximum(abs.(z))

    heatmap(x, y, z, c=:balance, clim=(-lim,lim))
    Plots.contour!(deg_x, deg_y, -1 * deg_z, levels=0, c=:black, legend=:none)
    xlims!(minimum(deg_x),maximum(deg_x))
    ylims!(minimum(deg_y),maximum(deg_y))
    title!("deg$i")
    fname = "./img/$(tar_mesh)_deg$i.png"
    rm(fname, force=true)
    savefig(fname)
end
