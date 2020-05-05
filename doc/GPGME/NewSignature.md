NAME
====

GPGME::NewSignature

SYNOPSIS
========

    with $newsig
    {
        put .pubkey-algo;
        put .fpr;
    }

DESCRIPTION
===========

See [gpgme_new_signature_t](https://gnupg.org/documentation/manuals/gpgme/Creating-a-Signature.html)

METHODS
=======

  * method **type**(GPGME::NewSignature:D: --> GPGME::SigMode)

  * method **pubkey-algo**(GPGME::NewSignature:D: --> GPGME::PubKeyAlgorithm)

  * method **hash-algo**(GPGME::NewSignature:D: --> GPGME::HashAlgorithm)

  * method **timestamp**(GPGME::NewSignature:D: |opts --> DateTime:D)

  * method **fpr**(--> Str)

  * method **sig-class**(--> uint32)

