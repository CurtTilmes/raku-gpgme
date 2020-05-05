NAME
====

GPGME::DecryptResult -- Extra information about a decryption

SYNOPSIS
========

    with $result
    {
        put .unsupported-algorithm;
        put .file-name;
        put .session-key;
        put .wrong-key-usage;
        put .is-de-vs;
        .keyid.put for .recipients;
    }

DESCRIPTION
===========

After a decryption, the context result holds this object with more information about the decyprtion.

See [gpgme_decrypt_result_t](https://www.gnupg.org/documentation/manuals/gpgme/Decrypt.html) for more details.

METHODS
=======

  * method **unsupported-algorithm**(GPGME::DecryptResult:D: --> Str)

If an unsupported algorithm was encountered, this string describes the algorithm that is not supported.

  * method **file-name**(GPGME::DecryptResult:D: --> Str)

This is the filename of the original plaintext message file if it is known.

  * method **session-key**(GPGME::DecryptResult:D: --> Str)

A textual representation) of the session key used in symmetric encryption of the message, if the context has been set to export session keys (see flag "export-session-key"), and a session key was available for the most recent decryption operation.

  * method **wrong-key-usage**(GPGME::DecryptResult:D: --> Bool:D)

This is true if the key was not used according to its policy.

  * method **is-de-vs**(GPGME::DecryptResult:D: --> Bool:D)

The message was encrypted in a VS-NfD compliant way. This is a specification in Germany for a restricted communication level.

  * method **recipients**(GPGME::DecryptResult:D: --> Seq)

Returns a list of `GPGME::Recipient`s to which this message was encrypted.

