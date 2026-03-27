pwd=$(pwd)
pwd=$(pwd)
coverage_metadata=${pwd}/table/coverage_metadata.csv 
marker_region_metadata=${pwd}/table/mark_region.csv
pipeline_script=${pwd}/script/coverage_plot_main.sh

mkdir -p log
bsub -P coverage -J coverage -n 2 -R "rusage[mem=8GB]" -eo ./log/coverage.err -oo ./log/coverage.out "
sh ${pipeline_script} -m ${coverage_metadata} -r ${marker_region_metadata}
"