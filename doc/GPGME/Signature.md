NAME
====

GPGME::Signature - Information about signatures

SYNOPSIS
========

    with $signature
    {
        put .summary;
        put .status
        ...
    }

DESCRIPTION
===========

See [gpgme_signature_t](https://gnupg.org/documentation/manuals/gpgme/Verify.html) for more information.

METHODS
=======

  * method **summary**(GPGME::Signature:D: --> BitEnum)

  * method **status**(GPGME::Signature:D: --> Str)

  * method **notations**(GPGME::Signature:D: --> Map)

  * method **timestamp**(GPGME::Signature:D: |opts --> DateTime:D)

  * method **expiretime**(GPGME::Signature:D: |opts --> DateTime)

  * method **validity**(GPGME::Signature:D: --> GPGME::Validity)

  * method **validity-reason**(GPGME::Signature:D: --> Str)

  * method **pubkey-algo**(GPGME::Signature:D: --> GPGME::PubKeyAlgorithm:D)

  * method **hash-algo**(GPGME::Signature:D: --> GPGME::HashAlgorithm:D)

