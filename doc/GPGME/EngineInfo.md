NAME
====

GPGME::EngineInfo -- Characteristics of the crypto engine

SYNOPSIS
========

    my $info = GPGME.engine-info;       # Get global info for all engines

    .put for $info.list;                # Stringify each info block

    with $info<OpenPGP>                 # Associative call by protocol
    {
        put .protocol;                  # openpgp
        put .filename;                  # /usr/bin/gpg
        put .version;                   # 2.1.18
        put .required-version;          # 1.4.0
        put .homedir;                   # /home/myname/.gnupg
    }

    my $info = $gpgme.engine-info;      # Get info from a context

DESCRIPTION
===========

Use `GPGME` to get either the global defaults for the supported crypto engines, or the info for a specific protocol in use by a context.

See [Engine Information](https://www.gnupg.org/documentation/manuals/gpgme/Engine-Information.html) for more details.

METHODS
=======

  * method **Str**(GPGME::EngineInfo:D: --> Str:D)

Return several lines of a human readable information about the crypto engine.

  * method **protocol**(GPGME::EngineInfo:D: --> GPGME::Protocol:D)

Returns an enumeration for the protocol. It stringifies to the protocol name and nummifies to the protocol id.

  * method **filename**(GPGME::EngineInfo:D: --> Str)

The file name of the executable program implementing this protocol.

  * method **homedir**(GPGME::EngineInfo:D: --> Str)

The directory name of the configuration directory for this crypto engine.

  * method **version**(GPGME::EngineInfo:D: --> Str)

This is a string containing the version number of the crypto engine.

  * method **required-version**(GPGME::EngineInfo:D: --> Str)

This is a string containing the minimum required version number of the crypto engine for GPGME to work correctly.

  * method **list**(--> Seq)

Returns a list of all the engines.

  * method **AT-KEY**(GPGME::EngineInfo:D: Str:D $key --> GPGME::EngineInfo)

Looks through the list of engines for a specific protocol.

