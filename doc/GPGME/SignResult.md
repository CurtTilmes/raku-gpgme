NAME
====

GPGME::SignResult - Result from a Sign operation

SYNOPSIS
========

    with $result
    {
       .put for .signatures;
       .put for .invalid-signers;
    }

DESCRIPTION
===========

See [gpgme_sign_result_t](https://gnupg.org/documentation/manuals/gpgme/Creating-a-Signature.html).

METHODS
=======

  * method **signatures**(GPGME::SignResult:D: --> Seq)

Returns a sequence of `GPGME::NewSignature`s.

  * method **invalid-signers**(GPGME::SignResult:D: --> Seq)

Returns a sequence of `GPGME::InvalidKey`s.

