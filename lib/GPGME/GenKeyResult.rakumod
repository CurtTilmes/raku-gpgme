use NativeCall;
use GPGME::DataHandle;

enum GPGME::GenKeyResultBits (
    GPGME_GENKEYRESULTBITS_PRIMARY => 1 +< 0,
    GPGME_GENKEYRESULTBITS_SUB     => 1 +< 1,
    GPGME_GENKEYRESULTBITS_UID     => 1 +< 2,
);

class GPGME::GenKeyResult is repr('CStruct')           # gpgme_genkey_result_t
{
    has uint32 $!bits;
    has Str $.fpr;
    has GPGME::DataHandle $!pubkey;
    has GPGME::DataHandle $!seckey;

    method Str(GPGME::GenKeyResult:D: --> Str:D)
    {
        with self
        {
            (.primary ?? 'p' !! '') ~
            (.sub     ?? 's' !! '') ~
            (.uid     ?? 'u' !! '') ~ ' ' ~
            .fpr
        }
    }

    method primary(GPGME::GenKeyResult:D: --> Bool:D)
    {
        so $!bits +& GPGME_GENKEYRESULTBITS_PRIMARY
    }

    method sub(GPGME::GenKeyResult:D:--> Bool:D)
    {
        so $!bits +& GPGME_GENKEYRESULTBITS_SUB
    }

    method uid(GPGME::GenKeyResult:D:--> Bool:D)
    {
        so $!bits +& GPGME_GENKEYRESULTBITS_UID
    }
}

=begin pod

=head1 NAME

GPGME::GenKeyResult -- Result from Generating a Key

=head1 SYNOPSIS

  with $result
  {
      say 'primary key created' if .primary;
      say 'subkey was created'  if .sub;
      say 'user ID was created' if .uid;
      say  "Key Fingerprint: ", .fpr;
  }

=head1 DESCRIPTION

After performing a key generation, these results are available.

See L<gpgme_genkey_result_t|https://gnupg.org/documentation/manuals/gpgme/Generating-Keys.html> for more details.

=head1 METHODS

=item method B<Str>(GPGME::GenKeyResult:D: --> Str:D)

Summarize the Generation Result.

=item method B<primary>(GPGME::GenKeyResult:D: --> Bool:D)

True if a primary key was created.

=item method B<sub>(GPGME::GenKeyResult:D:--> Bool:D)

True if a subkey was created.

=item method B<uid>(GPGME::GenKeyResult:D:--> Bool:D)

True if a user ID was created.

=item method B<fpr>(GPGME::GenKeyResult:D:--> Str)

The fingerprint of the key that was created.  If both a primary and a
subkey were generated, the fingerprint of the primary key will be
returned.

=end pod
