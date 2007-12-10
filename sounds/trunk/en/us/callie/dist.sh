base_dir="48000"
rates="32000 16000 8000"
version="1.0.pre3"
voice="en-us-callie"
voice_dir="en/us/callie"

for rate in $rates; do \
  test -d $rate || mkdir $rate; \
done

for dir in `ls $base_dir`; do \
  for rate in $rates; do \
    test -d $rate/$dir || mkdir $rate/$dir; \
  done ; \
done

for dir in `ls $base_dir`; do \
  for filename in `ls $base_dir/$dir`; do \
    for rate in $rates; do \
      echo sox $base_dir/$dir/$filename -r $rate -c 1 $rate/$dir/$filename; \
      sox $base_dir/$dir/$filename -r $rate -c 1 $rate/$dir/$filename; \
    done ; \
  done ; \
done

cd ../../..
for rate in $rates; do \
  echo tar -cvzf freeswitch-sounds-$voice-$rate-$version.tar.gz $voice_dir/$rate; \
  tar -cvzf freeswitch-sounds-$voice-$rate-$version.tar.gz $voice_dir/$rate; \
done
cd -
