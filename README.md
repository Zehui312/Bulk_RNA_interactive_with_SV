
This is a pipeline for visualizing interactions between structural variants (SVs) and RNA-seq data. You must first run the [Bulk_RNA_for_Long_reads](https://github.com/Zehui312/Bulk_RNA_for_Long_reads), [Bulk_RNA_Visualization_Deseq2](https://github.com/Zehui312/Bulk_RNA_Visualization_Deseq2), and [Bacterial_SV_pipeline](https://github.com/Zehui312/Bacterial_SV_pipeline) pipelines.

**Features:**
- Circle plot
- Coverage track plot

---

## 1. 💡 Workflow

<img src="/img/workflow.png" width="500">

| Input | Source |
|-------|--------|
| BAM file | Output from [Bulk_RNA_for_Long_reads](https://github.com/Zehui312/Bulk_RNA_for_Long_reads) |
| DESeq2 results | Output from [Bulk_RNA_Visualization_Deseq2](https://github.com/Zehui312/Bulk_RNA_Visualization_Deseq2) |
| SV locations | Output from [Bacterial_SV_pipeline](https://github.com/Zehui312/Bacterial_SV_pipeline) |

## 2. ⚙️ Create Environment

Use the same environment as [Bulk_RNA_for_Long_reads](https://github.com/Zehui312/Bulk_RNA_for_Long_reads):

```
conda activate bulk_ont
```

## 3-1. 📂 Fill mark_region.csv

| Column | Description |
|--------|-------------|
| Reference | Reference genome |
| Region_label | Custom region name |
| Chromosome | Contig containing the structural variation |
| start | Start position of the structural variation |
| end | End position of the structural variation |
| type | Structural variation type (e.g., TRA, INV, DUP) |
| Zoomin_left | Left zoom distance for coverage track |
| Zoomin_right | Right zoom distance for coverage track |

## 3-2. 📂 Fill circle_metadata.csv

| Column | Description |
|--------|-------------|
| sample_name | Project name |
| Output_path | Output directory |
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
| Output | Output directory |
| Bam_file_path | Path to BAM file |
| Sample_ID | Sample identifier |
| Group | Sample group or condition |
| normalizeUsing | Normalization method (bamCoverage parameter) |
| binSize | Bin size for coverage track (bamCoverage parameter) |
| color | Track color |
| height | Track height |
| max_value | Maximum y-axis value |
| min_value | Minimum y-axis value |

## 🚀 4. Usage

After filling all metadata files, run:

```bash
bash run_circle_plot_pipeline.sh 
```

```bash
bash run_coverage_plot_pipeline.sh
```

