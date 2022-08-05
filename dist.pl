#!/usr/bin/perl
#
# FreeSWITCH Sound File Distribution creation script. 
#
#
use warnings;
use strict;
use Data::Dumper;
use File::Path;
use File::Basename;

my $debug = 1;

my @languages = qw(en/us/callie en/us/allison en/ca/june es/ar/mario fr/ca/june pt/BR/karina ru/RU/elena ru/RU/kirill ru/RU/vika sv/se/jakob zh/cn/sinmei zh/hk/sinmei music);
my @versions  = qw(1.0.53       1.0.2         1.0.51     1.0.0       1.0.51     1.0.51       1.0.51      1.0.0        1.0.0      1.0.50      1.0.51       1.0.51       1.0.52);
my @rates     = qw(8000 16000 32000 48000);

if (scalar(@ARGV)) {
    my @filteredlang;
    my @filteredvers;

    foreach my $arg (@ARGV) {
	my @startlang = @languages;
	my @startvers = @versions;
	if ((my $matched) = grep $_ eq $arg, @startlang) {
	    foreach my $lang (@startlang) {
		my $version = shift @startvers;
		if ( $lang eq $arg ) {
		    push @filteredlang, $lang;
		    push @filteredvers, $version;
		}
	    }
	    
	}
    }
    @languages = ();
    @versions = ();
    @languages = @filteredlang;
    @versions  = @filteredvers;
}


foreach my $voicedir (@languages) {
    my $version = shift @versions;
    my $basedir = "$voicedir";
    my $savepath;
    my $args = "";
#    if ($voicedir =~ m/ru\/RU\/elena/) {
#	$basedir = "$voicedir/44000";
#    }

    if ($voicedir =~ m/allison/) {
	$args = 'lowpass 5000';
    }
    
    ( my $voice = $voicedir ) =~ s/\//-/g;
    my $tar_path = "tmp/$voicedir";
    
    if ($voicedir =~ m/music/) {
	    $basedir = "$basedir/48000/";
    }
    foreach my $rate (@rates) {
	if ($voicedir =~ m/music/) {
	    print "rate: $rate\n" if $debug;
	    print "tar_path: $tar_path $basedir\n" if $debug;
	    my @files = <$basedir/*>;
	    print Dumper \@files if $debug;
	    foreach my $file (@files) {
		(my $newfile = $file ) =~ s/48000/$rate/g;
		my $newdir = dirname $newfile;
		my @parts = split(/\//, $newdir);
		my $rate = pop @parts;
		print "rate2: $rate\n";
		my $spath = join("/", @parts);
		$newdir = "$spath/$rate";
		$savepath = "$spath/$rate";
		print "newdir:$newdir\n" if $debug;
		print "savepath: $savepath\n" if $debug;
		mkpath "tmp/$newdir";
		print "sox $file -r $rate -c 1 tmp/$newfile $args\n" if $debug;		
		system("sox $file -r $rate -c 1 tmp/$newfile $args 2>&1 > /dev/null");
		print "normalize-audio -l -12dBFS -a -19dBFS tmp/$newfile\n" if $debug;
		system("normalize-audio -l -12dBFS -a -19dBFS tmp/$newfile 2>&1 > /dev/null");
	    }

	} else {
	    mkpath "$tar_path";
	    my @dirs = <$basedir/*>;
	    print Dumper \@dirs if $debug;
	    foreach my $dir (@dirs) {
		my @files = <$dir/*/*>;
		print Dumper \@files if $debug;
		foreach my $file (@files) {

		    my $filename = fileparse($file);
		    my $newfile;
		    if ($voicedir =~ m/ru\/RU\/elena/) {
			( $newfile = $file ) =~ s/44000/$rate/g;
		    } else {
			( $newfile = $file ) =~ s/48000/$rate/g;
		    }
		    my $newdir = dirname $newfile;
		    my @parts = split(/\//, $newdir);
		    my $rate = pop @parts;
		    my $sdir = pop @parts;
		    my $spath = join("/", @parts);
		    $newdir = "$spath/$sdir/$rate";
		    $savepath = "$spath/*/$rate";
		    
		    print "newdir:$newdir newfile:$newfile\n" if $debug;
		    mkpath "tmp/$newdir";
		    if (($voicedir =~ m/ru\/RU\/kirill/) || ($voicedir =~ m/ru\/RU\/vika/)) {
		    	if ($rate eq '48000') {
		    		print "cp $file tmp/$newdir/$filename\n" if $debug;
		    		system("cp $file tmp/$newdir/$filename 2>&1 > /dev/null");
		    	} else {
		    		print "sox $file -r $rate tmp/$newdir/$filename $args\n" if $debug;
		    		system("sox $file -r $rate tmp/$newdir/$filename $args 2>&1 > /dev/null");
		    	}		
		    } else {
		    	print "sox -v 0.2 $file -r $rate -c 1 tmp/$newdir/$filename $args\n" if $debug;
		    	system("sox -v 0.2 $file -r $rate -c 1 tmp/$newdir/$filename $args 2>&1 > /dev/null");
		    }
		}
	    }
	}
	print "cd tmp && tar -cvzf ../freeswitch-sounds-$voice-$rate-$version.tar.gz $savepath\n" if $debug;
	system("cd tmp && tar -cvzf ../freeswitch-sounds-$voice-$rate-$version.tar.gz $savepath 2>&1 > /dev/null");
	print "cd tmp && openssl dgst -md5 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.md5\n" if $debug;
	print "cd tmp && openssl dgst -sha1 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.sha1\n" if $debug;
	print "cd tmp && openssl dgst -sha256 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.sha256\n" if $debug;
	system("cd tmp && openssl dgst -md5 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.md5");
	system("cd tmp && openssl dgst -sha1 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.sha1");
	system("cd tmp && openssl dgst -sha256 ../freeswitch-sounds-$voice-$rate-$version.tar.gz > ../freeswitch-sounds-$voice-$rate-$version.tar.gz.sha256");
    }
}

#system("rm -rf tmp");
