

process dataset_genome {
    label "small"

    input:
    val genome
    
    output:
    path "${genome}.fasta"

    stub:
    """
    touch ${genome}.fasta
    """

    script:
    """
    if [ ! \$(which datasets) ]; then 
        if [[ "\$OSTYPE" == "linux-gnu"* ]]; then
            curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets' 
        elif [[ "\$OSTYPE" == "darwin"* ]]; then
                # Mac OSX
            curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/mac/datasets' 
        elif [[ "\$OSTYPE" == "cygwin" ]]; then
            curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets' 
        fi
        chmod a+x ./datasets
        ./datasets download genome accession ${genome}
    else
        datasets download genome accession ${genome}
    fi && \
    7za x ncbi_dataset.zip && \
    cat ncbi_dataset/data/${genome}/*.fna > ${genome}.fasta && rm -rf ncbi_dataset*
    """
}
