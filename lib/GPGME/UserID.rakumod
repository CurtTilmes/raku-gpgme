use NativeCall;
use GPGME::Check;
use GPGME::Constants;
use GPGME::KeySig;
use GPGME::TOFU;
use GPGME::LinkedList;
use BitEnum;

enum GPGME::UseridBits (
    GPGME_USERID_BITS_REVOKED => 1 +< 0,
    GPGME_USERID_BITS_INVALID => 1 +< 1,
);

class GPGME::UserID is repr('CStruct')                   # gpgme_user_id_t
    does GPGME::LinkedList
{
    has GPGME::UserID $.next;
    has uint32 $!bits;
    has int32 $!validity;
    has Str $.uid;
    has Str $.name;
    has Str $.email;
    has Str $.comment;
    has GPGME::KeySig $!signatures;
    has Pointer $!ignore;
    has Str $.address;
    has GPGME::TOFU $!tofu;
    has ulong $!last-update;

    method Str(GPGME::UserID:D: --> Str:D)
    {
        "uid [$.validity()] {$!name // ''}"                        ~
        "{ " ($!comment)" if ($!comment and $!comment.chars)} "    ~
        "{ "<$!email>" if $!email}\n"
    }

    method revoked(GPGME::UserID:D: --> Bool:D)
    {
        so $!bits +& GPGME_USERID_BITS_REVOKED
    }

    method invalid(GPGME::UserID:D: --> Bool:D)
    {
        so $!bits +& GPGME_USERID_BITS_INVALID
    }

    method validity(GPGME::UserID:D: --> GPGME::Validity)
    {
        GPGME::Validity($!validity) but GPGME::EnumStr[15]
    }

    method last-update(GPGME::UserID:D: |opts --> DateTime)
    {
        $!last-update ?? DateTime.new($!last-update,|opts)
                      !! DateTime
    }

    method signatures(GPGME::UserID:D: --> Seq)
    {
        $!signatures.list
    }

    method tofu(GPGME::UserID:D: --> Seq)
    {
        $!tofu.list
    }
}

=begin pod

=head1 NAME

GPGME::UserID - User ID Information

=head1 SYNOPSIS

  with $userid
  {
      .put;                    # Stringify to summary
      put .uid;
      put .name;
      put .email;
      put .comment;
  }

=head1 DESCRIPTION

See L<gpgme_user_id_t|https://gnupg.org/documentation/manuals/gpgme/Key-objects.html> for more information

=head1 METHODS

=item method B<Str>(GPGME::UserID:D: --> Str:D)

=item method B<validity>(GPGME::UserID:D: --> GPGME::Validity)

An enumeration that stringifies to the validity;

=item method B<uid>(GPGME::UserID:D: --> Str)

=item method B<name>(GPGME::UserID:D: --> Str)

=item method B<email>(GPGME::UserID:D: --> Str)

=item method B<comment>(GPGME::UserID:D: --> Str)

=item method B<signatures>(GPGME::UserID:D: --> Seq)

Returns a C<GPGME::KeySig> for each signature.

=item method B<address>(GPGME::UserID:D: --> Str)

=item method B<tofu>(GPGME::UserID:D: --> Seq)

Returns a C<GPGME::TOFU> for each tofu (trust on first use).

=item method B<last-update>(GPGME::UserID:D: --> DateTime)

=end pod
