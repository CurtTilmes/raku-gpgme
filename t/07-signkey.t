#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 11;

isa-ok my $gpg = GPGME.new(:$homedir, :keylist-mode<sigs>,
                           :passphrase<abc>),
    GPGME, 'Create object';

for <joe@foo.bar alice@foo.bar> -> $uid
{
    isa-ok $gpg.create-key($uid), GPGME::GenKeyResult, "Generate key $uid";
}

lives-ok { $gpg.signers('alice@foo.bar') }, 'Set Signers';

with $gpg.signers[0]
{
    isa-ok $_, GPGME::Key, 'Signer key';
    is .uids[0].uid, 'alice@foo.bar', 'Alice is a signer';
}

isa-ok my $key = $gpg.get-key('joe@foo.bar'), GPGME::Key, 'Get Key';

lives-ok { $gpg.keysign($key, 'joe@foo.bar') }, 'Sign key';

isa-ok $key = $gpg.get-key('joe@foo.bar'), GPGME::Key, 'Get Key';

for $key.uids[0].signatures
{
    is .uid, 'joe@foo.bar'|'alice@foo.bar', 'Both Joe and Alice have signed';
}

done-testing;
