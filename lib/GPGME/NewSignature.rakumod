use NativeCall;
use GPGME::Constants;
use GPGME::LinkedList;

class GPGME::NewSignature is repr('CStruct')             # gpgme_new_signature_t
      does GPGME::LinkedList
{
    has GPGME::NewSignature $.next;
    has int32 $!type;
    has int32 $!pubkey-algo;
    has int32 $!hash-algo;
    has ulong $!ignore;
    has long $!timestamp;
    has Str $.fpr;
    has uint32 $!ignore2;
    has uint32 $.sig-class;

    method type(GPGME::NewSignature:D: --> GPGME::SigMode)
    {
        GPGME::SigMode($!type) but GPGME::EnumStr[15]
    }

    method pubkey-algo(GPGME::NewSignature:D: --> GPGME::PubKeyAlgorithm)
    {
        GPGME::PubKeyAlgorithm($!pubkey-algo) but GPGME::EnumStr[9]
    }

    method hash-algo(GPGME::NewSignature:D: --> GPGME::HashAlgorithm)
    {
        GPGME::HashAlgorithm($!hash-algo) but GPGME::EnumStr[9]
    }

    method timestamp(GPGME::NewSignature:D: |opts --> DateTime:D)
    {
        DateTime.new($!timestamp, |opts)
    }
}

=begin pod

=head1 NAME

GPGME::NewSignature

=head1 SYNOPSIS

  with $newsig
  {
      put .pubkey-algo;
      put .fpr;
  }

=head1 DESCRIPTION

See L<gpgme_new_signature_t|https://gnupg.org/documentation/manuals/gpgme/Creating-a-Signature.html>

=head1 METHODS

=item method B<type>(GPGME::NewSignature:D: --> GPGME::SigMode)

=item method B<pubkey-algo>(GPGME::NewSignature:D: --> GPGME::PubKeyAlgorithm)

=item method B<hash-algo>(GPGME::NewSignature:D: --> GPGME::HashAlgorithm)

=item method B<timestamp>(GPGME::NewSignature:D: |opts --> DateTime:D)

=item method B<fpr>(--> Str)

=item method B<sig-class>(--> uint32)

=end pod
