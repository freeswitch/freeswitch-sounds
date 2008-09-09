base_dir="48000"
rates="32000 16000 8000"
version="1.0.5"
voice="en-us-callie"
voice_dir="en/us/callie"
tar_path="../../.."
tmp_dir="tmp"
CWD=`pwd`

for rate in $rates; do \
  mkdir -p $tmp_dir/$voice_dir
  for dir in `ls $base_dir`; do \
    test -d $tmp_dir/$voice_dir/$dir/$rate || mkdir -p $tmp_dir/$voice_dir/$dir/$rate; \
    for filename in `ls $base_dir/$dir`; do \
      echo sox -v 0.2 $base_dir/$dir/$filename -r $rate -c 1 $tmp_dir/$voice_dir/$dir/$rate/$filename; \
      sox -v 0.2 $base_dir/$dir/$filename -r $rate -c 1 $tmp_dir/$voice_dir/$dir/$rate/$filename; \
    done ; \
  done ; \
  cd $tmp_dir
  echo tar -cvzf $CWD/$tar_path/freeswitch-sounds-$voice-$rate-$version.tar.gz *; \
  tar -cvzf $CWD/$tar_path/freeswitch-sounds-$voice-$rate-$version.tar.gz *; \
  cd -
  rm -rf $tmp_dir
done

