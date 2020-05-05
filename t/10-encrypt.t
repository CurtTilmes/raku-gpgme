#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 5;

isa-ok my $gpg = GPGME.new(:$homedir, :passphrase<abc>), GPGME,
    'Create object';

isa-ok $gpg.create-key('joe'), GPGME::GenKeyResult, "Generate key";

my $message = "my message";

isa-ok my $cipher = $gpg.encrypt($message, 'joe'), GPGME::Data,
    'Encrypt message';

my $buf = $cipher.slurp;

isa-ok my $plain = $gpg.decrypt($buf), GPGME::Data, 'Decrypt message';

is $plain, $message, 'Message correct';

done-testing;
