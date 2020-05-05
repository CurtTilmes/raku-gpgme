use NativeCall;
use GPGME::Check;
use GPGME::LinkedList;
use BitEnum;

class GPGME::SigNotation is repr('CStruct')             # gpgme_sig_notation_t
      does GPGME::LinkedList
{
    has GPGME::SigNotation $.next;
    has Str $.name;
    has Str $.value;
    has int32 $!name-len;
    has int32 $!value-len;
    has uint32 $!flags;           # Ignore for now, assume human readable
    has uint32 $!bits;            # Ignore for now, assume human readable

    multi method Map(GPGME::SigNotation:U: --> Map:D) { Map.new }

    multi method Map(GPGME::SigNotation:D: --> Map:D)
    {
        Map.new: do for self.list { .name => .value }
    }
}

=begin pod

=head1 NAME

GPGME::SigNotation - Information about Signature Notations

=head1 SYNOPSIS

  put $notation.Map;

=head1 DESCRIPTION

Each Signature Notation has a name and a value.  You can get a C<list>
of them or a C<Map> of them.

See L<gpgme_sig_notation_t|https://gnupg.org/documentation/manuals/gpgme/Verify.html> for more information.

=head1 METHODS

=item method B<name>(GPGME::SigNotation:D --> Str)

=item method B<value>(GPGME::SigNotation:D --> Str)

=item method B<list>(GPGME::SigNotation:D --> Seq)

=item method B<Map>(--> Map:D)

=end pod
