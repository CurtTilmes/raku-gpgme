NAME
====

GPGME::Key -- Information about a key

SYNOPSIS
========

    with $key
    {
        .put;                         # Stringify summary of key
        put .protocol;
        put .issuer-serial;
        ...
    }

DESCRIPTION
===========

Holds information about a key.

See [gpgme_key_t](https://gnupg.org/documentation/manuals/gpgme/Key-objects.html) for more information.

METHODS
=======

  * method **Str**(GPGME::Key:D: --> Str:D)

Stringify to a summary of the key.

  * method **protocol**(GPGME::Key:D: --> GPGME::Protocol)

An enumerated object that stringifies to the name of the protocol.

  * method **issuer-serial**(GPGME::Key:D: --> Str)

  * method **issuer-name**(GPGME::Key:D: --> Str)

  * method **chain-id**(GPGME::Key:D: --> Str)

  * method **owner-trust**(GPGME::Key:D: --> GPGME::Validity)

An enumerated object that stringifies to the type of validity.

  * method **subkeys**(GPGME::Key:D: --> Seq)

Returns a `GPGME::SubKey` for each subkey for the key.

  * method **uids**(GPGME::Key:D: --> Seq)

Returns a `GPGME::UserID` for each user ID associated with the key.

  * method **keylist-mode**(GPGME::Key:D: --> GPGME::KeylistMode)

An enumerated object that stringifies to the key listing mode

  * method **fpr**(GPGME::Key:D: --> Str)

Key fingerprint.

  * method **last-update**(GPGME::Key:D: --> DateTime)

DateTime of last update.

