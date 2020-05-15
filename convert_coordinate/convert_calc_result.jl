include("subs.jl")
using Main.grd_converter
using Proj4
using DelimitedFiles
using GMT

#out_dirは変換後のgrdファイルを出力するディレクトリ．
#out_dir内にMwごとにディレクトリを作成し，
#その中にシナリオごとにディレクトリを作成，
#各シナリオのディレクトリ内に変換・補間後のgrdファイルを出力する．
out_dir ="../disp/"
mkpath(out_dir)

#お渡ししたHDD内のresults/ディレクトリへのpath
#results_dir = "../../dansou/results/"
results_dir = "../../results"

#変換するgrdファイルのEPSGコード．お渡ししたデータは4612なので
#このままでよい
in_EPSG_code  = 4612 #JGD2000
in_proj  = Projection(Proj4.epsg[in_EPSG_code ])

#以下出力するgrdファイルの座標系を指定する．
#以下2通りのどちらかの方法でout_projを作成する．
#EPSGコードを使う場合#######################################
out_EPSG_code = 2448 #平面直角6系
#out_EPSG_code = 2446 #平面直角4系
out_proj = Projection(Proj4.epsg[out_EPSG_code])
#原点座標を指定する場合#####################################
#lat=33.0
#lon=133.5
#proj_string="+proj=tmerc +lat_0=$lat +lon_0=$lon +k=0.9999 +x_0=0 +y_0=0 +ellps=GRS80"
#out_proj = Projection(proj_string)
##########################################################

domains = readdlm("domain.csv", ',')[2:end,:]
#domains = [810]
#変換したいMwをArray形式で与える
#Mw_list = ["Mw80","Mw82","Mw84","Mw86","Mw88","Mw90"]
Mw_list = ["Mw80"]
for Mw = Mw_list
    members = readdir(results_dir * Mw *'/')
    #変換したいシナリオ番号(member)のループ
    for member_loop = 1 : 1#length(members)
        mkpath(out_dir * Mw * "/" * members[member_loop])
        tar_dir = results_dir * Mw * "/" * members[member_loop] * "/"
        faults = get_grd_list(tar_dir)
        for fault_loop = 1: length(faults)
            xyz = convert_grd(tar_dir * faults[fault_loop], in_proj, out_proj)
            for domain_loop = 1 : size(domains)[1]
                out_f_name = out_dir * Mw * "/" * members[member_loop] * "/" * string(domains[domain_loop,1])* "_" * lpad(fault_loop,6,"0") * ".grd=cf"
                println(out_f_name)
                surface(xyz, G=out_f_name, I=domains[domain_loop,2], R=float.(domains[domain_loop,3:end]), T=0.25)
                #nearneighbor(xyz, G=out_f_name, I=domains[domain_loop,2], R=float.(domains[domain_loop,3:end]), S=1000, E=-99999)
            end
        end
    end
end
