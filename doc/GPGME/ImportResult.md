NAME
====

GPGME::ImportResult

SYNOPSIS
========

    with $result
    {
      put .considered;
      put .no-user-id;
      ..
    }

DESCRIPTION
===========

Result from an Import operation.

See [gpgme_import_result_t](https://gnupg.org/documentation/manuals/gpgme/Importing-Keys.html) for more information.

METHODS
=======

  * method **considered**(GPGME::ImportResult:D: --> int32)

  * method **no-user-id**(GPGME::ImportResult:D: --> int32)

  * method **imported**(GPGME::ImportResult:D: --> int32)

  * method **imported-rsa**(GPGME::ImportResult:D: --> int32)

  * method **unchanged**(GPGME::ImportResult:D: --> int32)

  * method **new-user-ids**(GPGME::ImportResult:D: --> int32)

  * method **new-sub-keys**(GPGME::ImportResult:D: --> int32)

  * method **new-signatures**(GPGME::ImportResult:D: --> int32)

  * method **new-revocations**(GPGME::ImportResult:D: --> int32)

  * method **secret-read**(GPGME::ImportResult:D: --> int32)

  * method **secret-imported**(GPGME::ImportResult:D: --> int32)

  * method **secret-unchanged**(GPGME::ImportResult:D: --> int32)

  * method **skipped-new-keys**(GPGME::ImportResult:D: --> int32)

  * method **not-imported**(GPGME::ImportResult:D: --> int32)

  * method **imports**(GPGME::ImportResult:D: --> Seq)

Returns a `GPGME::ImportStatus` for each import.

