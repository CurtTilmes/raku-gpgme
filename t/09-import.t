#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 9;

isa-ok my $gpg = GPGME.new(:$homedir, :armor, :passphrase<abc>),
    GPGME, 'Create object';

isa-ok $gpg.create-key('joe@foo.bar'), GPGME::GenKeyResult, "Generate key";

my $fpr = $gpg.fpr;

isa-ok my $exp = $gpg.export('joe@foo.bar'), GPGME::Data, 'exported';

$tempdir = make-temp-dir;
$homedir = $tempdir.absolute;

isa-ok $gpg = GPGME.new(:$homedir, :armor, :passphrase<abc>),
    GPGME, 'Create a new object';

isa-ok $gpg.import($exp), GPGME::ImportResult, 'import';

with $gpg
{
    is .considered, 1, '1 key considered';
    is .imported, 1, '1 key imported';
    is .imports[0].fpr, $fpr, 'Fingerprint matches';
}

isa-ok $gpg.get-key('joe@foo.bar'), GPGME::Key, 'found key after import';

done-testing;
