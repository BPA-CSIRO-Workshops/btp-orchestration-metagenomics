#!/bin/bash

top_dir='/mnt/workshop'
data_sub_dir='data'
working_dir='working'
trainee_user='trainee'
sudoer_user='ubuntu'

cloud_storage_url_prefix='https://swift.rc.nectar.org.au:8888/v1/AUTH_809'

echo "Top level directory is: $top_dir"
if [ ! -e "$top_dir" ]; then
  echo "Creating top level directory: $top_dir"
  mkdir -p "$top_dir"
fi

# Create directory structure for data to be pulled from NeCTAR object storage
if [ ! -e "$top_dir/$data_sub_dir" ]; then
  echo "Creating raw data directory: $top_dir/$data_sub_dir"
  mkdir -p "$top_dir/$data_sub_dir"
else
  echo "Raw data directory already exists"
fi

if [ ! -e "$top_dir/$working_dir" ]; then
  echo "Creating working directory: $top_dir/$working_dir"
  mkdir -p "$top_dir/$working_dir"
else
  echo "Working directory already exists"
fi
if [ $(stat -c %U "$top_dir/$working_dir") != "$trainee_user" ]; then
  echo "Making working directory owned by $trainee_user"
  chown "$trainee_user" "$top_dir/$working_dir"
else
  echo "Working directory already owned by $trainee_user"
fi

if [[ ! -e "/home/${trainee_user}/Desktop" ]]; then
  mkdir --mode=755 /home/${trainee_user}/Desktop
  chown -R "$trainee_user:$trainee_user" /home/${trainee_user}/Desktop
fi

