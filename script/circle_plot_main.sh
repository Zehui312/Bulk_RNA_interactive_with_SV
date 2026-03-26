#!/bin/bash
pwd=$(pwd)
# Set default circos config if not provided

# Parse command line arguments
while getopts "m:r:" opt; do
    case $opt in
        m) circos_metadata="$OPTARG" ;;
        r) marker_region_metadata="$OPTARG" ;;
        *) echo "Usage: $0 -m circos_metadata -r marker_region_metadata"; exit 1 ;;
    esac
done

# Validate required arguments
if [ -z "$circos_metadata" ] || [ -z "$marker_region_metadata" ]; then
    echo "Error: Both -m and -r options are required" >&2
    exit 1
fi


sample_name=$(tail -n +2 ${circos_metadata} | cut -d "," -f1| tr -d " "|sort |uniq)
output_dir=$(tail -n +2 ${circos_metadata} | cut -d "," -f2| tr -d " "| sort |uniq)
ref_gff_path=$(tail -n +2 ${circos_metadata} | cut -d "," -f4| tr -d " "| sort |uniq)
echo ">>>>>> Starting circle plot pipeline <<<<<<"
echo "#sample_name: $sample_name"
echo "#output_dir: $output_dir"
echo "#ref_gff_path: $ref_gff_path"
echo "==>>>>>> Starting circle plot pipeline <<<<<<"
output_path=${output_dir}/${sample_name}/circle_plot
data_path=${pwd}/data
circos_config=${pwd}/data/circos.conf

if [ ! -d "${output_path}" ]; then
    mkdir -p ${output_path}
fi


#=================================================================
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# >>>>>>>>>>>>>> Start of the pipeline for one sample <<<<<<<<<<<<
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#=================================================================
cat $circos_metadata | grep -v "sample_name" |  while read line;
do 
output_name=$(echo $line | cut -d "," -f3| tr -d " "|tr -d "\r")
ref_gff_path=$(echo $line | cut -d "," -f4| tr -d " "|tr -d "\r")
DEseq2_result=$(echo $line | cut -d "," -f5| tr -d " "|tr -d "\r")
p_value_cutoff=$(echo $line | cut -d "," -f6| tr -d " "|tr -d "\r")
log2fc_cutoff=$(echo $line | cut -d "," -f7| tr -d " "|tr -d "\r")
showing_contig=$(echo $line | cut -d "," -f8| tr -d " "|tr -d "\r")
echo "output_name: $output_name"
echo "ref_gff_path: $ref_gff_path"
echo "DEseq2_result: $DEseq2_result"
echo "p_value_cutoff: $p_value_cutoff"
echo "log2fc_cutoff: $log2fc_cutoff"
echo "showing_contig: $showing_contig"

#=================================================================
#+++++++++++++++++++++++Step 1 OriC Position+++++++++++++++++++++++
#=================================================================


cat ${ref_gff_path} | grep "origin of replication"|grep ${showing_contig} | awk -F "\t" -v OFS=" " -v ref="$ref_name"  '
{
    contig = $1
    start = $4
    end = $5
    print contig, start, end, "fill_color=orange"
}' > ${data_path}/${output_name}_oriC.txt


#=================================================================
#+++++++++++++++++++++++Step 2 log2 and P-value+++++++++++++++++++
#=================================================================

csvcut -c seqnames,start,end,log2FoldChange $DEseq2_result  |grep -E $(echo $showing_contig | tr "," "|") | sed 's/,/ /g' > ${data_path}/${output_name}_log2fc.txt
csvcut -c seqnames,start,end,padj,log2FoldChange "$DEseq2_result" \
| csvgrep -c seqnames -r $(echo $showing_contig | tr "," "|") \
| awk -F',' -v pcut="$p_value_cutoff" -v fccut="$log2fc_cutoff" '
NR==1{next}  # skip header
{
  seq=$1; start=$2; end=$3; p=$4; fc=$5
  if (p < pcut && fc > fccut)      print seq, start, end, "fill_color=red"
  else if (p < pcut && fc < -fccut) print seq, start, end, "fill_color=green"
}' > ${data_path}/${output_name}_sig.txt

#=================================================================
#+++++++++++++++++++++++Step 3 SV region and labels+++++++++++++++
#=================================================================
if [ -f "${data_path}/${output_name}_sv.txt" ]; then
    rm ${data_path}/${output_name}_sv.txt
    rm ${data_path}/${output_name}_sv_labels.txt
fi
touch ${data_path}/${output_name}_sv.txt
touch ${data_path}/${output_name}_sv_labels.txt

cat ${marker_region_metadata} | grep ${showing_contig} |  while read line;
do
region_name=$(echo $line | cut -d "," -f 2)
contig_id=$(echo $line | cut -d "," -f 3)
start=$(echo $line | cut -d "," -f 4)
end=$(echo $line | cut -d "," -f 5)
sv_type=$(echo $line | cut -d "," -f 6)
echo -e "${contig_id} ${start} ${end} fill_color=black" >> ${data_path}/${output_name}_sv.txt
echo -e "${contig_id} ${start} ${end} ${region_name}_${sv_type}" >> ${data_path}/${output_name}_sv_labels.txt
done
#=================================================================
#+++++++++++++++++++++++Step 3 change  circos.conf +++++++++++++++
#=================================================================
sed "s|output_path|${output_path}|g" ${circos_config} >${data_path}/${output_name}-circos.conf
sed -i "s/file_name/${output_name}/g" ${data_path}/${output_name}-circos.conf
sed -i "s/P_value_file.txt/${output_name}_sig.txt/g" ${data_path}/${output_name}-circos.conf
sed -i "s/log2fc_file.txt/${output_name}_log2fc.txt/g" ${data_path}/${output_name}-circos.conf
sed -i "s/oric_ter_file.txt/${output_name}_oriC.txt/g" ${data_path}/${output_name}-circos.conf
sed -i "s/Region_sv_file.txt/${output_name}_sv.txt/g" ${data_path}/${output_name}-circos.conf
sed -i "s/sv_labels_file.txt/${output_name}_sv_labels.txt/g" ${data_path}/${output_name}-circos.conf
#=================================================================
#+++++++++++++++++++++++Step 3 Karyotype ++++++++++++++++++++++++
#=================================================================

grep "sequence-region" ${ref_gff_path} |grep ${showing_contig} | awk -F " " -v OFS=" " -v ref="$ref_name"  '
{
    contig = $2
    start = 0
    end = $4
    print "chr - " contig, contig, start, end, "blue"
}' > ${data_path}/${output_name}_karyotype.txt

sed -i "s/karyotype_file.txt/${output_name}_karyotype.txt/g" ${data_path}/${output_name}-circos.conf


circos -conf ${data_path}/${output_name}-circos.conf

done