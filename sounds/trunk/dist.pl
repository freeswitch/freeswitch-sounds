#!/usr/bin/perl
use Data::Dumper;
use File::Path;
use File::Basename;
my $debug = 0;

my @languages = qw(en/us/callie en/ca/june fr/ca/june pt/BR/karina ru/RU/elena zh/cn/sinmei zh/hk/sinmei music);
my @versions  = qw(1.0.50       1.0.50     1.0.50     1.0.50        1.0.50     1.0.50       1.0.50       1.0.50);
my @rates     = qw(8000 16000 32000 48000);

foreach my $voicedir (@languages) {
    my $version = shift @versions;
    my $basedir = "$voicedir/48000";
    if ($voicedir =~ m/ru\/RU\/elena/) {
	$basedir = "$voicedir/44000";
    }
    
    ( my $voice = $voicedir ) =~ s/\//-/g;
    my $tar_path = "tmp/$voicedir";
    foreach my $rate (@rates) {
	if ($voicedir =~ m/music/) {
	    print "rate: $rate\n";
	    print "tar_path: $tar_path $basedir\n" if $debug;
	    my @files = <$basedir/*>;
	    print Dumper \@files if $debug;
	    foreach my $file (@files) {
		(my $newfile = $file ) =~ s/48000/$rate/g;
		my $newdir = dirname $newfile;
		print "newdir:$newdir\n";
		mkpath "tmp/$newdir";
		print "sox -v 0.2 $file -r $rate -c 1 tmp/$newfile\n" if $debug;
		system("sox -v 0.2 $file -r $rate -c 1 tmp/$newfile 2>&1 > /dev/null");
	    }
	} else {
	    mkpath "$tar_path";
	    my @dirs = <$basedir/*>;
	    print Dumper \@dirs if $debug;
	    foreach my $dir (@dirs) {
		my @files = <$dir/*>;
		print Dumper \@files;
		foreach my $file (@files) {
		    my $newfile;
		    if ($voicedir =~ m/ru\/RU\/elena/) {
			( $newfile = $file ) =~ s/44000/$rate/g;
		    } else {
			( $newfile = $file ) =~ s/48000/$rate/g;
		    }
		    my $newdir = dirname $newfile;
		    print "newdir:$newdir\n";
		    mkpath "tmp/$newdir";
		    print "sox -v 0.2 $file -r $rate -c 1 tmp/$newfile\n" if $debug;
		    system("sox -v 0.2 $file -r $rate -c 1 tmp/$newfile 2>&1 > /dev/null");
		}
	    }
	}
	print "cd tmp && tar -cvzf ../freeswitch-sounds-$voice-$rate-$version.tar.gz $voicedir/$rate\n" if $debug;
	system("cd tmp && tar -cvzf ../freeswitch-sounds-$voice-$rate-$version.tar.gz $voicedir/$rate 2>&1 > /dev/null");
	print "cd tmp && openssl dgst -md5 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.md5\n" if $debug;
	print "cd tmp && openssl dgst -sha1 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.sha1\n" if $debug;
	print "cd tmp && openssl dgst -sha256 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.sha256\n" if $debug;
	system("cd tmp && openssl dgst -md5 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.md5");
	system("cd tmp && openssl dgst -sha1 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.sha1");
	system("cd tmp && openssl dgst -sha256 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.sha256");
    }
}

system("rm -rf tmp");
