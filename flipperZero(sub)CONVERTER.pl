#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

# Získanie zoznamu súborov v aktuálnom priečinku
my $dir = '.';
opendir(my $dh, $dir) or die "Nepodarilo sa otvoriť priečinok: $!";
my @files = readdir($dh);
closedir($dh);

# Prechádzanie cez zoznam súborov
foreach my $file (@files) {
    next unless -f $file;  # Preskočiť ak nie je to súbor

    if ($file =~ /\.Complex16s$/i) {
        my $output_file = convert_to_flipper_zero($file);
        print "Konverzia súboru $file na formát Flipper Zero (výstup: $output_file) dokončená.\n";
    }
}

sub convert_to_flipper_zero {
    my ($input_file) = @_;
    my ($name, $path, $suffix) = fileparse($input_file, qr/\.[^.]*/);
    my $output_file = "${path}${name}.sub";

    open(my $input_fh, '<:raw', $input_file) or die "Nepodarilo sa otvoriť vstupný súbor $input_file: $!";
    open(my $output_fh, '>:raw', $output_file) or die "Nepodarilo sa otvoriť výstupný súbor $output_file: $!";

    while (read($input_fh, my $data, 4)) {
        my ($real, $imag) = unpack('s>s>', $data);

        my $new_real = $real * 2;
        my $new_imag = $imag * 2;

        print $output_fh pack('s>s>', $new_real, $new_imag);
    }

    close($input_fh);
    close($output_fh);

    return $output_file;
}
