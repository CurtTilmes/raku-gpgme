use NativeCall;
use GPGME::Signature;

class GPGME::VerifyResult is repr('CStruct')            # gpgme_verify_result_t
{
    has GPGME::Signature $!signatures;
    has Str $.file-name;

    method signatures(GPGME::VerifyResult:D: --> Seq) { $!signatures.list }
}

=begin pod

=head1 NAME

GPGME::VerifyResult

=head1 SYNOPSIS

  with $result
  {
      put .file-name;
      .summary.put for .signatures;
  }

=head1 DESCRIPTION

See L<gpgme_verify_result_t|https://gnupg.org/documentation/manuals/gpgme/Verify.html> for more information.

=head1 METHODS

=item method B<file-name>(GPGME::VerifyResult:D: --> Str)

=item method B<signatures>(GPGME::VerifyResult:D: --> Seq)

Returns a C<GPGME::Signature> for each signature.

=end pod
