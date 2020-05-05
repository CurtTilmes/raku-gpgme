use NativeCall;
use GPGME::Constants;
use GPGME::Check;
use GPGME::LinkedList;

class GPGME::InvalidKey is repr('CStruct')              # gpgme_invalid_key_t
    does GPGME::LinkedList
{
    has GPGME::InvalidKey $.next;
    has Str $.fpr;
    has uint32 $!reason;

    method reason(GPGME::InvalidKey:D: --> Str)
    {
        $!reason == GPG_ERR_NO_ERROR
            ?? 'Success'
            !! X::GPGME.new(code => $!reason).message
    }
}

=begin pod

=head1 NAME

GPGME::InvalidKey - Information about invalid keys

=head1 SYNOPSIS

  with $invalidkey
  {
    put .fpr;
    put .reason;
  }

=head1 DESCRIPTION

Holds the fingerprint and reason a key is invalid.

=head1 METHODS

=item method B<fpr>(GPGME::InvalidKey:D: --> Str)

=item method B<reason>(GPGME::InvalidKey:D: --> Str)

=end pod
