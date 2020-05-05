NAME
====

GPGME::KeySig -- Key signature

SYNOPSIS
========

    with $keysig
    {
        put .pubkey-algo;
        put .keyid;
        ...
    }

DESCRIPTION
===========

`GPGME::KeySig` is a key signature structure. Key signatures are one component of a `GPGME::Key` object, and validate user IDs on the key in the OpenPGP protocol.

The signatures on a key are only available if the key was retrieved via a listing operation with the `:keylist-mode<sigs>` mode enabled, because it can be expensive to retrieve all signatures of a key.

The signature notations on a key signature are only available if the key was retrieved via a listing operation with the `:keylist-mode<sig_notations>` mode enabled, because it can be expensive to retrieve all signature notations.

See [gpgme_key_sig_t](https://www.gnupg.org/documentation/manuals/gpgme/Key-objects.html) for more details.

METHODS
=======

  * method **Str**(GPGME::KeySig:D: --> Str)

  * method **revoked**(GPGME::KeySig:D: --> Bool:D)

  * method **expired**(GPGME::KeySig:D: --> Bool:D)

  * method **invalid**(GPGME::KeySig:D: --> Bool:D)

  * method **exportable**(GPGME::KeySig:D: --> Bool:D)

  * method **pubkey-algo**(GPGME::KeySig:D: --> GPGME::PubKeyAlgorithm)

An enumeration for the public key algorithm used in the encryption. It stringifies to the name of the algorithm and numifies to the algorithm id.

  * method **status**(GPGME::KeySig:D:)

  * method **keyid**(GPGME::KeySig:D: --> Str)

  * method **timestamp**(GPGME::KeySig:D: --> DateTime:D)

  * method **expires**(GPGME::KeySig:D: --> DateTime)

  * method **uid**(GPGME::KeySig:D: --> Str)

  * method **name**(GPGME::KeySig:D: --> Str)

  * method **email**(GPGME::KeySig:D: --> Str)

  * method **comment**(GPGME::KeySig:D: --> Str)

  * method **sig-class**(GPGME::KeySig:D: --> uint32)

  * method **notations**(GPGME::KeySig:D: --> Map)

