NAME
====

GPGME::Recipient -- Information about Recipients of a decryption

SYNOPSIS
========

    with $recipient
    {
        put .keyid;
        put .pubkey-algo;
        put .status;
    }

DESCRIPTION
===========

After a decryption, the list of recipients can be retrieved with more information.

See [gpgme_recipient_t](https://www.gnupg.org/documentation/manuals/gpgme/Decrypt.html) for more details.

METHODS
=======

  * method **keyid**(GPGME::Recipient:D: --> Str)

This is the key ID of the key (in hexadecimal digits) used as recipient.

  * method **pubkey-algo**(GPGME::Recipient:D: --> GPGME::PubKeyAlgorithm)

An enumeration for the public key algorithm used in the encryption. It stringifies to the name of the algorithm and numifies to the algorithm id.

  * method **status**(GPGME::Recipient:D: --> Bool:D)

`True` if the secret key for this recipient is available.

