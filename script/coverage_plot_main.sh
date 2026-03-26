# Default values
# meta_data=/research/groups/ma1grp/home/zyu/work_2026/RNA_seq_3_March/Bulk_RNA_interactive_with_SV/table/coverage_track_plot/coverage_metadata.csv
# mark_region_meta=/research/groups/ma1grp/home/zyu/work_2026/RNA_seq_3_March/Bulk_RNA_interactive_with_SV/table/coverage_track_plot/mark_region.csv


# Parse command line arguments
while getopts "m:r:h" opt; do
    case $opt in
        m)
            meta_data="$OPTARG"
            ;;
        r)
            mark_region_meta="$OPTARG"
            ;;
        h)
            echo "Usage: $0 -m <metadata_file> -r <mark_region_file>"
            echo "  -m: Path to coverage metadata CSV file"
            echo "  -r: Path to mark region metadata CSV file"
            echo "  -h: Display this help message"
            exit 0
            ;;
        *)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$meta_data" ] || [ -z "$mark_region_meta" ]; then
    echo "Error: Both -m and -r options are required" >&2
    exit 1
fi


sample_name=$(tail -n 1 ${meta_data} | cut -d "," -f 1)
output_dir=$(tail -n 1 ${meta_data} | cut -d "," -f 2)
output_path=${output_dir}/${sample_name}/coverage_plot
normalization_method=$(tail -n +2 ${meta_data} | cut -d "," -f 6 | sort | uniq)
bin_size=$(tail -n +2 ${meta_data} | cut -d "," -f 7 | sort | uniq)

#=================================================================
#+++++++++++++++++++++++Step 1 bamCoverage +++++++++++++++++++++++
#=================================================================
mkdir -p ${output_path}/1_bamCoverage
cd ${output_path}/1_bamCoverage

tail -n +2 ${meta_data} | cut -d "," -f 3,4 | while read line;
do
bamfile=$(echo $line | cut -d "," -f 1)
sample_name=$(echo $line | cut -d "," -f 2)
echo ">>>The input bamfile: ${bamfile} <<<."
echo ">>>The sample name: ${sample_name} <<<"
bamCoverage -b ${bamfile} -o ${sample_name}.bw --normalizeUsing ${normalization_method} --binSize ${bin_size} --ignoreDuplicates 
done


#=================================================================
#+++++++++++++++++++++++Step 2 visualisation bamfiles ++++++++++++
#=================================================================
mkdir -p ${output_path}/2_visualization
cd ${output_path}/2_visualization

ln -s ${output_path}/1_bamCoverage/*.bw ./

#>>>>>> Step 2.1 global analysis <<<<<<<
bamfile=$(tail -n 1 ${meta_data} | cut -d "," -f 3)
samtools view -H ${bamfile} | grep '^@SQ' > ref_info.txt

# Generate the tracks_all.ini file for pyGenomeTracks
if [ -f tracks_all.ini ]; then
    rm tracks_all.ini
fi

touch tracks_all.ini
tail -n +2 ${meta_data} | cut -d "," -f 4,5,8,9,10,11 | while read line;
do
sample_name=$(echo $line | cut -d "," -f 1)
group=$(echo $line | cut -d "," -f 2)
color=$(echo $line | cut -d "," -f 3)
height=$(echo $line | cut -d "," -f 4)
max_value=$(echo $line | cut -d "," -f 5)
min_value=$(echo $line | cut -d "," -f 6)
title="${group}_${sample_name}"
echo -e "[${sample_name}]\nfile = ${sample_name}.bw\ntitle = ${title}\ncolor = ${color}\nheight = ${height}\nmax_value = ${max_value}\nmin_value = ${min_value}\n" >> tracks_all.ini
done

echo -e "[x-axis]\nwhere = bottom\nheight = 0.7\nfontsize = 12\nnumber_of_ticks = 9" >> tracks_all.ini
echo -e "[regions]\nfile = region.bed\ncolor = red\nheight = 1\ncolor=grey\ndisplay = collapsed\nlabels = on\nfontsize = 8" >> tracks_all.ini

# Generate the region.bed file for pyGenomeTracks
if [ -f region.bed ]; then
    rm region.bed
fi
cat ${mark_region_meta} | tail -n +2 | cut -d "," -f 2,3,4,5 | while read line;
do
region_name=$(echo $line | cut -d "," -f 1)
ref_id=$(echo $line | cut -d "," -f 2)
start=$(echo $line | cut -d "," -f 3)
end=$(echo $line | cut -d "," -f 4)
echo -e "${ref_id}\t${start}\t${end}\t${region_name}" >> region.bed
done

mkdir -p global_plot
cat ref_info.txt | awk -F "\t" '{print $2 "," $3}' | while read line;
do
ref_id=$(echo "$line" | cut -d "," -f 1 |cut -d ":" -f 2)
length=$(echo "$line" | cut -d "," -f 2 |cut -d ":" -f 2)
# echo ">>>The reference id: ${ref_id} <<<."
# echo ">>>The reference length: ${length} <<<."
pyGenomeTracks --tracks tracks_all.ini --region ${ref_id}:1-${length} --dpi 300 --outFileName global_plot/${ref_id}_global.pdf
done


#>>>>>> Step 2.2 zoom in each region <<<<<<<
mkdir -p zoomin_plot

cat ${mark_region_meta} | tail -n +2 | cut -d "," -f 2,3,4,5,7,8 | while read line;
do
region_name=$(echo "$line" | cut -d "," -f 1)
ref_id=$(echo "$line" | cut -d "," -f 2)
start=$(echo "$line" | cut -d "," -f 3)
end=$(echo "$line" | cut -d "," -f 4)
Zoomin_left=$(echo "$line" | cut -d "," -f 5 | tr -d "\r")
Zoomin_right=$(echo "$line" | cut -d "," -f 6 | tr -d "\r")
left_position=$((start - Zoomin_left))
right_position=$((end + Zoomin_right))
pyGenomeTracks --tracks tracks_all.ini --region ${ref_id}:${left_position}-${right_position} --dpi 300 --outFileName zoomin_plot/${region_name}.pdf
done

mkdir -p log
mv *.* log/
