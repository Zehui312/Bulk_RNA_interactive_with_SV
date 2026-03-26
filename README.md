
This is a Pipeline to visualize Interactive between SV and RNA-seq. You need run the [Bulk_RNA_for_Long_reads](https://github.com/Zehui312/Bulk_RNA_for_Long_reads), [Bulk_RNA_Visualization_Deseq2](https://github.com/Zehui312/Bulk_RNA_Visualization_Deseq2) and [Bacterial_SV_pipeline](https://github.com/Zehui312/Bacterial_SV_pipeline) 

**Features:**
- Circle plot
- Coverage track plot

---

## 1. 💡 Workflow

<img src="/img/workflow.png" width="500">

| Input | Source |
|-------|--------|
| Bam file | After running [Bulk_RNA_for_Long_reads](https://github.com/Zehui312/Bulk_RNA_for_Long_reads) |
| Deseq2 result table | After running [Bulk_RNA_Visualization_Deseq2](https://github.com/Zehui312/Bulk_RNA_Visualization_Deseq2) |
| SV location table | After running [Bacterial_SV_pipeline](https://github.com/Zehui312/Bacterial_SV_pipeline) |

## 2. ⚙️ Create Environment

Use the same environment as [Bulk_RNA_for_Long_reads](https://github.com/Zehui312/Bulk_RNA_for_Long_reads).

```
conda activate bulk_ont
```

## 3-1. 📂 Fill mark_region.csv

| Column | Description |
|--------|-------------|
| Reference | Reference genome |
| Region_label | Custom name for the region |
| Chromosom | Contig containing structural variation |
| start | Start location of structural variation |
| end | End location of structural variation |
| type | Type of structural variation (e.g., TRA, INV, DUP) |
| Zoomin_left | Left zoom distance for coverage track plot |
| Zoomin_right | Right zoom distance for coverage track plot |

## 3-2. 📂 Fill circle_metadata.csv

| Column | Description |
|--------|-------------|
| sample_name | Project name |
| Output_path | Output directory path |
| Output_name | Output file name |
| Ref_gff_path | Path to reference GFF file |
| Deseq2_result_path | Path to DESeq2 results |
| p_value_cutoff | P-value threshold |
| log2fc_cutoff | Log2 fold-change threshold |
| showing_contig | Contig to display |

## 3-3. 📂 Fill coverage_metadata.csv


| Column | Description |
|--------|-------------|
| sample_name | Project name |
| Output | Output directory path |
| Bam_file_path | Path to BAM file |
| Sample_ID | Sample identifier |
| Group | Sample group/condition |
| normalizeUsing | Normalization method (bamCoverage paramter) |
| binSize | Bin size for coverage track (bamCoverage paramter)|
| color | Track color |
| height | Track height |
| max_value | Maximum value for y-axis |
| min_value | Minimum value for y-axis |


## 🚀 4. Usage

After filling all metadata, run:

```bash
bash run_circle_plot_pipeline.sh 
```

```bash
bash run_coverage_plot_pipeline.sh
```