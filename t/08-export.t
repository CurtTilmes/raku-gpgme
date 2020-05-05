#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 6;

isa-ok my $gpg = GPGME.new(:$homedir, :armor, :passphrase<abc>),
    GPGME, 'Create object';

isa-ok $gpg.create-key('joe@foo.bar'), GPGME::GenKeyResult, "Generate key";

isa-ok my $exp1 = $gpg.export('joe@foo.bar'), GPGME::Data, 'exported';

isa-ok my $key = $gpg.get-key('joe@foo.bar'), GPGME::Key, 'Get Key';

isa-ok my $exp2 = $gpg.export($key), GPGME::Data, 'exported key';

is $exp1, $exp2, 'Keys match';

done-testing;


