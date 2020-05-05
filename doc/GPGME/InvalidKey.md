NAME
====

GPGME::InvalidKey - Information about invalid keys

SYNOPSIS
========

    with $invalidkey
    {
      put .fpr;
      put .reason;
    }

DESCRIPTION
===========

Holds the fingerprint and reason a key is invalid.

METHODS
=======

  * method **fpr**(GPGME::InvalidKey:D: --> Str)

  * method **reason**(GPGME::InvalidKey:D: --> Str)

