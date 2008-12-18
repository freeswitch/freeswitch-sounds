base_dir="48000"
rates="32000 16000 8000"
version="1.0.7"
voice="music"
voice_dir="music"

for rate in $rates; do \
  test -d $rate || mkdir $rate; \
done

for filename in `ls $base_dir`; do \
  for rate in $rates; do \
    echo sox $base_dir/$filename -r $rate -c 1 $rate/$filename; \
    sox $base_dir/$filename -r $rate -c 1 $rate/$filename; \
  done ; \
done


cd ..
for rate in $rates; do \
  echo tar -cvzf freeswitch-sounds-$voice-$rate-$version.tar.gz $voice_dir/$rate--exclude .svn;  \
  tar -cvzf freeswitch-sounds-$voice-$rate-$version.tar.gz $voice_dir/$rate --exclude .svn; \
done
  tar -cvzf freeswitch-sounds-$voice-48000-$version.tar.gz $voice_dir/48000 --exclude .svn; \

cd -
