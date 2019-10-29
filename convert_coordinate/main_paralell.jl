using Distributed

@everywhere include("subs.jl")
@everywhere using Main.grd_converter
@everywhere using Proj4
@everywhere using DelimitedFiles
@everywhere using GMT

#out_dirは変換後のgrdファイルを出力するディレクトリ．
#out_dir内にMwごとにディレクトリを作成し，
#その中にシナリオごとにディレクトリを作成，
#各シナリオのディレクトリ内に変換・補間後のgrdファイルを出力する．
@everywhere out_dir ="../disp/"
@everywhere mkpath(out_dir)

#お渡ししたHDD内のresults/ディレクトリへのpath
#@everywhere results_dir = "../../dansou/results/"
#@everywhere source_dir = "../../dansou/"
@everywhere results_dir = "../../results/"
@everywhere source_dir = "../../fault_model/"

#変換するgrdファイルのEPSGコード．お渡ししたデータは4612なので
#このままでよい
@everywhere in_EPSG_code  = 4612 #JGD2000
@everywhere const in_proj  = Projection(Proj4.epsg[in_EPSG_code ])

#以下出力するgrdファイルの座標系を指定する．
#以下2通りのどちらかの方法でout_projを作成する．
#EPSGコードを使う場合#######################################
@everywhere out_EPSG_code = 2448 #平面直角6系
#out_EPSG_code = 2446 #平面直角4系
@everywhere const out_proj = Projection(Proj4.epsg[out_EPSG_code])
#原点座標を指定する場合#####################################
#lat=33.0
#lon=133.5
#proj_string="+proj=tmerc +lat_0=$lat +lon_0=$lon +k=0.9999 +x_0=0 +y_0=0 +ellps=GRS80"
#out_proj = Projection(proj_string)
##########################################################

@everywhere domains = readdlm("domain.csv", ',')[2:end,:]
#domains = [810]
#変換したいMwをArray形式で与える
#@everywhere Mw_list = ["Mw80","Mw82","Mw84","Mw86","Mw88","Mw90"]
@everywhere Mw_list = ["Mw90"]
for Mw = Mw_list
    @everywhere Mw = $Mw
    @everywhere members = readdir(results_dir * Mw *'/')
    @everywhere members = members[length.(members) .== 13]
    #変換したいシナリオ番号(member)のループ
    #for member_loop = 1:length(members)
    pmap(2:2) do member_loop
    #pmap(1:length(members)) do member_loop
        out_member_dir = out_dir * Mw * "/" * members[member_loop] * "/"
        mkpath(out_member_dir)
        tar_dir = results_dir * Mw * "/" * members[member_loop] * "/"
        disps = get_810_disp_grd_list(tar_dir)
	#=
        for disp_loop = 1:length(disps)
            xyz = convert_grd(tar_dir * disps[disp_loop], in_proj, out_proj)
            for domain_loop = 1:size(domains)[1]
                out_f_name = out_member_dir * string(domains[domain_loop,1])* "_disp" * lpad(disp_loop,6,"0") * ".grd=cf"
                println(out_f_name)
                surface(xyz, G=out_f_name, I=domains[domain_loop,2], R=float.(domains[domain_loop,3:end]), T=0.25)
                #nearneighbor(xyz, G=out_f_name, I=domains[domain_loop,2], R=float.(domains[domain_loop,3:end]), S=1000, E=-99999)
            end
        end
	=#
        disp_list = get_810_disp_grd_list(out_member_dir)
        writedlm(out_member_dir * "disp_list.txt", disp_list)
        source_num = members[member_loop][end-5:end]
        tsunpar_dir = source_dir * Mw *"/input." * source_num * "/"
        tsunpar = readlines(tsunpar_dir * "tsun.par")
        tsunpar = vcat(tsunpar[1:16], tsunpar[18:end])
        writedlm(out_member_dir * "tsun.par", tsunpar,quotes=false)
    end
end
