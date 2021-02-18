
# Hua Sun

# 2021-01-18

# USAGE

# Target (no header)
# <chr> <start> <stop>

# set 4Gb memory for MGI-server

CONFIG=''
TARGET=''
OUTDIR='.'

while getopts "C:T:O:" opt; do
  case $opt in
    C)
      CONFIG=$OPTARG
      ;;
    T)
      TARGET=$OPTARG
      ;;    
    O)
      OUTDIR=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done


source $CONFIG


# make outdir folder
mkdir -p $OUTDIR


# If there is no exome target file
if [[ $TARGET == "" ]]; then

    ${JAVA} -Dsamjdk.use_async_io_read_samtools=false \
      -Dsamjdk.use_async_io_write_samtools=true \
      -Dsamjdk.use_async_io_write_tribble=false \
      -Dsamjdk.compression_level=2 \
      -Xmx4g -jar ${GATK} PreprocessIntervals \
      -R ${GENOME} \
      --bin-length 5000 \
      --interval-merging-rule OVERLAPPING_ONLY \
      -O ${OUTDIR}/targets.preprocessed.5k.interval_list
fi




# If there is a exome target file
if [[ $TARGET != "" ]]; then

    ${JAVA} -Dsamjdk.use_async_io_read_samtools=false \
      -Dsamjdk.use_async_io_write_samtools=true \
      -Dsamjdk.use_async_io_write_tribble=false \
      -Dsamjdk.compression_level=2 \
      -Xmx4g -jar ${GATK} PreprocessIntervals \
      -R ${GENOME} \
      -L ${TARGET} \
      --bin-length 0 \
      --interval-merging-rule OVERLAPPING_ONLY \
      -O ${OUTDIR}/targets.preprocessed.exome.interval_list
fi



${JAVA} -Dsamjdk.use_async_io_read_samtools=false \
      -Dsamjdk.use_async_io_write_samtools=true \
      -Dsamjdk.use_async_io_write_tribble=false \
      -Dsamjdk.compression_level=2 \
      -Xmx4g -jar ${GATK} AnnotateIntervals \
      -R ${GENOME} \
      -L ${OUTDIR}/targets.preprocessed.exome.interval_list \
      --interval-merging-rule OVERLAPPING_ONLY \
      -O ${OUTDIR}/targets.preprocessed.exome.annotated.interval_list

