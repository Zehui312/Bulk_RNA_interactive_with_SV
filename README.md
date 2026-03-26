
This is a Pipeline to visualize Interactive between SV and RNA-seq. First, run the [Bulk_RNA_for_Long_reads](https://github.com/Zehui312/Bulk_RNA_for_Long_reads) pipeline to generate BAM files in the `5_total_stat` directory.

**Features:**
- Feature quantification (`featureCounts`)
- Differential expression analysis (`DESeq2`)
- Visualization (PCA + Volcano plots)

---


## 1. 💡 Workflow

<img src="/img/workflow.png" width="500">



## 2. ⚙️ Create Environment

Use the same environment as [Bulk_RNA_for_Long_reads](https://github.com/Zehui312/Bulk_RNA_for_Long_reads).

```
conda activate bulk_ont
```