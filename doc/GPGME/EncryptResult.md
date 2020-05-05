NAME
====

GPGME::EncryptResult

SYNOPSIS
========

    for $result.invalid-recipients
    {
      put .fpr;
      put .reason;
    }

DESCRIPTION
===========

Result from an Encryption operation.

See [gpgme_encrypt_result_t](https://gnupg.org/documentation/manuals/gpgme/Encrypting-a-Plaintext.html) for more information.

METHODS
=======

  * method **invalid-recipients**(GPGME::EncryptResult:D: --> Seq)

Returns a `GPGME::InvalidKey` for each invalid recipient.

