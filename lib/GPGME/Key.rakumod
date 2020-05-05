use NativeCall;
use GPGME::Check;
use GPGME::SubKey;
use GPGME::UserID;

enum GPGME::KeyBits (
    GPGME_KEYBITS_REVOKED          => 1 +< 0,
    GPGME_KEYBITS_EXPIRED          => 1 +< 1,
    GPGME_KEYBITS_DISABLED         => 1 +< 2,
    GPGME_KEYBITS_INVALID          => 1 +< 3,
    GPGME_KEYBITS_CAN_ENCRYPT      => 1 +< 4,
    GPGME_KEYBITS_CAN_SIGN         => 1 +< 5,
    GPGME_KEYBITS_CAN_CERTIFY      => 1 +< 6,
    GPGME_KEYBITS_SECRET           => 1 +< 7,
    GPGME_KEYBITS_CAN_AUTHENTICATE => 1 +< 8,
    GPGME_KEYBITS_IS_QUALIFIED     => 1 +< 9,
);

class GPGME::Key is repr('CStruct')                           # gpgme_key_t
{
    has uint32 $!refs;
    has uint32 $!bits;
    has int32 $!protocol;
    has Str $.issuer-serial;
    has Str $.issuer-name;
    has Str $.chain-id;
    has int32 $!owner-trust;
    has GPGME::SubKey $!subkeys;
    has GPGME::UserID $!uids;
    has Pointer $!ignore1;
    has Pointer $!ignore2;
    has uint32 $!keylist-mode;
    has Str $.fpr;
    has ulong $!last-update;

    method Str(GPGME::Key:D: --> Str:D)
    {
        join "\n", $.subkeys.list, $.uids.list
    }

    method revoked(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_REVOKED }

    method expired(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_EXPIRED }

    method disabled(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_DISABLED }

    method invalid(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_INVALID }

    method can-encrypt(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_CAN_ENCRYPT }

    method can-sign(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_CAN_SIGN }

    method can-certify(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_CAN_CERTIFY }

    method secret(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_SECRET }

    method can-authenticate(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_CAN_AUTHENTICATE }

    method is-qualified(GPGME::Key:D: --> Bool:D)
    { so $!bits +& GPGME_KEYBITS_IS_QUALIFIED }

    method protocol(GPGME::Key:D: --> GPGME::Protocol)
    {
        GPGME::Protocol($!protocol) but GPGME::EnumStr[15]
    }

    method owner-trust(GPGME::Key:D: --> GPGME::Validity)
    {
        GPGME::Validity($!owner-trust) but GPGME::EnumStr[15]
    }

    method subkeys(GPGME::Key:D: --> Seq) { $!subkeys.list }

    method uids(GPGME::Key:D: --> Seq) { $!uids.list }

    method keylist-mode(GPGME::Key:D: --> GPGME::KeylistMode)
    {
        GPGME::KeylistMode($!keylist-mode) but GPGME::EnumStr[19]
    }

    method last-update(GPGME::Key:D: |opts --> DateTime)
    {
        $!last-update ?? DateTime.new($!last-update, |opts)
                      !! DateTime
    }

    method unref() is native is symbol('gpgme_key_unref') {}

    submethod DESTROY() { .unref with self }
}

=begin pod

=head1 NAME

GPGME::Key -- Information about a key

=head1 SYNOPSIS

  with $key
  {
      .put;                         # Stringify summary of key
      put .protocol;
      put .issuer-serial;
      ...
  }

=head1 DESCRIPTION

Holds information about a key.

See L<gpgme_key_t|https://gnupg.org/documentation/manuals/gpgme/Key-objects.html> for more information.

=head1 METHODS

=item method B<Str>(GPGME::Key:D: --> Str:D)

Stringify to a summary of the key.

=item method B<protocol>(GPGME::Key:D: --> GPGME::Protocol)

An enumerated object that stringifies to the name of the protocol.

=item method B<issuer-serial>(GPGME::Key:D: --> Str)

=item method B<issuer-name>(GPGME::Key:D: --> Str)

=item method B<chain-id>(GPGME::Key:D: --> Str)

=item method B<owner-trust>(GPGME::Key:D: --> GPGME::Validity)

An enumerated object that stringifies to the type of validity.

=item method B<subkeys>(GPGME::Key:D: --> Seq)

Returns a C<GPGME::SubKey> for each subkey for the key.

=item method B<uids>(GPGME::Key:D: --> Seq)

Returns a C<GPGME::UserID> for each user ID associated with the key.

=item method B<keylist-mode>(GPGME::Key:D: --> GPGME::KeylistMode)

An enumerated object that stringifies to the key listing mode

=item method B<fpr>(GPGME::Key:D: --> Str)

Key fingerprint.

=item method B<last-update>(GPGME::Key:D: --> DateTime)

DateTime of last update.

=end pod
