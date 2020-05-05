#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 7;

isa-ok my $gpg = GPGME.new(:$homedir, :passphrase<abc>), GPGME,
    'Create object';

isa-ok $gpg.create-key('joe'), GPGME::GenKeyResult, "Generate key";

my $fpr = $gpg.fpr;

my $message = "my message";

isa-ok my $cipher = $gpg.encrypt($message, 'joe', :sign), GPGME::Data,
    'Encrypt message';

is $gpg.sign-result.signatures[0].fpr, $fpr, 'Signed with the right key';

my $buf = $cipher.slurp;

isa-ok my $plain = $gpg.decrypt($buf, :verify), GPGME::Data, 'Decrypt message';

is $plain, $message, 'Message correct';

is $gpg.verify-result.signatures[0].fpr, $fpr, 'Verified with the right key';

done-testing;
