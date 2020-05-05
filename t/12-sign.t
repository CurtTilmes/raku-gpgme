#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 10;

isa-ok my $gpg = GPGME.new(:$homedir, :armor, :passphrase<abc>),
    GPGME, 'Create object';

isa-ok $gpg.create-key('joe@foo.bar'), GPGME::GenKeyResult, "Generate key";

my $fpr = $gpg.fpr;

lives-ok { $gpg.signers('joe@foo.bar') }, 'Set Signers';

my $message = "My message";

isa-ok my $signed = $gpg.sign($message), GPGME::Data, 'Sign message';

is $gpg.signatures[0].fpr, $fpr, 'Signed with the right key';

isa-ok my $plain = $gpg.verify($signed), GPGME::Data, 'Verify message';

is $plain, $message, 'Message verified';

with $gpg.signatures[0]
{
    is .status, 'Success', 'signature status';
    ok .summary.isset('valid'), 'Signature valid';
    is $gpg.signatures[0].fpr, $fpr, 'Verify key correct';
}

done-testing;


