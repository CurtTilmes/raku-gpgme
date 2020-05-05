use NativeCall;
use GPGME::Constants;
use GPGME::Check;
use GPGME::LinkedList;
use GPGME::SigNotation;
use GPGME::Key;
use BitEnum;

class GPGME::Signature is repr('CStruct')                # gpgme_signature_t
    does GPGME::LinkedList
{
    has GPGME::Signature $.next;
    has int32 $!summary;
    has Str $.fpr;
    has uint32 $!status;
    has GPGME::SigNotation $!notations;
    has ulong $!timestamp;
    has ulong $!expiretime;
    has uint32 $!bits;
    has int32 $!validity;
    has int32 $!reason;
    has int32 $!pubkey-algo;
    has int32 $!hash-algo;
    has Str $.pka-address;
    has GPGME::Key $.key;

    method summary(GPGME::Signature:D: --> BitEnum)
    {
        BitEnum[GPGME::SigSum, prefix => 'GPGME_SIGSUM_', :lc].new($!summary)
    }

    method status(GPGME::Signature:D: --> Str)
    {
        $!status == GPG_ERR_NO_ERROR
            ?? 'Success'
            !! X::GPGME.new(code => $!status).message
    }

    method notations(GPGME::Signature:D: --> Map) { $!notations.Map }

    method timestamp(GPGME::Signature:D: |opts --> DateTime:D)
    {
        DateTime.new($!timestamp, |opts)
    }

    method expiretime(GPGME::Signature:D: |opts --> DateTime)
    {
        $!expiretime ?? DateTime.new($!expiretime, |opts)
                     !! DateTime
    }

    method validity(GPGME::Signature:D: --> GPGME::Validity)
    {
        GPGME::Validity($!validity) but GPGME::EnumStr[15]
    }

    method validity-reason(GPGME::Signature:D: --> Str)
    {
        X::GPGME.new(code => $!reason).message
    }

    method pubkey-algo(GPGME::Signature:D: --> GPGME::PubKeyAlgorithm:D)
    {
        GPGME::PubKeyAlgorithm($!pubkey-algo) but GPGME::EnumStr[9]
    }

    method hash-algo(GPGME::Signature:D: --> GPGME::HashAlgorithm:D)
    {
        GPGME::HashAlgorithm($!hash-algo) but GPGME::EnumStr[9]
    }
}

=begin pod

=head1 NAME

GPGME::Signature - Information about signatures

=head1 SYNOPSIS

  with $signature
  {
      put .summary;
      put .status
      ...
  }

=head1 DESCRIPTION

See L<gpgme_signature_t|https://gnupg.org/documentation/manuals/gpgme/Verify.html> for more information.

=head1 METHODS

=item method B<summary>(GPGME::Signature:D: --> BitEnum)

=item method B<status>(GPGME::Signature:D: --> Str)

=item method B<notations>(GPGME::Signature:D: --> Map)

=item method B<timestamp>(GPGME::Signature:D: |opts --> DateTime:D)

=item method B<expiretime>(GPGME::Signature:D: |opts --> DateTime)

=item method B<validity>(GPGME::Signature:D: --> GPGME::Validity)

=item method B<validity-reason>(GPGME::Signature:D: --> Str)

=item method B<pubkey-algo>(GPGME::Signature:D: --> GPGME::PubKeyAlgorithm:D)

=item method B<hash-algo>(GPGME::Signature:D: --> GPGME::HashAlgorithm:D)

=end pod
