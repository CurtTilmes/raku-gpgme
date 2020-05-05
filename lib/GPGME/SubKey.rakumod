use NativeCall;
use GPGME::Check;
use GPGME::Constants;
use GPGME::LinkedList;
use BitEnum;

enum GPGME::SubKeyBits (
    GPGME_SUBKEYBITS_REVOKED          => 1 +< 0,
    GPGME_SUBKEYBITS_EXPIRED          => 1 +< 1,
    GPGME_SUBKEYBITS_DISABLED         => 1 +< 2,
    GPGME_SUBKEYBITS_INVALID          => 1 +< 3,
    GPGME_SUBKEYBITS_CAN_ENCRYPT      => 1 +< 4,
    GPGME_SUBKEYBITS_CAN_SIGN         => 1 +< 5,
    GPGME_SUBKEYBITS_CAN_CERTIFY      => 1 +< 6,
    GPGME_SUBKEYBITS_SECRET           => 1 +< 7,
    GPGME_SUBKEYBITS_CAN_AUTHENTICATE => 1 +< 8,
    GPGME_SUBKEYBITS_IS_QUALIFIED     => 1 +< 9,
    GPGME_SUBKEYBITS_IS_CARDKEY       => 1 +< 10,
    GPGME_SUBKEYBITS_IS_DE_VS         => 1 +< 11,
);

class GPGME::SubKey is repr('CStruct')                         # gpgme_subkey_t
                    does GPGME::LinkedList
{
    has GPGME::SubKey $.next;
    has uint32 $!bits;
    has int32 $!pubkey-algo;
    has uint32 $.length;
    has Str $.keyid;
    has uint64 $!ignore1;
    has uint64 $!ignore2;
    has uint8 $!ignore3;
    has Str $.fpr;
    has long $!timestamp;
    has long $!expires;
    has Str $.card-number;
    has Str $.curve;
    has Str $.keygrip;

    method Str(GPGME::SubKey:D: --> Str:D)
    {
        "$.type $.pubkey-algo$!length $.timestamp.Date() " ~
        "[$.capabilities()]" ~
        "{(' [expires: ' ~ .Date ~ ']') with $.expires} $!fpr"
    }

    method capabilities(GPGME::SubKey:D: --> Str:D)
    {
          ($.can-encrypt      ?? 'e' !! '')
              ~
          ($.can-sign         ?? 's' !! '')
              ~
          ($.can-certify      ?? 'c' !! '')
              ~
          ($.can-authenticate ?? 'a' !! '')
              ~
          ($.disabled         ?? 'D' !! '')
    }

    method flags() { BitEnum[GPGME::SubKeyBits, prefix => 'GPGME_SUBKEYBITS_',
                             :lc].new($!bits) }

    method pubkey-algo(GPGME::SubKey:D: --> GPGME::PubKeyAlgorithm:D)
    {
        GPGME::PubKeyAlgorithm($!pubkey-algo) but GPGME::EnumStr[9]
    }

    method type(GPGME::SubKey:D: --> Str:D) { $.secret ?? 'sec' !! 'pub' }

    method revoked(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_REVOKED }

    method expired(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_EXPIRED }

    method disabled(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_DISABLED }

    method invalid(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_INVALID }

    method can-encrypt(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_CAN_ENCRYPT }

    method can-sign(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_CAN_SIGN }

    method can-certify(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_CAN_CERTIFY }

    method secret(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_SECRET }

    method can-authenticate(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_CAN_AUTHENTICATE }

    method is-qualified(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_IS_QUALIFIED }

    method is-cardkey(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_IS_CARDKEY }

    method is-de-vs(GPGME::SubKey:D: --> Bool:D)
    { so $!bits +& GPGME_SUBKEYBITS_IS_DE_VS }

    method timestamp(GPGME::SubKey:D: |opts --> DateTime:D)
    {
        DateTime.new($!timestamp, |opts)
    }

    method expires(GPGME::SubKey:D: |opts --> DateTime)
    {
        $!expires ?? DateTime.new($!expires, |opts) !! DateTime
    }
}

=begin pod

=head1 NAME

GPGME::SubKey - Information about subkey

=head1 SYNOPSIS

  with $subkey
  {
      put "Algorithm: ", .pubkey-algo;
      put "revoked" if .revoked;
      ...
  }

=head1 DESCRIPTION

See L<gpgme_subkey_t|https://www.gnupg.org/documentation/manuals/gpgme/Key-objects.html> for more details.

=head1 METHODS

=item B<Str>(GPGME::SubKey:D: --> Str:D)

Stringify to a short summary of the key.

=item B<list>()

A list of the subkeys.

=item B<capabilities>(GPGME::SubKey:D: --> Str:D)

A short string summary of the key's capabilities:
* (e)ncrypt
* (s)ign
* (c)ertify
* (a)uthenticate
* (D)isabled

=item B<pubkey-algo>(--> GPGME::PubKeyAlgorithm:D)

A C<GPGME::PubKeyAlgorithm> enumeration that stringifies to the
algorithm name and numifies to its id.

=item B<length>(GPGME::SubKey:D: --> uint32)

=item B<keyid>(GPGME::SubKey:D: --> Str)

=item B<fpr>(GPGME::SubKey:D: --> Str)

Fingerprint for the key.

=item B<type>(GPGME::SubKey:D: --> Str:D)

'sec' for secret key or 'pub' for public key.

=item B<revoked>(GPGME::SubKey:D: --> Bool:D)

=item B<expired>(GPGME::SubKey:D: --> Bool:D)

=item B<disabled>(GPGME::SubKey:D: --> Bool:D)

=item B<invalid>(GPGME::SubKey:D: --> Bool:D)

=item B<can-encrypt>(GPGME::SubKey:D: --> Bool:D)

=item B<can-sign>(GPGME::SubKey:D: --> Bool:D)

=item B<can-certify>(GPGME::SubKey:D: --> Bool:D)

=item B<secret>(GPGME::SubKey:D: --> Bool:D)

=item B<can-authenticate>(GPGME::SubKey:D: --> Bool:D)

=item B<is-qualified>(GPGME::SubKey:D: --> Bool:D)

=item B<is-cardkey>(GPGME::SubKey:D: --> Bool:D)

=item B<is-de-vs>(GPGME::SubKey:D: --> Bool:D)

=item B<timestamp>(GPGME::SubKey:D: |opts --> DateTime:D)

Timestamp of the key, pass in options for C<DateTime> creation.

=item B<expires>(GPGME::SubKey:D: |opts --> DateTime)

Expire time of the key if available.

=item B<card-number>(GPGME::SubKey:D: --> Str)

=item B<curve>(GPGME::SubKey:D: --> Str)

=item B<keygrip>(GPGME::SubKey:D: --> Str)

=end pod
