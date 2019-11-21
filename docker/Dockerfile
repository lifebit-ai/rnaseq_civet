FROM nfcore/base

LABEL authors="phil@lifebit.ai" \
      description="Docker image for rnaseq_civet pipeline"

RUN pip install bz2file
RUN conda install -c bioconda samtools==1.9 && \
    conda install -c bioconda bowtie2==2.3.5 && \
    conda install -c bioconda rsem==1.3.2