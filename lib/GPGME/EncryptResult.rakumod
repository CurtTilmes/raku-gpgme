use NativeCall;
use GPGME::InvalidKey;

class GPGME::EncryptResult is repr('CStruct')          # gpgme_encrypt_result_t
{
    has GPGME::InvalidKey $!invalid-recipients;

    method invalid-recipients(GPGME::EncryptResult:D: --> Seq)
    {
        $!invalid-recipients.list
    }
}

=begin pod

=head1 NAME

GPGME::EncryptResult

=head1 SYNOPSIS

  for $result.invalid-recipients
  {
    put .fpr;
    put .reason;
  }

=head1 DESCRIPTION

Result from an Encryption operation.

See L<gpgme_encrypt_result_t|https://gnupg.org/documentation/manuals/gpgme/Encrypting-a-Plaintext.html> for more information.

=head1 METHODS

=item method B<invalid-recipients>(GPGME::EncryptResult:D: --> Seq)

Returns a C<GPGME::InvalidKey> for each invalid recipient.

=end pod
