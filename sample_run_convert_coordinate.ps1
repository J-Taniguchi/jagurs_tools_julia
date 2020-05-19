$input = "A.grd"
$output = "B.grd=cf"
$inEPSG = 2446
$outEPSG = 4612

$grid_size = "18s"
$xmin = 134
$xmax = 137
$ymin = 33
$ymax = 35

julia ./convert_coordinate/convert_coordinate.jl $input $output $inEPSG $outEPSG $grid_size $xmin $xmax $ymin $ymax