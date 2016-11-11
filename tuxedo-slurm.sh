#!/bin/bash

"This script needs to run form inside the folder scripts in a working project with the following structure:
project/scripts
project/raw_data


Raw data needs to be labeled in the following fashion:

Sample_serial-Folder-Line-Time_point/day_of_life(day_post_Treament)-treament-REPlicate-READ

and with the exact number of characters as in the example bellow:

S_001-F_HaTS-L____N2-__0-____-REP_1-READ_1.fastq.gz

S_XXX-F_XXXX-L_XXXXX-XXX-XXXX-REP_X-READ_x.fastq.gz

Please notice that for paired samples, the S_XXX is the same.


Make sure you have edited the last section of this script - cuffdiff - before you execute this script." > /dev/null 2>&1


#############################################################################

# Define series as SE or PE and stranded or unstranded

SE_unstr=("YiTS" "YiDR" "YiIS" "ShTe")
SE_str=("Yid1" "OeDA" "AgMi")
PE_str=("RoSt" "HaTS" "HaIS")
PE_uns=("XHFC")
mix=("Yid3")

unstr=("YiTS" "YiDR" "YiIS" "ShTe" "XHFC")
str=("Yid1" "OeDA" "RoSt" "HaTS" "HaIS" "AgMi" )
#mix=("Yid3")


# Which series do you which to work on:

series="HaIS"

# Reference genome

ann=/draco/u/jboucas/genomes/caenorhabditis_elegans/85
ori_GTF=$(readlink -f ${ann}/original.gtf)
hisat_index=${ann}/toplevel_hisat2/index.fa
adapters_file=/draco/u/jboucas/test/TruSeqAdapters.txt
genome=${ann}/toplevel_hisat2/index.fa


#############################################################################


echo "Creating required folders"
mkdir -p ../slurm_logs
mkdir -p ../fastqc_output
mkdir -p ../tmp
mkdir -p ../skewer_output
mkdir -p ../hisat_output
mkdir -p ../stringtie_output
mkdir -p ../cuffmerge_output
mkdir -p ../cuffdiff_output
mkdir -p ../cuffquant_output


top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw_data)/
rawt=$(readlink -f ../skewer_output)/
merg=$(readlink -f ../cuffmerge_output)/ 
qua=$(readlink -f ../cuffquant_output)/ 



# Required function

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

#############################################################################

echo "Starting FASTQC"

ids=

cd ${raw} 
for serie in $series; do
    cd ${raw}
    for file in $(ls *${serie}*.fastq.gz); do 
        echo "#!/bin/bash
        module load pigz
        module load fastqc
        cp ${raw}${file} ${tmp}
        cd ${tmp}
        unpigz -p 4 ${file}
        # FASTQC call
        fastqc -t 4 -o ../fastqc_output ${file%.gz}
        rm ${tmp}fastqc_${file%.fastq.gz}.sh
        " > ${tmp}fastqc_${file%.fastq.gz}.sh

        cd ${tmp} 
        chmod 755 ${tmp}fastqc_${file%.fastq.gz}.sh 
        rm -f ../slurm_logs/fastqc_${file%.fastq.gz}.*.out  
        id=$(sbatch -p short --cpus-per-task=4 --mem=8gb -t 30 -o ../slurm_logs/fastqc_${file%.fastq.gz}.%j.out ${tmp}fastqc_${file%.fastq.gz}.sh)
        ids=${ids}:${id:20}
    done
done

echo "Waiting for FASTQC jobs${ids} to complete"
srun -d afterok${ids} echo "FASTQC done. Starting skewer."

#############################################################################

ids=

