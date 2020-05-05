NAME
====

GPGME::VerifyResult

SYNOPSIS
========

    with $result
    {
        put .file-name;
        .summary.put for .signatures;
    }

DESCRIPTION
===========

See [gpgme_verify_result_t](https://gnupg.org/documentation/manuals/gpgme/Verify.html) for more information.

METHODS
=======

  * method **file-name**(GPGME::VerifyResult:D: --> Str)

  * method **signatures**(GPGME::VerifyResult:D: --> Seq)

Returns a `GPGME::Signature` for each signature.

