NAME
====

GPGME::SigNotation - Information about Signature Notations

SYNOPSIS
========

    put $notation.Map;

DESCRIPTION
===========

Each Signature Notation has a name and a value. You can get a `list` of them or a `Map` of them.

See [gpgme_sig_notation_t](https://gnupg.org/documentation/manuals/gpgme/Verify.html) for more information.

METHODS
=======

  * method **name**(GPGME::SigNotation:D --> Str)

  * method **value**(GPGME::SigNotation:D --> Str)

  * method **list**(GPGME::SigNotation:D --> Seq)

  * method **Map**(--> Map:D)

