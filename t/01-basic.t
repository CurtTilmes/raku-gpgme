#!/usr/bin/env raku
use Test;
use GPGME;

plan 2;

ok my $version = GPGME.version, 'Get version';

diag "GPGME version $version";

ok GPGME.dirinfo('gpg-name'), 'dirinfo found gpg';

done-testing;
