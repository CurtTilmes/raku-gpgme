use NativeCall;
use GPGME::ImportStatus;

class GPGME::ImportResult is repr('CStruct')            # gpgme_import_result_t
{
    has int32 $.considered;
    has int32 $.no-user-id;
    has int32 $.imported;
    has int32 $.imported-rsa;
    has int32 $.unchanged;
    has int32 $.new-user-ids;
    has int32 $.new-sub-keys;
    has int32 $.new-signatures;
    has int32 $.new-revocations;
    has int32 $.secret-read;
    has int32 $.secret-imported;
    has int32 $.secret-unchanged;
    has int32 $.skipped-new-keys;
    has int32 $.not-imported;
    has GPGME::ImportStatus $!imports;

    method imports(GPGME::ImportResult:D: --> Seq) { $!imports.list }
}

=begin pod

=head1 NAME

GPGME::ImportResult

=head1 SYNOPSIS

  with $result
  {
    put .considered;
    put .no-user-id;
    ..
  }


=head1 DESCRIPTION

Result from an Import operation.

See L<gpgme_import_result_t|https://gnupg.org/documentation/manuals/gpgme/Importing-Keys.html> for more information.

=head1 METHODS

=item method B<considered>(GPGME::ImportResult:D: --> int32)

=item method B<no-user-id>(GPGME::ImportResult:D: --> int32)

=item method B<imported>(GPGME::ImportResult:D: --> int32)

=item method B<imported-rsa>(GPGME::ImportResult:D: --> int32)

=item method B<unchanged>(GPGME::ImportResult:D: --> int32)

=item method B<new-user-ids>(GPGME::ImportResult:D: --> int32)

=item method B<new-sub-keys>(GPGME::ImportResult:D: --> int32)

=item method B<new-signatures>(GPGME::ImportResult:D: --> int32)

=item method B<new-revocations>(GPGME::ImportResult:D: --> int32)

=item method B<secret-read>(GPGME::ImportResult:D: --> int32)

=item method B<secret-imported>(GPGME::ImportResult:D: --> int32)

=item method B<secret-unchanged>(GPGME::ImportResult:D: --> int32)

=item method B<skipped-new-keys>(GPGME::ImportResult:D: --> int32)

=item method B<not-imported>(GPGME::ImportResult:D: --> int32)

=item method B<imports>(GPGME::ImportResult:D: --> Seq)

Returns a C<GPGME::ImportStatus> for each import.

=end pod
