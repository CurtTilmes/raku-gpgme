use NativeCall;
use GPGME::Constants;
use GPGME::LinkedList;

class GPGME::Recipient is repr('CStruct')               # gpgme_recipient_t
    does GPGME::LinkedList
{
    has GPGME::Recipient $.next;
    has Str $.keyid;
    has int64 $!ignore1;
    has int64 $!ignore2;
    has int8  $!ignore3;
    has int32 $!pubkey-algo;
    has uint32 $!status;

    method pubkey-algo(GPGME::Recipient:D: --> GPGME::PubKeyAlgorithm)
    {
        GPGME::PubKeyAlgorithm($!pubkey-algo) but GPGME::EnumStr[9]
    }

    method status(GPGME::Recipient:D: --> Bool:D) { $!status == 0 }
}

=begin pod

=head1 NAME

GPGME::Recipient -- Information about Recipients of a decryption

=head1 SYNOPSIS

   with $recipient
   {
       put .keyid;
       put .pubkey-algo;
       put .status;
   }

=head1 DESCRIPTION

After a decryption, the list of recipients can be retrieved with more
information.

See L<gpgme_recipient_t|https://www.gnupg.org/documentation/manuals/gpgme/Decrypt.html> for more details.

=head1 METHODS

=item method B<keyid>(GPGME::Recipient:D: --> Str)

This is the key ID of the key (in hexadecimal digits) used as recipient.

=item method B<pubkey-algo>(GPGME::Recipient:D: --> GPGME::PubKeyAlgorithm)

An enumeration for the public key algorithm used in the encryption.
It stringifies to the name of the algorithm and numifies to the
algorithm id.

=item method B<status>(GPGME::Recipient:D: --> Bool:D)

C<True> if the secret key for this recipient is available.

=end pod
