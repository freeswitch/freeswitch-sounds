#!/usr/bin/perl
#
# Generate the WiX version-data files from dist.pl, so dist.pl remains the
# single source of truth for package versions.
#
#   build/sounds_version.txt : "<name-with-dashes> <version>" per voice
#   build/moh_version.txt    : "<version>" for the music (MoH) package
#
# Usage (from the windows/ folder):
#   perl gen-version-files.pl [path-to-dist.pl] [output-build-dir]
#
# Defaults: ../dist.pl  and  ./build
#
use warnings;
use strict;
use File::Path qw(make_path);
use File::Basename;

my $distpl  = $ARGV[0] || dirname(__FILE__) . "/../dist.pl";
my $builddir = $ARGV[1] || dirname(__FILE__) . "/build";

open(my $fh, "<", $distpl) or die "Cannot open $distpl: $!";
my $src = do { local $/; <$fh> };
close($fh);

# Pull the qw(...) bodies of the @languages and @versions arrays.
my ($langs) = $src =~ /\@languages\s*=\s*qw\(([^)]*)\)/s
    or die "Could not find \@languages in $distpl";
my ($vers)  = $src =~ /\@versions\s*=\s*qw\(([^)]*)\)/s
    or die "Could not find \@versions in $distpl";

my @languages = split ' ', $langs;
my @versions  = split ' ', $vers;

die "languages/versions count mismatch (" . scalar(@languages) .
    " vs " . scalar(@versions) . ") in $distpl"
    unless @languages == @versions;

make_path($builddir);

open(my $sv, ">", "$builddir/sounds_version.txt") or die "sounds_version.txt: $!";
my $moh_version;
for my $i (0 .. $#languages) {
    my $voice   = $languages[$i];
    my $version = $versions[$i];
    if ($voice eq 'music') {
        $moh_version = $version;
        next;
    }
    (my $name = $voice) =~ s{/}{-}g;   # en/us/callie -> en-us-callie
    print $sv "$name $version\n";
}
close($sv);

die "music package not found in $distpl" unless defined $moh_version;
open(my $mh, ">", "$builddir/moh_version.txt") or die "moh_version.txt: $!";
print $mh "$moh_version\n";
close($mh);

print "Wrote $builddir/sounds_version.txt and $builddir/moh_version.txt\n";
print "  music (MoH) version: $moh_version\n";
