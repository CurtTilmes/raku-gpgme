use NativeCall;
use GPGME::Recipient;
use BitEnum;

enum GPGME::DecryptResultBits (
    GPGME_DECRYPTRESULTBITS_WRONG_KEY_USAGE   => 1 +< 0,
    GPGME_DECRYPTRESULTBITS_IS_DE_VS          => 1 +< 1,
);

class GPGME::DecryptResult is repr('CStruct')         # gpgme_decrypt_result_t
{
    has Str $.unsupported_algorithm;
    has uint32 $!bits;
    has GPGME::Recipient $!recipients;
    has Str $.file-name;
    has Str $.session-key;

    method wrong-key-usage(GPGME::DecryptResult:D: --> Bool:D)
    { so $!bits +& GPGME_DECRYPTRESULTBITS_WRONG_KEY_USAGE }

    method is-de-vs(GPGME::DecryptResult:D: --> Bool:D)
    { so $!bits +& GPGME_DECRYPTRESULTBITS_IS_DE_VS }

    method recipients(GPGME::DecryptResult:D: --> Seq) { $!recipients.list }
}

=begin pod

=head1 NAME

GPGME::DecryptResult -- Extra information about a decryption

=head1 SYNOPSIS

    with $result
    {
        put .unsupported-algorithm;
        put .file-name;
        put .session-key;
        put .wrong-key-usage;
        put .is-de-vs;
        .keyid.put for .recipients;
    }

=head1 DESCRIPTION

After a decryption, the context result holds this object with more
information about the decyprtion.

See L<gpgme_decrypt_result_t|https://www.gnupg.org/documentation/manuals/gpgme/Decrypt.html> for more details.

=head1 METHODS

=item method B<unsupported-algorithm>(GPGME::DecryptResult:D: --> Str)

If an unsupported algorithm was encountered, this string describes the
algorithm that is not supported.

=item method B<file-name>(GPGME::DecryptResult:D: --> Str)

This is the filename of the original plaintext message file if it is known.

=item method B<session-key>(GPGME::DecryptResult:D: --> Str)

A textual representation) of the session key used in symmetric
encryption of the message, if the context has been set to export
session keys (see flag "export-session-key"), and a session key was
available for the most recent decryption operation.

=item method B<wrong-key-usage>(GPGME::DecryptResult:D: --> Bool:D)

This is true if the key was not used according to its policy.

=item method B<is-de-vs>(GPGME::DecryptResult:D: --> Bool:D)

The message was encrypted in a VS-NfD compliant way. This is a
specification in Germany for a restricted communication level.

=item method B<recipients>(GPGME::DecryptResult:D: --> Seq)

Returns a list of C<GPGME::Recipient>s to which this message was encrypted.

=end pod
