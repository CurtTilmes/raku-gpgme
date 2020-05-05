NAME
====

GPGME::TOFU - Trust on First Use information

SYNOPSIS
========

    with $tofu
    {
        .put;            # Stringify summary
        put .validity;
        put .policy;
        put .signcount;
        put .encrcount;
    }

DESCRIPTION
===========

See [gpgme_tofu_info_t](https://gnupg.org/documentation/manuals/gpgme/Key-objects.html) for more information.

METHODS
=======

  * method **Str**(--> Str)

  * method **validity**(GPGME::TOFU:D: --> GPGME::TOFUValidity)

An enumeration that stringifies to the amount of validity.

  * method **policy**(GPGME::TOFU:D: --> GPGME::TOFUPolicy)

An enumeration that stringifies to the TOFU policy.

  * method **signcount**(GPGME::TOFU:D: --> uint16)

  * method **encrcount**(GPGME::TOFU:D: --> uint16)

  * method **signfirst**(GPGME::TOFU:D: --> DateTime)

  * method **signlast**(GPGME::TOFU:D: --> DateTime)

  * method **encrfirst**(GPGME::TOFU:D: --> DateTime)

  * method **encrlast**(GPGME::TOFU:D: --> DateTime)

  * method **description**(GPGME::TOFU:D: --> Str)