# function for downloading files from cloud storage
# call it like this:
# dl_file_from_cloud_storage $file
function dl_file_from_cloud_storage() {
  local url="$1"
  echo -n "    $url ... "
  
  http_status_code=$(curl $url --location --silent --remote-time -z $top_dir/$data_sub_dir/${url##*/} -o $top_dir/$data_sub_dir/${url##*/} --write-out %{http_code})
  if [[ "$http_status_code" == "304" ]]; then
    echo "SKIPPED - Local file is up-to-date"
  elif [[ "$http_status_code" == "200" ]]; then
    echo "DOWNLOADED"
  elif [[ "$http_status_code" == "404" ]]; then
    echo "FILE NOT FOUND"
  else
    echo "NOT SURE WHAT HTTP STATUS CODE $http_status_code MEANS"
  fi
}


###############
## QC Module ##
###############
module_dir='QC'
files=(
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataQC/bad_example.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataQC/good_example.fastq'
)
echo "Setting up module: $module_dir"
# Download the QC files from cloud object storage
echo "  Downloading data files ... "
cd "$top_dir/$data_sub_dir"
for file in "${files[@]}"
do
  dl_file_from_cloud_storage $file
done
# Setup working directory and symlinks as expected by the tutorial
echo -n "  Creating working directory $top_dir/$working_dir/$module_dir ... "
if [ ! -e "$top_dir/$working_dir/$module_dir" ]; then
  mkdir -p "$top_dir/$working_dir/$module_dir"
  echo "DONE"
  cd "$top_dir/$working_dir/$module_dir"
  ln -s $top_dir/$data_sub_dir/bad_example.fastq 
  ln -s $top_dir/$data_sub_dir/good_example.fastq

  # make tutorial paths sync with shorter paths used used in tutorials
  if [[ ! -e /home/$trainee_user/QC ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/QC"
  fi
  if [[ ! -e /home/$trainee_user/Desktop/QC ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/Desktop/QC"
  fi
else
  echo "Already exists"
fi
# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  chown -R "$trainee_user:$trainee_user" "$top_dir/$working_dir/$module_dir"
fi
####################


###############################
## Alignment/ChIP-seq Module ##
###############################
module_dir='ChIP-seq'
files=(
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataChIPSeq/Oct4.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataChIPSeq/gfp.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataChIPSeq/Oct4.bam'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataChIPSeq/gfp.bam'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataChIPSeq/mouse.mm10.genome'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataChIPSeq/mm10.fa'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataChIPSeq/PeakAnalyzer_1.4.tar.gz'
)
echo "Setting up module: $module_dir"
# Download the ChIP-seq files from cloud object storage
echo "  Downloading data files ... "
cd "$top_dir/$data_sub_dir"
for file in "${files[@]}"
do
  dl_file_from_cloud_storage $file
done
# Setup working directory and symlinks as expected by the tutorial
echo -n "  Creating working directory $top_dir/$working_dir/$module_dir ... "
if [ ! -e "$top_dir/$working_dir/$module_dir" ]; then
  mkdir -p "$top_dir/$working_dir/$module_dir"
  echo "DONE"
  cd "$top_dir/$working_dir/$module_dir"
  ln -s $top_dir/$data_sub_dir/Oct4.fastq
  ln -s $top_dir/$data_sub_dir/gfp.fastq
  tar -xzf $top_dir/$data_sub_dir/PeakAnalyzer_1.4.tar.gz
  mkdir -p "$top_dir/$working_dir/$module_dir/bowtie_index"
  cd "$top_dir/$working_dir/$module_dir/bowtie_index"
  ln -s $top_dir/$data_sub_dir/mm10.fa
  ln -s $top_dir/$data_sub_dir/mouse.mm10.genome
  mkdir -p "$top_dir/$working_dir/$module_dir/data"
  cd "$top_dir/$working_dir/$module_dir/data"
  ln -s $top_dir/$data_sub_dir/gfp.bam

  # make tutorial paths sync with shorter paths used used in tutorials
  if [[ ! -e /home/$trainee_user/ChIP-seq ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/ChIP-seq"
  fi
  if [[ ! -e /home/$trainee_user/Desktop/ChIP-seq ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/Desktop/ChIP-seq"
  fi
else
  echo "Already exists"
fi
# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  chown -R "$trainee_user:$trainee_user" "$top_dir/$working_dir/$module_dir"
fi
##########################


####################
## RNA-seq Module ##
####################
module_dir='RNA-seq'
files=(
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_1.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_2.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_1.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_2.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/Danio_rerio.Zv9.66.spliceSites'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/Danio_rerio.Zv9.66.gtf'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.1.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.2.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.3.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.4.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.rev.1.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.rev.2.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/Danio_rerio.Zv9.66.dna.fa'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/Danio_rerio.Zv9.66.dna.fa.fai'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/globalDiffExprs_Genes_qval.01_top100.tab'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_genes.fpkm_tracking'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_genes.fpkm_tracking'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_isoforms.fpkm_tracking'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_isoforms.fpkm_tracking'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_transcripts.gtf'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_transcripts.gtf'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/accepted_hits.bam'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/accepted_hits.sorted.bam'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/accepted_hits.sorted.bam.bai'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/junctions.bed'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/deletions.bed'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/insertions.bed'
)
echo "Setting up module: $module_dir"
# Download the RNA-seq files from cloud object storage
echo "  Downloading data files ... "
cd "$top_dir/$data_sub_dir"
for file in "${files[@]}"
do
  dl_file_from_cloud_storage $file
done
# Setup working directory and symlinks as expected by the tutorial
echo -n "  Creating working directory $top_dir/$working_dir/$module_dir ... "
if [ ! -e "$top_dir/$working_dir/$module_dir" ]; then
  mkdir -p "$top_dir/$working_dir/$module_dir"
  echo "DONE"
  cd $top_dir/$working_dir/$module_dir
  mkdir -p $top_dir/$working_dir/$module_dir/{data,annotation,genome}
  cd $top_dir/$working_dir/$module_dir/data
  ln -s $top_dir/$data_sub_dir/2cells_1.fastq
  ln -s $top_dir/$data_sub_dir/2cells_2.fastq
  ln -s $top_dir/$data_sub_dir/6h_1.fastq
  ln -s $top_dir/$data_sub_dir/6h_2.fastq
  cd $top_dir/$working_dir/$module_dir/annotation
  ln -s $top_dir/$data_sub_dir/Danio_rerio.Zv9.66.spliceSites
  ln -s $top_dir/$data_sub_dir/Danio_rerio.Zv9.66.gtf
  cd $top_dir/$working_dir/$module_dir/genome
  ln -s $top_dir/$data_sub_dir/ZV9.1.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.2.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.3.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.4.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.rev.1.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.rev.2.ebwt
  ln -s $top_dir/$data_sub_dir/Danio_rerio.Zv9.66.dna.fa
  ln -s $top_dir/$data_sub_dir/Danio_rerio.Zv9.66.dna.fa.fai
  mkdir -p $top_dir/$working_dir/$module_dir/{tophat,cufflinks,cuffdiff}
  cd $top_dir/$working_dir/$module_dir/cuffdiff
  ln -s $top_dir/$data_sub_dir/globalDiffExprs_Genes_qval.01_top100.tab
  mkdir -p $top_dir/$working_dir/$module_dir/cufflinks/{ZV9_2cells,ZV9_6h}_gtf_guided
  cd $top_dir/$working_dir/$module_dir/cufflinks/ZV9_2cells_gtf_guided
  ln -s $top_dir/$data_sub_dir/2cells_genes.fpkm_tracking genes.fpkm_tracking
  ln -s $top_dir/$data_sub_dir/2cells_isoforms.fpkm_tracking isoforms.fpkm_tracking
  ln -s $top_dir/$data_sub_dir/2cells_transcripts.gtf transcripts.gtf
  touch skipped.gtf
  cd $top_dir/$working_dir/$module_dir/cufflinks/ZV9_6h_gtf_guided
  ln -s $top_dir/$data_sub_dir/6h_genes.fpkm_tracking genes.fpkm_tracking
  ln -s $top_dir/$data_sub_dir/6h_isoforms.fpkm_tracking isoforms.fpkm_tracking
  ln -s $top_dir/$data_sub_dir/6h_transcripts.gtf transcripts.gtf
  touch skipped.gtf
  mkdir -p $top_dir/$working_dir/$module_dir/tophat/ZV9_2cells
  cd $top_dir/$working_dir/$module_dir/tophat/ZV9_2cells
  ln -s $top_dir/$data_sub_dir/accepted_hits.bam
  ln -s $top_dir/$data_sub_dir/accepted_hits.sorted.bam
  ln -s $top_dir/$data_sub_dir/accepted_hits.sorted.bam.bai
  ln -s $top_dir/$data_sub_dir/junctions.bed
  ln -s $top_dir/$data_sub_dir/deletions.bed
  ln -s $top_dir/$data_sub_dir/insertions.bed

  # make tutorial paths sync with shorter paths used by the EBI folks
  if [[ ! -e /home/$trainee_user/RNA-seq ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/RNA-seq"
  fi
  if [[ ! -e /home/$trainee_user/Desktop/RNA-seq ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/Desktop/RNA-seq"
  fi
else
  echo "Already exists"
fi

# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  chown -R "$trainee_user:$trainee_user" "$top_dir/$working_dir/$module_dir"
fi
#########################


#############################
## de novo assembly Module ##
#############################
module_dir='de_novo'
files=(
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/velvet_1.2.07.tgz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR022825.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR022823.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/s_aureus_mrsa252.EB1_s_aureus_mrsa252.dna.chromosome.Chromosome.fa.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR022852_1.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR022852_2.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR023408_1.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR023408_2.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR000892.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR000893.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR022863_1.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR022863_2.fastq.gz'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR023408_trim1.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataDeNovo/SRR023408_trim2.fastq'
)
echo "Setting up module: $module_dir"
# Download the de novo assembly files from cloud object storage
echo "  Downloading data files ... "
cd "$top_dir/$data_sub_dir"
for file in "${files[@]}"
do
  dl_file_from_cloud_storage $file
done
# Setup working directory and symlinks as expected by the tutorial
echo -n "  Creating working directory $top_dir/$working_dir/$module_dir ... "
if [ ! -e "$top_dir/$working_dir/$module_dir" ]; then
  mkdir -p "$top_dir/$working_dir/$module_dir"
  echo "DONE"
  cd "$top_dir/$working_dir/$module_dir"
  ln -s $top_dir/$data_sub_dir Data

  # make tutorial paths sync with shorter paths used by the EBI folks
  if [[ ! -e /home/$trainee_user/NGS ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/NGS"
  fi
  if [[ ! -e /home/$trainee_user/Desktop/NGS ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/Desktop/NGS"
  fi
else
  echo "Already exists"
fi
# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  chown -R "$trainee_user:$trainee_user" "$top_dir/$working_dir/$module_dir"
fi
##################################


#################################################
## Last thing to be run for the whole workshop ##
#################################################
chown -R "$sudoer_user:$sudoer_user" "$top_dir/$data_sub_dir"
