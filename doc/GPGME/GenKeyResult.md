NAME
====

GPGME::GenKeyResult -- Result from Generating a Key

SYNOPSIS
========

    with $result
    {
        say 'primary key created' if .primary;
        say 'subkey was created'  if .sub;
        say 'user ID was created' if .uid;
        say  "Key Fingerprint: ", .fpr;
    }

DESCRIPTION
===========

After performing a key generation, these results are available.

See [gpgme_genkey_result_t](https://gnupg.org/documentation/manuals/gpgme/Generating-Keys.html) for more details.

METHODS
=======

  * method **Str**(GPGME::GenKeyResult:D: --> Str:D)

Summarize the Generation Result.

  * method **primary**(GPGME::GenKeyResult:D: --> Bool:D)

True if a primary key was created.

  * method **sub**(GPGME::GenKeyResult:D:--> Bool:D)

True if a subkey was created.

  * method **uid**(GPGME::GenKeyResult:D:--> Bool:D)

True if a user ID was created.

  * method **fpr**(GPGME::GenKeyResult:D:--> Str)

The fingerprint of the key that was created. If both a primary and a subkey were generated, the fingerprint of the primary key will be returned.

