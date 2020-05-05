use NativeCall;
use GPGME::Check;
use GPGME::Constants;
use GPGME::SigNotation;
use GPGME::LinkedList;
use BitEnum;

enum GPGME::KeySigBits (
    GPGME_KEYSIG_REVOKED    => 1 +< 0,
    GPGME_KEYSIG_EXPIRED    => 1 +< 1,
    GPGME_KEYSIG_INVALID    => 1 +< 2,
    GPGME_KEYSIG_EXPORTABLE => 1 +< 3,
);

class GPGME::KeySig is repr('CStruct')                         # gpgme_key_sig_t
      does GPGME::LinkedList
{
    has GPGME::KeySig $.next;
    has uint32 $.bits;
    has int32 $!pubkey-algo;
    has Str $.keyid;
    has uint64 $!ignore1;
    has uint64 $!ignore2;
    has uint8 $!ignore3;
    has long $!timestamp;
    has long $!expires;
    has uint32 $!status;
    has uint32 $!ignore4;
    has Str $.uid;
    has Str $.name;
    has Str $.email;
    has Str $.comment;
    has uint32 $.sig-class;
    has GPGME::SigNotation $.notations;

    method Str(GPGME::KeySig:D: --> Str)
    {
        "sig $.flags() $!keyid $.timestamp.Date() $!uid"
    }

    method flags(GPGME::KeySig:D: --> BitEnum)
    {
        BitEnum[GPGME::KeySigBits, prefix => 'GPGME_KEYSIG_', :lc].new($!bits)
    }

    method revoked(GPGME::KeySig:D: --> Bool:D)
    { so $!bits +& GPGME_KEYSIG_REVOKED }

    method expired(GPGME::KeySig:D: --> Bool:D)
    { so $!bits +& GPGME_KEYSIG_EXPIRED }

    method invalid(GPGME::KeySig:D: --> Bool:D)
    { so $!bits +& GPGME_KEYSIG_INVALID }

    method exportable(GPGME::KeySig:D: --> Bool:D)
    { so $!bits +& GPGME_KEYSIG_EXPORTABLE }

    method pubkey-algo(GPGME::KeySig:D: --> GPGME::PubKeyAlgorithm)
    {
        GPGME::PubKeyAlgorithm($!pubkey-algo) but GPGME::EnumStr[9]
    }

    method status(GPGME::KeySig:D:)
    {
        GPGME::Error($!status) but GPGME::EnumStr[8]
    }

    method timestamp(GPGME::KeySig:D: |opts --> DateTime:D)
    {
        DateTime.new($!timestamp, |opts)
    }

    method expires(GPGME::KeySig:D: |opts --> DateTime:D)
    {
        $!expires ?? DateTime.new($!expires, |opts)
                  !! DateTime
    }

    method notations(GPGME::KeySig:D: --> Map)
    {
        $!notations.Map
    }
}

=begin pod

=head1 NAME

GPGME::KeySig -- Key signature

=head1 SYNOPSIS

  with $keysig
  {
      put .pubkey-algo;
      put .keyid;
      ...
  }

=head1 DESCRIPTION

C<GPGME::KeySig> is a key signature structure. Key signatures are one
component of a C<GPGME::Key> object, and validate user IDs on the key
in the OpenPGP protocol.

The signatures on a key are only available if the key was retrieved
via a listing operation with the C<:keylist-mode<sigs>> mode enabled,
because it can be expensive to retrieve all signatures of a key.

The signature notations on a key signature are only available if the
key was retrieved via a listing operation with the
C<:keylist-mode<sig_notations>> mode enabled, because it can be
expensive to retrieve all signature notations.

See L<gpgme_key_sig_t|https://www.gnupg.org/documentation/manuals/gpgme/Key-objects.html> for more details.

=head1 METHODS

=item method B<Str>(GPGME::KeySig:D: --> Str)

=item method B<revoked>(GPGME::KeySig:D: --> Bool:D)

=item method B<expired>(GPGME::KeySig:D: --> Bool:D)

=item method B<invalid>(GPGME::KeySig:D: --> Bool:D)

=item method B<exportable>(GPGME::KeySig:D: --> Bool:D)

=item method B<pubkey-algo>(GPGME::KeySig:D: --> GPGME::PubKeyAlgorithm)

An enumeration for the public key algorithm used in the encryption.
It stringifies to the name of the algorithm and numifies to the
algorithm id.

=item method B<status>(GPGME::KeySig:D:)

=item method B<keyid>(GPGME::KeySig:D: --> Str)

=item method B<timestamp>(GPGME::KeySig:D: --> DateTime:D)

=item method B<expires>(GPGME::KeySig:D: --> DateTime)

=item method B<uid>(GPGME::KeySig:D: --> Str)

=item method B<name>(GPGME::KeySig:D: --> Str)

=item method B<email>(GPGME::KeySig:D: --> Str)

=item method B<comment>(GPGME::KeySig:D: --> Str)

=item method B<sig-class>(GPGME::KeySig:D: --> uint32)

=item method B<notations>(GPGME::KeySig:D: --> Map)

=end pod