cd ${raw}
for serie in $series; do
    cd ${raw}
    for file in $(ls S_160*${serie}*1.fastq.gz); do
        cd ${raw}
        if [[ -e ${file%1.fastq.gz}2.fastq.gz ]]; then
            echo "#!/bin/bash 
            module load pigz
            module load skewer

            # skewer call for paired end reads
 
	    skewer -y ${adapters_file} -m pe \
 	    -q 20 -n -u -t 18 ${tmp}${file%1.fastq.gz}1.fastq ${tmp}${file%1.fastq.gz}2.fastq
	    
            cd ${top}skewer_output
            
            mv ${tmp}${file%1.fastq.gz}-trimmed-pair1.fastq ${rawt}${file%1.fastq.gz}1.fastq
            mv ${tmp}${file%1.fastq.gz}-trimmed-pair2.fastq ${rawt}${file%1.fastq.gz}2.fastq 

            pigz -p 18 ${file%1.fastq.gz}1.fastq
            pigz -p 18 ${file%1.fastq.gz}2.fastq

            rm ${tmp}skewer_${file%-READ_1.fastq.gz}.sh
            " > ${tmp}skewer_${file%-READ_1.fastq.gz}.sh
        else
            echo "#!/bin/bash
            module load pigz
            module load skewer

            # skewer call for single end reads

            mv ${tmp}${file%1.fastq.gz}-trimmed-pair1.fastq ${rawt}${file%1.fastq.gz}1.fastq

	    skewer -x ${adapters_file} -m any \ 
	    -q 20 -n -u -t 18 ${tmp}${file%1.fastq.gz}1.fastq
           
	    cd ${top}skewer_output
            pigz -p 18 ${file%.gz}
            rm ${tmp}skewer_${file%-READ_1.fastq.gz}.sh
            " > ${tmp}skewer_${file%-READ_1fastq.gz}.sh

        fi
    cd ${tmp}
    chmod 755 ${tmp}skewer_${file%-READ_1.fastq.gz}.sh
    rm -f ../slurm_logs/skewer_${file%-READ_1.fastq.gz}.*.out  
    id=$(sbatch -p short --cpus-per-task=18 --mem=36gb -o ../slurm_logs/skewer_${file%-READ_1.fastq.gz}.%j.out ${tmp}skewer_${file%-READ_1.fastq.gz}.sh)
    ids=${ids}:${id:20}    
    done
done
exit
echo "Waiting for Flexbar jobs${ids} to complete"
srun -d afterok${ids} echo "skewer done. Starting HiSat and StringTie"

#############################################################################

ids=

cd ${rawt}
for serie in $series; do
    cd ${rawt}
    for file in $(ls *${serie}*1.fastq.gz); do
        
        # Libraries and paired end vs. single end settings for HISAT    
 
        if [[ $(contains "${SE_unstr[@]}" "$serie") == "y" ]]; then
            lib=
            files="-U ${file}"
        elif [[ $(contains "${PE_uns[@]}" "$serie") == "y" ]]; then
            lib=
            files="-1 ${file} -2 ${file%1.fastq.gz}2.fastq.gz"
        elif [[ $(contains "${SE_str[@]}" "$serie") == "y" ]]; then
            lib="--rna-strandness R"
            files="-U ${file}"
        elif [[ $(contains "${PE_str[@]}" "$serie") == "y" ]]; then
            lib="--rna-strandness RF"
            files="-1 ${file} -2 ${file%1.fastq.gz}2.fastq.gz"
        elif [[ $(contains "${mix[@]}" "$serie") == "y" ]]; then
            files=-U ${file}
            REP=${file:30:5}
            if [[ ${REP} == REP_3 ]]; then
                lib="--rna-strandness R"
            else
                lib=
            fi
        fi

        echo "#!/bin/bash
        cd ${rawt}
        module load bowtie
        module load hisat

        # HISAT call 

        hisat2 -p 18 ${lib} --dta-cufflinks --met-file ${top}hisat_output/${file%%-READ_1.fastq.gz}.stats \
        -x ${hisat_index} -S ${top}hisat_output/${file%-READ_1.fastq.gz}.sam \
        ${files}

        cd ${top}hisat_output
        module load samtools
        
        # Use samtools to select mapped reads and sort them

        samtools view -@ 18 -bhS -F 4 ${file%-READ_1.fastq.gz}.sam | samtools sort -@ 18 -o ${file%-READ_1.fastq.gz}.bam -
        mkdir -p ${top}stringtie_output/${file%-READ_1.fastq.gz}

        module load stringtie

        # StringTie call

        stringtie ${file%-READ_1.fastq.gz}.bam -o ${top}stringtie_output/${file%-READ_1.fastq.gz}.gtf \
        -p 18 -G ${ori_GTF} -f 0.99 \
        -C ${top}stringtie_output/${file%-READ_1.fastq.gz}_full_cov.gtf \
        -b ${top}stringtie_output/${file%-READ_1.fastq.gz} 
        rm ${tmp}HS_ST_${file%-READ_1.fastq.gz}.sh
        " > ${tmp}HS_ST_${file%-READ_1.fastq.gz}.sh

        cd ${tmp}
        chmod 755 ${tmp}HS_ST_${file%-READ_1.fastq.gz}.sh 
        rm -f ../slurm_logs/HS_ST_${file%-READ_1.fastq.gz}.*.out
        id=$(sbatch -p general --cpus-per-task=18 --mem=36gb -t 8:00:00  -o ../slurm_logs/HS_ST_${file%-READ_1.fastq.gz}.%j.out ${tmp}HS_ST_${file%-READ_1.fastq.gz}.sh)
        ids=${ids}:${id:20}
    done
