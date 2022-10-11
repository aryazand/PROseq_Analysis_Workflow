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

fastq_trimmed = []
for filename in fastq_input:
    new_filename = filename.replace('raw_data', 'processed_data/trimmed_reads')
    new_filename = new_filename.replace('R1_001.fastq', 'R1_001_val_1.fq')
    new_filename = new_filename.replace('R2_001.fastq', 'R2_001_val_2.fq')
    fastq_trimmed.append(new_filename)

multiqc_output =  "processed_data/fastqc/sample_fastq/multiqc_report.html",

######################
# Rules
######################

rule all:
    input:
        multiqc_output,
        fastq_trimmed

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
	    """
        trim_galore --paired --small_rna --dont_gzip --output_dir processed_data/trimmed_reads/sample_fastq/ {input}
        """
