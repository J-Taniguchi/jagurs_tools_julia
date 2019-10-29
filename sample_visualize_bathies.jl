#set jagurs_tools_path
#if you set as absolute path, you can bring this code everywhere you want.
jagurs_tools_path = "path/to/jagurs_tools"

#make bathy_paths as Vector{String}
bathy_dir = "path/to/bathy_dir"
bathies = ["0090-04.grd", "0090-05.grd", "0090-06.grd"]
bathy_paths = joinpath.(bathy_dir, bathies)

#set out_dir
out_dir  = "path/to/out_dir/"

#don't touch below
include(joinpath(jagurs_tools_path, "/visualize/visualize_bathy.jl"))
mkpath(out_dir)

for i = 1:length(bathy_paths)
    println(bathy_paths[i])
    visualize_bathy(bathy_paths[i], out_dir)
end
