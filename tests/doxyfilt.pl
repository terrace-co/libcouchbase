#!/usr/bin/perl

# Google tests don't really play nicely with Doxygen, so we need to
# Convert the TEST_F macro into something Doxygen can eat. To do this we need
# to convert it to a simple function declaration, and trick into thinking
# the methods have been declared

use strict;
use warnings;
use File::Path qw(mkpath rmtree);

my $fname = $ARGV[0];

my @lines;
my %classes;

open my $fh, "<", $fname or die "$fname: $!";
while ( (my $line = <$fh>) ) {
    my $re = qr/TEST_F\(\s*([[:alnum:]]+)\s*,\s*([[:alnum:]]+)\s*\)/;
    my ($cls,$fn) = ($line =~ $re);
    if ($cls) {
        push @{$classes{$cls}}, $fn;
        $line =~ s/TEST_F[^{]+/$cls\::$fn() /g;
    }
    push @lines, $line;
}

while (my ($cls,$functions) = each %classes) {
    my $decl = "// Contents of this class auto-generated by $0\n";
    $decl .= "class $cls {\npublic: \n";
    foreach my $func (@$functions) {
        $decl .= "    void $func(); \n";
    }
    $decl .= "};\n";
    unshift @lines, "#line \"$fname\" 0\n";
    unshift @lines, $decl;
}

print @lines;