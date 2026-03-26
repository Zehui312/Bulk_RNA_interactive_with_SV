pwd=$(pwd)
pwd=$(pwd)
circos_metadata=${pwd}/table/circle_metadata.csv
marker_region_metadata=${pwd}/table/mark_region.csv
pipeline_script=${pwd}/script/circle_plot_main.sh

mkdir -p log
bsub -P coverage -J coverage -n 2 -R "rusage[mem=8GB]" -eo ./log/coverage.err -oo ./log/coverage.out "
sh ${pipeline_script} -m ${circos_metadata} -r ${marker_region_metadata}
"