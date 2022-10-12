import glob

######################
# Setup Variables
######################

fastq_input = glob.glob('raw_data/**/*.fastq')
fastqc_output = []
for filename in fastq_input:
    new_filename = filename.split('.')[0] + '_fastqc.html'
    new_filename = new_filename.replace('raw_data', 'processed_data/fastqc')
    fastqc_output.append(new_filename)

fastq_paired_deduped = []
for filename in fastq_input:
    new_filename = filename.replace('raw_data', 'processed_data/deduped_reads')
    new_filename = new_filename.replace('.fastq', '_deduped.fastq.paired.fq')
    fastq_paired_deduped.append(new_filename)

multiqc_output =  "processed_data/fastqc/sample_fastq/multiqc_report.html"

print(fastq_paired_deduped)

######################
# Rules
######################

rule all:
    input:
        multiqc_output,
        fastq_paired_deduped

rule clean:
    shell:
        """
        rm -r ./processed_data/*
        """

rule run_fastqc:
    input:
        "raw_data/sample_fastq/{sample}.fastq"
    output:
        "processed_data/fastqc/sample_fastq/{sample}_fastqc.html",
        "processed_data/fastqc/sample_fastq/{sample}_fastqc.zip"
    shell:
        "fastqc -o ./processed_data/fastqc/sample_fastq/ {input}"

rule run_multiqc:
    input:
        fastqc_output
    output:
        "processed_data/fastqc/sample_fastq/multiqc_report.html"
    shell:
        "multiqc -o processed_data/fastqc/sample_fastq/ processed_data/fastqc/sample_fastq"

rule run_trim:
    input:
        "raw_data/sample_fastq/{sample}_R1_001.fastq",
        "raw_data/sample_fastq/{sample}_R2_001.fastq"
    output:
        "processed_data/trimmed_reads/sample_fastq/{sample}_R1_001_val_1.fq",
        "processed_data/trimmed_reads/sample_fastq/{sample}_R2_001_val_2.fq"
    shell:
	    "trim_galore --paired --small_rna --dont_gzip --output_dir processed_data/trimmed_reads/sample_fastq/ {input}"

rule run_dedup:
    input:
        "processed_data/trimmed_reads/sample_fastq/{sample}_R{direction}_001_val_{direction}.fq"
    output:
        "processed_data/deduped_reads/sample_fastq/{sample}_R{direction}_001_deduped.fastq"
    shell:
	    "seqkit rmdup -s -o {output} {input}"

rule run_pair:
    input:
        "processed_data/deduped_reads/sample_fastq/{sample}_R1_001_deduped.fastq",
        "processed_data/deduped_reads/sample_fastq/{sample}_R2_001_deduped.fastq"
    output:
        "processed_data/deduped_reads/sample_fastq/{sample}_R1_001_deduped.fastq.paired.fq",
        "processed_data/deduped_reads/sample_fastq/{sample}_R2_001_deduped.fastq.paired.fq"
    shell:
        "fastq_pair {input}"

# rule get_genomes:

rule prealignment:
    input:
    ouput:
    shell:

rule alignment:
