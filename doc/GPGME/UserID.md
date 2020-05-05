NAME
====

GPGME::UserID - User ID Information

SYNOPSIS
========

    with $userid
    {
        .put;                    # Stringify to summary
        put .uid;
        put .name;
        put .email;
        put .comment;
    }

DESCRIPTION
===========

See [gpgme_user_id_t](https://gnupg.org/documentation/manuals/gpgme/Key-objects.html) for more information

METHODS
=======

  * method **Str**(GPGME::UserID:D: --> Str:D)

  * method **validity**(GPGME::UserID:D: --> GPGME::Validity)

An enumeration that stringifies to the validity;

  * method **uid**(GPGME::UserID:D: --> Str)

  * method **name**(GPGME::UserID:D: --> Str)

  * method **email**(GPGME::UserID:D: --> Str)

  * method **comment**(GPGME::UserID:D: --> Str)

  * method **signatures**(GPGME::UserID:D: --> Seq)

Returns a `GPGME::KeySig` for each signature.

  * method **address**(GPGME::UserID:D: --> Str)

  * method **tofu**(GPGME::UserID:D: --> Seq)

Returns a `GPGME::TOFU` for each tofu (trust on first use).

  * method **last-update**(GPGME::UserID:D: --> DateTime)

