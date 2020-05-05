use NativeCall;
use GPGME::InvalidKey;
use GPGME::NewSignature;

class GPGME::SignResult is repr('CStruct')             # gpgme_sign_result_t
{
    has GPGME::InvalidKey $!invalid-signers;
    has GPGME::NewSignature $!signatures;

    method signatures(GPGME::SignResult:D: --> Seq)
    {
        $!signatures.list
    }

    method invalid-signers(GPGME::SignResult:D: --> Seq)
    {
        $!invalid-signers.list
    }
}

=begin pod

=head1 NAME

GPGME::SignResult - Result from a Sign operation

=head1 SYNOPSIS

  with $result
  {
     .put for .signatures;
     .put for .invalid-signers;
  }

=head1 DESCRIPTION

See L<gpgme_sign_result_t|https://gnupg.org/documentation/manuals/gpgme/Creating-a-Signature.html>.

=head1 METHODS

=item method B<signatures>(GPGME::SignResult:D: --> Seq)

Returns a sequence of C<GPGME::NewSignature>s.

=item method B<invalid-signers>(GPGME::SignResult:D: --> Seq)

Returns a sequence of C<GPGME::InvalidKey>s.

=end pod
