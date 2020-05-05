#!/usr/bin/env raku
use Test;
use Temp::Path;
use GPGME;

my $tempdir = make-temp-dir;
my $homedir = $tempdir.absolute;

plan 6;

isa-ok my $gpg = GPGME.new(:$homedir, :passphrase<abc>),
    GPGME, 'Create object';

isa-ok my $genresult = $gpg.create-key('joe@foo.bar'),
    GPGME::GenKeyResult, 'Generate key';

isa-ok my $key = $gpg.get-key('joe@foo.bar'),
    GPGME::Key, 'Retrieve key';

lives-ok { $gpg.adduid($key, 'another@email.address') }, 'Add uid';

lives-ok { $gpg.revuid($key, 'joe@foo.bar') }, 'Revoke user ID';

isa-ok $key = $gpg.get-key('joe@foo.bar'),
    GPGME::Key, 'Retrieve key';

done-testing;
