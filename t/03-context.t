#!/usr/bin/env raku
use Test;
use GPGME;

plan 20;

isa-ok my $gpg = GPGME.new(:armor, :textmode, :offline,
                           :pin-entry-mode<ask>,
                           :keylist-mode<sigs local validate>),
    GPGME, 'new';

is $gpg.protocol, 'OpenPGP', 'protocol';

isa-ok $gpg.engine-info, 'GPGME::EngineInfo', 'Engine Info';

throws-like { $gpg.sender("foo") }, X::GPGME,
    message => 'Failure: Invalid value', 'Invalid sender';

ok $gpg.sender('From: <somebody@somewhere.com>'), 'Set sender';

is $gpg.sender, 'somebody@somewhere.com', 'Get sender';

ok $gpg.armor, 'ASCII Armor';

ok $gpg.textmode, 'Text Mode';

ok $gpg.offline, 'Offline Mode';

is $gpg.pin-entry-mode, 'ask', 'ask pin entry mode';

ok my $mode = $gpg.keylist-mode, 'Get keylist mode';

ok $mode.isset(<local sigs validate>), 'keylist mode local';

nok $mode.isset(<extern notation with_secret with_tofu ephemeral>),
    'keylist mode clear flags';

isa-ok $gpg = GPGME.new(protocol => 'CMS'), GPGME, 'new CMS';

is $gpg.protocol, 'CMS', 'CMS protocol';

is $gpg.keylist-mode, 'local', 'Keylist mode default local';

is $gpg.armor, False, 'No ASCII Armor';

is $gpg.textmode, False, 'No text mode';

is $gpg.offline, False, 'No offline mode';

is $gpg.pin-entry-mode, 'default', 'default pinentry mode';

done-testing;
