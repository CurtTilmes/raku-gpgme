#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 8;

isa-ok my $gpg = GPGME.new(:$homedir, :armor, :passphrase<abc>),
    GPGME, 'Create object';

isa-ok $gpg.create-key('joe@foo.bar'), GPGME::GenKeyResult, "Generate key";

my $fpr = $gpg.fpr;

lives-ok { $gpg.signers('joe@foo.bar') }, 'Set Signers';

my $message = "My message";

isa-ok my $signature = $gpg.sign($message, :detach), GPGME::Data, 'Sign message';

isa-ok $gpg.verify($signature, $message), GPGME::VerifyResult, 'Verify message';

with $gpg.signatures[0]
{
    is .status, 'Success', 'signature status';
    ok .summary.isset('valid'), 'Signature valid';
    is $gpg.signatures[0].fpr, $fpr, 'Verify key correct';
}

done-testing;
