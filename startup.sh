#!/bin/sh

HIPSGEN_ARGS=()

echo "=== AWS_BATCH_JOB_ARRAY_INDEX: $AWS_BATCH_JOB_ARRAY_INDEX ==="

# todo: add in a lookup for the `-Xmx10g/255g/700m RAM flag`

for i in "$@"; do
  case "$i" in

    # -------- java flags --------
    -Xmx*|-Xms*)
      JAVA_ARG=("$i")
      ;;

    # -------- flags --------
    -clean|-n|-color|-nocolor|-nice|-notouch|\
    -hhhcar|-notrim|-trim|-gzip|-hips3d|\
    -d|-h|-man)
      HIPSGEN_ARGS+=("$i")
      ;;

    # -------- key=value parameters --------
    order=*|minOrder=*|frame=*|tileWidth=*|\
    orderFreq=*|bitpix=*|dataRange=*|pixelCut=*|img=*|\
    hdu=*|blank=*|restfreq=*|validRange=*|skyVal=*|\
    expTime=*|maxRatio=*|fov=*|border=*|shape=*|mode=*|\
    incremental=*|region=*|partitioning=*|maxThread=*|\
    fastCheck=*|fitsKeys=*|id=*|title=*|creator=*|\
    target=*|status=*|color=*|inRed=*|inGreen=*|inBlue=*|\
    cmRed=*|cmGreen=*|cmBlue=*|luptonQ=*|luptonS=*|\
    luptonM=*|cache=*|cacheSize=*|cacheRemoveOnExit=*|\
    mocOrder=*|mapNside=*|format=*|mirrorSplit=*|pilot=*)
      HIPSGEN_ARGS+=("$i")
      ;;

    # ---------- parse in and out separately ----------
    in=*)
      HIPSGEN_ARGS+=("$i")
      IN_DIR="${i#in=}"
      ;;
      
    out=*)
      HIPSGEN_ARGS+=("$i/$AWS_BATCH_JOB_ARRAY_INDEX")
      OUT_DIR="${i#out=}/$AWS_BATCH_JOB_ARRAY_INDEX"
      ;;

    # ---------- actions ----------
    INDEX|TILES|PNG|JPEG|MOC|MAP|ALLSKY|\
    CLEAN|CLEANINDEX|CLEANFITS|CLEANJPEG|CLEANPNG|CLEANWEIGHT|\
    TREE|APPEND|CONCAT|CUBE|DETAILS|STMOC|UPDATE|\
    CHECKCODE|MIRROR|RGB|CHECK|CHECKDATASUM|CHECKFAST|\
    LINT|MAPTILES|COUNT|PACK|PACKINDEX|UNPACK|UNPACKINDEX)
      HIPSGEN_ARGS+=("$i")
      ;;

    # -------- ignore everything else --------
    *)
      ;;
  esac
done

echo "==== Passing through to hipsgen ===="
printf '  %q\n' "${HIPSGEN_ARGS[@]}"

echo "==== mounting database to mount subdirectory ===="
mkdir -p mnt/stpubdata/panstarrs/ps1
mount-s3 s3://stpubdata/panstarrs/ps1/ mnt/stpubdata/panstarrs/ps1 --no-sign-request

# todo: we need total jobs or something similar to do this start/end logic
echo "==== running hipsgen command ===="
# start=$((AWS_BATCH_JOB_ARRAY_INDEX*4))
# end=$((start + 3))

java "${JAVA_ARG}" -jar Hipsgen.jar -hipsgen "${HIPSGEN_ARGS[@]}" # region="0/${start}-${end}"

EXIT_CODE=$?
echo "==== Hipsgen finished with exit code $EXIT_CODE ===="

echo "==== HiPS output directory: ${OUT_DIR} ===="
aws s3 sync "${OUT_DIR}" s3://pcuster-test-hipsgen-output/
if [ -d "$OUT_DIR" ]; then
  ls -R "$OUT_DIR"
else
  echo "Output directory not found"
fi

# ensure that we send the hipsgen exit code to stdout