Tools for JAGURS

# visualize_bathy(_and_line).jl
this program has bugs.
## required packages
- GMT.jl
  -  Note that, [GMT](https://github.com/GenericMappingTools/gmt/blob/master/INSTALL.md) is required for GMT.jl
- Plots.jl
- ProgressMeter.jl

# convert_coordinates.jl
## required packages
- GMT.jl
- Proj4.jl
- ArgParse.jl

## useage

``` bash
convert_coordinate.jl [input_grid_file] [output_grid_file_name] [EPSG_code_of_input_grid] [EPSG_code_of_output_grid]
```

### example of EPSG code
EPSG code | meaning|
----------|--------|
4612| JGD2000
6668 | JGD2011
6672 | 平面直角第4系(JGD2011)
2446 | 平面直角第4系(JGD2000)
6674 | 平面直角第6系(JGD2011)
2448 | 平面直角第6系(JGD2000)

[reference](http://tmizu23.hatenablog.com/entry/20091215/1260868350) (In Japanese)