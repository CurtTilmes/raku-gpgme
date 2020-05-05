use NativeCall;
use GPGME::Constants;
use GPGME::Check;
use GPGME::LinkedList;
use BitEnum;

constant \GPGME_TOFU_VALIDITY_MASK = 0b0000111;
constant \GPGME_TOFU_POLICY_MASK   = 0b1111000;

class GPGME::TOFU is repr('CStruct') # gpgme_tofu_info_t
    does GPGME::LinkedList
{
    has GPGME::TOFU $.next;
    has uint32 $!bits;
    has uint16 $.signcount;
    has uint16 $.encrcount;
    has ulong $!signfirst;
    has ulong $!signlast;
    has ulong $!encrfirst;
    has ulong $!encrlast;
    has Str $.description;

    method Str(--> Str) { $!description }

    method validity(GPGME::TOFU:D: --> GPGME::TOFUValidity)
    {
        GPGME::TOFUValidity($!bits +& GPGME_TOFU_VALIDITY_MASK)
            but GPGME::EnumStr[20]
    }

    method policy(GPGME::TOFU:D: --> GPGME::TOFUPolicy)
    {
        GPGME::TOFUPolicy(($!bits +& GPGME_TOFU_POLICY_MASK) +> 3)
            but GPGME::EnumStr[18]
    }

    method signfirst(GPGME::TOFU:D: |opts --> DateTime:D)
    {
        DateTime.new($!signfirst, |opts)
    }

    method signlast(GPGME::TOFU:D: |opts --> DateTime:D)
    {
        DateTime.new($!signlast, |opts)
    }

    method encrfirst(GPGME::TOFU:D: |opts --> DateTime:D)
    {
        DateTime.new($!encrfirst, |opts)
    }

    method encrlast(GPGME::TOFU:D: |opts --> DateTime:D)
    {
        DateTime.new($!encrlast, |opts)
    }
}

=begin pod

=head1 NAME

GPGME::TOFU - Trust on First Use information

=head1 SYNOPSIS

  with $tofu
  {
      .put;            # Stringify summary
      put .validity;
      put .policy;
      put .signcount;
      put .encrcount;
  }

=head1 DESCRIPTION

See L<gpgme_tofu_info_t|https://gnupg.org/documentation/manuals/gpgme/Key-objects.html> for more information.

=head1 METHODS

=item method B<Str>(--> Str)

=item method B<validity>(GPGME::TOFU:D: --> GPGME::TOFUValidity)

An enumeration that stringifies to the amount of validity.

=item method B<policy>(GPGME::TOFU:D: --> GPGME::TOFUPolicy)

An enumeration that stringifies to the TOFU policy.

=item method B<signcount>(GPGME::TOFU:D: --> uint16)

=item method B<encrcount>(GPGME::TOFU:D: --> uint16)

=item method B<signfirst>(GPGME::TOFU:D: --> DateTime)

=item method B<signlast>(GPGME::TOFU:D: --> DateTime)

=item method B<encrfirst>(GPGME::TOFU:D: --> DateTime)

=item method B<encrlast>(GPGME::TOFU:D: --> DateTime)

=item method B<description>(GPGME::TOFU:D: --> Str)

=end pod
