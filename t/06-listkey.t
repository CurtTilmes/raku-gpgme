#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 11;

isa-ok my $gpg = GPGME.new(:$homedir, :passphrase<abc>),
    GPGME, 'Create object';

for <joe harry alice bill> -> $uid
{
    isa-ok $gpg.create-key($uid), GPGME::GenKeyResult, "Generate key $uid";
}

ok (my @keys = $gpg.keylist(<alice harry>)), 'Key list';

is @keys.elems, 2, 'Found 2 keys';

for @keys
{
    isa-ok my $userid = .uids[0], GPGME::UserID, 'Got a userid';

    is $userid.uid, 'harry'|'alice', 'Found right users';
}

done-testing;
