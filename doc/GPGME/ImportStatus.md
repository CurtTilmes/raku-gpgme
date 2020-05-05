NAME
====

GPGME::ImportStatus -- Status of each import

SYNOPSIS
========

    with $import
    {
      .put;                         # Stringify summary
      put .result if .failed;
      put .status;
    }

DESCRIPTION
===========

Object returned for each import after an import operation.

See [gpgme_import_status_t](https://gnupg.org/documentation/manuals/gpgme/Importing-Keys.html) for more information.

METHODS
=======

  * method **fpr**(GPGME::ImportStatus:D --> Str:D)

Fingerprint for key.

  * method **failed**(GPGME::ImportStatus:D--> Bool:D)

  * method **result**(GPGME::ImportStatus:D --> Str:D)

String description of error message for failed import.

  * method **status**(GPGME::ImportStatus:D --> BitEnum)

A `BitEnum` made up of the flags for the various characteristics of the imported key.

  * method **is-new**(GPGME::ImportStatus:D --> Bool:D)

  * method **has-uids**(GPGME::ImportStatus:D --> Bool:D)

  * method **has-sigs**(GPGME::ImportStatus:D --> Bool:D)

  * method **has-subkeys**(GPGME::ImportStatus:D --> Bool:D)

  * method **has-secret**(GPGME::ImportStatus:D --> Bool:D)

