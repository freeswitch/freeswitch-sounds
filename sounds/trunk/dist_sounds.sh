country="us"
lang="en"
voice="callie"
src_hz="48000"
dst_dir="tmp"



base_dir="${lang}/${country}/${voice}/${src_hz}"
rates="48000 32000 16000 8000"
voice_dir="${lang}/${country}/${voice}"
CWD=`pwd`

mkdir -p ${dst_dir}

for rate in $rates; do \
  mkdir -p $dst_dir/$voice_dir
  for dir in `ls $base_dir`; do \
    test -d $dst_dir/$voice_dir/$dir/$rate || mkdir -p $dst_dir/$voice_dir/$dir/$rate; \
    for filename in `ls $base_dir/$dir`; do \
      echo sox -v 0.2 $base_dir/$dir/$filename -r $rate -c 1 $dst_dir/$voice_dir/$dir/$rate/$filename; \
      sox -v 0.2 $base_dir/$dir/$filename -r $rate -c 1 $dst_dir/$voice_dir/$dir/$rate/$filename; \
    done ; \
  done ; \
done

