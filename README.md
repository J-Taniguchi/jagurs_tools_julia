Tools for JAGURS

# visualize_bathy.jl

## required packages
- GMT.jl
  -  Note that, [GMT](https://github.com/GenericMappingTools/gmt/blob/master/INSTALL.md) is required for GMT.jl
- ArgParse.jl
- Plots.jl
- ProgressMeter.jl

## Useage
```
usage: visualize_bathy.jl [-l] [-i IMAGE_TYPE] [-y] [-h] gridfile output_dir

positional arguments:
  gridfile              gridfile.dat
  output_dir            output directory

optional arguments:
  -l, --write_line      write line data
  -i, --image_type IMAGE_TYPE
                        output image type. png or svg 
                        (default: "png")
  -y, --yes_all         make output_dir if it dose not exist, 
                        and output files to output_dir.
  -h, --help            show this help message and exit
```

# convert_coordinates.jl
## required packages
- GMT.jl
- Proj4.jl
- ArgParse.jl

## useage
```
usage: convert_coordinate.jl [-h] input output in_EPSG out_EPSG grid_size xmin xmax ymin ymax

positional arguments:
  input       input grid file
  output      input grid file name
  in_EPSG     EPSG code of input grid (type: Int64)
  out_EPSG    EPSG code of output grid (type: Int64)
  grid_size   grid size of output grid.
  xmin        xmin of output grid (type: Float64)
  xmax        xmax of output grid (type: Float64)
  ymin        ymin of output grid (type: Float64)
  ymax        ymax of output grid (type: Float64)
  optional arguments:
  -h, --help  show this help message and exit
```
or read sample_convert_coordinate.ps1.


## example of EPSG code
EPSG code | meaning
----------|--------
4612      | JGD2000
6668      | JGD2011
6672      | 平面直角第4系(JGD2011)
2446      | 平面直角第4系(JGD2000)
6674      | 平面直角第6系(JGD2011)
2448      | 平面直角第6系(JGD2000)

[reference](http://tmizu23.hatenablog.com/entry/20091215/1260868350) (In Japanese)