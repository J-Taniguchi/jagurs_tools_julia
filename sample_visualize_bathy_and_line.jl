#set jagurs_tools_path
#if you set as absolute path, you can bring this code everywhere you want.
jagurs_tools_path = "./"

#make bathy_paths as Vector{String}
bathy_dir = "../dataset/arikawa/"
bathies = ["bathy.grd"]
bathy_paths = joinpath.(bathy_dir, bathies)

#make line_paths as Vector{String}
#the order must be same as bathy_paths
lines = ["bank.txt"]
line_paths = joinpath.(bathy_dir, lines)

#set out_dir
out_dir  = "../dataset/arikawa_result"

#don't touch below
include(joinpath(jagurs_tools_path, "visualize/visualize_bathy.jl"))
mkpath(out_dir)

for i = 1:length(bathy_paths)
    println(bathy_paths[i])
    visualize_bathy_and_line(bathy_paths[i], line_paths[i], out_dir, c=:inferno, fig_type="png")
end
