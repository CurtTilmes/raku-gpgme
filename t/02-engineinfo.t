#!/usr/bin/env raku
use Test;
use GPGME;

plan 6;

lives-ok { GPGME.engine-check-version('OpenPGP') }, 'Check protocol engine';

throws-like { GPGME.engine-check-version('bad one') },
    X::GPGME, message => 'Failure: Invalid crypto engine',
    'Invalid crypto engine';

isa-ok my $info = GPGME.engine-info, GPGME::EngineInfo, 'Get info';

isa-ok $info<cms>, GPGME::EngineInfo, 'look up a protocol';

lives-ok { GPGME.engine-info('cms', :homedir</tmp>) },
    'Set homedir for a protocol';

is $info<cms>.homedir, '/tmp', 'homedir set';

done-testing;