done

echo "Waiting for HISAT and StringTie jobs${ids} to complete"
srun -d afterok${ids} echo "HiSat and StringTie done. Starting cuffmerge"
 
#############################################################################

for serie in $series; do
    rm ${tmp}assemblies_${serie}.txt

    cd ${top}stringtie_output
    mkdir -p full_coverage
    mv *_full_cov.gtf full_coverage
    
    # Select only transcripts which have full coverage

    cd full_coverage
    for gtf in $(ls *${serie}*.gtf); do
        readlink -f ${gtf} >> ${tmp}assemblies_${serie}.txt
    done

    cd ${top}
    mkdir -p cuffmerge_output/${serie}
    cmout=$(readlink -f cuffmerge_output/${serie})/
    echo ${serie}

    cd ${top}
    module load cufflinks
    
    # Cuffmerge call

    srun --cpus-per-task=2 cuffmerge -p 2 \
    -o ${cmout} --min-isoform-fraction 1.0 \
    -g ${ori_GTF} -s ${genome} ${tmp}assemblies_${serie}.txt
done

cd ${tmp}
cd ../scripts

#############################################################################

echo "Starting cuffquant"

ids=

for serie in $series; do

    # Library settings for cuffquant

    if [[ $(contains "${unstr[@]}" "$serie") == "y" ]]; then
        lib="fr-unstranded"
    elif [[ $(contains "${str[@]}" "$serie") == "y" ]]; then
        lib="fr-firststrand"
    elif [[ $(contains "${mix[@]}" "$serie") == "y" ]]; then
        lib="fr-unstranded"
    fi

    cd ${top}hisat_output
    for file in $(ls *${serie}*.bam); do 
        echo "#!/bin/bash
        cd ${top}cuffquant_output
        mkdir -p ${serie}
        cd ${serie}
        module load cufflinks

        # Cuffquant call

        cuffquant -p 18 --library-type ${lib} \
        -o ${file%.bam} \
        ${top}cuffmerge_output/${serie}/merged.gtf \
        ${top}hisat_output/${file}
        rm ${tmp}quant_${file%.bam}.sh
        " > ${tmp}quant_${file%.bam}.sh
        cd ${tmp}
        chmod 755 ${tmp}quant_${file%.bam}.sh
        rm -f ../slurm_logs/quant_${file%.bam}.*.out  
        id=$(sbatch -p general --cpus-per-task=18 --mem=36gb -t 12:00:00 -o ../slurm_logs/quant_${file%.bam}.%j.out ${tmp}quant_${file%.bam}.sh)
        ids=${ids}:${id:20}
    done
done

echo "Waiting for cuffquant jobs${ids} to complete"
srun -d afterok${ids} echo "Cuffquant done. Starting cuffdiff."


#############################################################################


#### cuff diff >>>> one section per serie ######

serie=HaIS
mkdir -p ${top}cuffdiff_output/${serie}
dout=$(readlink -f ${top}cuffdiff_output/${serie})
lib="fr-firststrand"

echo "#!/bin/bash
cd ${qua}${serie}

module load cufflinks

# Cuffdiff call

cuffdiff -p 18 --library-type ${lib} \
-L N2,daf2 \
-o ${dout} --dispersion-method per-condition \
${top}cuffmerge_output/${series}/merged.gtf \
S_160-F_HaIS-L____N2-___-____-REP_1/abundances.cxb,S_161-F_HaIS-L____N2-___-____-REP_2/abundances.cxb,S_162-F_HaIS-L____N2-___-____-REP_3/abundances.cxb \
S_163-F_HaIS-L__daf2-___-____-REP_1/abundances.cxb,S_164-F_HaIS-L__daf2-___-____-REP_2/abundances.cxb,S_165-F_HaIS-L__daf2-___-____-REP_3/abundances.cxb

rm ${tmp}diff_${serie}.sh" > ${tmp}diff_${serie}.sh

#### END section

for serie in ${series}; do
    cd ${tmp}
    chmod 755 ${tmp}diff_${serie}.sh
    rm -f ../slurm_logs/diff_${serie}.*.out 
    sbatch -p general --cpus-per-task=18 --mem=120gb -t 18:00:00 -o ../slurm_logs/diff_${serie}.%j.out ${tmp}diff_${serie}.sh
done

exit
