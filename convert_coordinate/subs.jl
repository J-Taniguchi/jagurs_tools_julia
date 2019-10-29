module grd_converter

using GMT
using Proj4

export get_810_disp_grd_list,convert_grd

"""
get_810_disp_grd_list(tar_dir)
get list of 810_disp*.grd in tar_dir.
"""
function get_810_disp_grd_list(tar_dir)
    tar_grd = Array{String}(undef,0)
    fs = readdir(tar_dir)
    for i = 1:length(fs)
        if fs[i][1:8] == "810_disp" && fs[i][end-3:end] == ".grd"
            tar_grd = vcat(tar_grd,fs[i])
            vcat
        end
    end
    return tar_grd
end

"""
convert_grd(tar_grd, in_proj, out_proj)
convert tar_grd from in_proj to out_proj
output is xyz format.
in_proj (and out_proj) can make like
in_proj = Projection(Proj4.epsg[in_EPSG_code])
"""
function convert_grd(tar_grd, in_proj, out_proj)
    xyz = grd2xyz(tar_grd)[1].data
    out_xy = transform(in_proj, out_proj, xyz[:,1:2])
    return hcat(out_xy, xyz[:,3])
end

end
