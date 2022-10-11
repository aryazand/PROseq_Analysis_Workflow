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

print(fastqc_output)

######################
# Rules
######################

rule all:
  input:
    "processed_data/fastqc/sample_fastq/multiqc_report.html"

rule clean:
  shell:
    "rm -f {fastqc_output} multiqc_report.html"

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
