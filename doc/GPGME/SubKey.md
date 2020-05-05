NAME
====

GPGME::SubKey - Information about subkey

SYNOPSIS
========

    with $subkey
    {
        put "Algorithm: ", .pubkey-algo;
        put "revoked" if .revoked;
        ...
    }

DESCRIPTION
===========

See [gpgme_subkey_t](https://www.gnupg.org/documentation/manuals/gpgme/Key-objects.html) for more details.

METHODS
=======

  * **Str**(GPGME::SubKey:D: --> Str:D)

Stringify to a short summary of the key.

  * **list**()

A list of the subkeys.

  * **capabilities**(GPGME::SubKey:D: --> Str:D)

A short string summary of the key's capabilities: * (e)ncrypt * (s)ign * (c)ertify * (a)uthenticate * (D)isabled

  * **pubkey-algo**(--> GPGME::PubKeyAlgorithm:D)

A `GPGME::PubKeyAlgorithm` enumeration that stringifies to the algorithm name and numifies to its id.

  * **length**(GPGME::SubKey:D: --> uint32)

  * **keyid**(GPGME::SubKey:D: --> Str)

  * **fpr**(GPGME::SubKey:D: --> Str)

Fingerprint for the key.

  * **type**(GPGME::SubKey:D: --> Str:D)

'sec' for secret key or 'pub' for public key.

  * **revoked**(GPGME::SubKey:D: --> Bool:D)

  * **expired**(GPGME::SubKey:D: --> Bool:D)

  * **disabled**(GPGME::SubKey:D: --> Bool:D)

  * **invalid**(GPGME::SubKey:D: --> Bool:D)

  * **can-encrypt**(GPGME::SubKey:D: --> Bool:D)

  * **can-sign**(GPGME::SubKey:D: --> Bool:D)

  * **can-certify**(GPGME::SubKey:D: --> Bool:D)

  * **secret**(GPGME::SubKey:D: --> Bool:D)

  * **can-authenticate**(GPGME::SubKey:D: --> Bool:D)

  * **is-qualified**(GPGME::SubKey:D: --> Bool:D)

  * **is-cardkey**(GPGME::SubKey:D: --> Bool:D)

  * **is-de-vs**(GPGME::SubKey:D: --> Bool:D)

  * **timestamp**(GPGME::SubKey:D: |opts --> DateTime:D)

Timestamp of the key, pass in options for `DateTime` creation.

  * **expires**(GPGME::SubKey:D: |opts --> DateTime)

Expire time of the key if available.

  * **card-number**(GPGME::SubKey:D: --> Str)

  * **curve**(GPGME::SubKey:D: --> Str)

  * **keygrip**(GPGME::SubKey:D: --> Str)

