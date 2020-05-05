#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 3;

isa-ok my $gpg = GPGME.new(:$homedir),
    GPGME, 'Create object';

isa-ok $gpg.genkey(:Name-Real('Joe Tester'),
                   :Name-Comment('with stupid passphrase'),
                   :Name-Email('joe@foo.bar'),
                   :Passphrase('abc')),
    GPGME::GenKeyResult, 'Generate key';

isa-ok my $key = $gpg.get-key('joe@foo.bar'),
    GPGME::Key, 'Retrieve key';

done-testing;
