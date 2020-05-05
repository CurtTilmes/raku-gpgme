use NativeCall;
use GPGME::Constants;
use GPGME::LinkedList;
use BitEnum;

class GPGME::ImportStatus is repr('CStruct')             # gpgme_import_status_t
    does GPGME::LinkedList
{
    has GPGME::ImportStatus $.next;
    has Str    $.fpr;
    has int32  $!result;
    has uint32 $!status;

    method Str(GPGME::ImportStatus:D --> Str:D)
    {
        "$!fpr $.status() $.result()"
    }

    method result(GPGME::ImportStatus:D --> Str:D)
    {
        $!result == GPG_ERR_NO_ERROR
            ?? 'Success'
            !! X::GPGME.new(code => $!result).message
    }

    method failed(GPGME::ImportStatus:D--> Bool:D)
    {
        $!result != GPG_ERR_NO_ERROR
    }

    method status(GPGME::ImportStatus:D --> BitEnum)
    {
        BitEnum[GPGME::ImportFlags, prefix => 'GPGME_IMPORT_', :lc]
                          .new($!status)
    }

    method is-new(GPGME::ImportStatus:D --> Bool:D)
    {
        $.status().isset(GPGME_IMPORT_NEW)
    }

    method has-uids(GPGME::ImportStatus:D --> Bool:D)
    {
        $.status().isset(GPGME_IMPORT_UID)
    }

    method has-sigs(GPGME::ImportStatus:D --> Bool:D)
    {
        $.status().isset(GPGME_IMPORT_SIG)
    }

    method has-subkeys(GPGME::ImportStatus:D --> Bool:D)
    {
        $.status().isset(GPGME_IMPORT_SUBKEY)
    }

    method has-secret(GPGME::ImportStatus:D --> Bool:D)
    {
        $.status().isset(GPGME_IMPORT_SECRET)
    }
}

=begin pod

=head1 NAME

GPGME::ImportStatus -- Status of each import

=head1 SYNOPSIS

  with $import
  {
    .put;                         # Stringify summary
    put .result if .failed;
    put .status;
  }

=head1 DESCRIPTION

Object returned for each import after an import operation.

See L<gpgme_import_status_t|https://gnupg.org/documentation/manuals/gpgme/Importing-Keys.html> for more information.

=head1 METHODS

=item method B<fpr>(GPGME::ImportStatus:D --> Str:D)

Fingerprint for key.

=item method B<failed>(GPGME::ImportStatus:D--> Bool:D)

=item method B<result>(GPGME::ImportStatus:D --> Str:D)

String description of error message for failed import.

=item method B<status>(GPGME::ImportStatus:D --> BitEnum)

A C<BitEnum> made up of the flags for the various characteristics of
the imported key.

=item method B<is-new>(GPGME::ImportStatus:D --> Bool:D)

=item method B<has-uids>(GPGME::ImportStatus:D --> Bool:D)

=item method B<has-sigs>(GPGME::ImportStatus:D --> Bool:D)

=item method B<has-subkeys>(GPGME::ImportStatus:D --> Bool:D)

=item method B<has-secret>(GPGME::ImportStatus:D --> Bool:D)

=end pod
