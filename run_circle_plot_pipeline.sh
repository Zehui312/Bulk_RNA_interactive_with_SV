pwd=$(pwd)
meta_data=${pwd}/table/circle_metadata.csv
mark_region_meta=${pwd}/table/mark_region.csv
pipeline_script=${pwd}/script/circle_plot_main.sh

mkdir -p log
bsub -P coverage -J coverage -n 2 -R "rusage[mem=8GB]" -eo ./log/coverage.err -oo ./log/coverage.out "
sh ${pipeline_script} -m ${meta_data} -r ${mark_region_meta}
"