use NativeCall;
use GPGME::Constants;
use GPGME::Check;
use GPGME::LinkedList;

my %engines;

class GPGME::EngineInfo is repr('CStruct')            # gpgme_engine_info_t
    does GPGME::LinkedList
    does Associative
{
    has GPGME::EngineInfo $.next;
    has uint32  $.protocol;
    has Str     $.filename;
    has Str     $.version;
    has Str     $.required-version;
    has Str     $.homedir;

    method protocol(GPGME::EngineInfo:D: --> GPGME::Protocol:D)
    {
        GPGME::Protocol($!protocol) but GPGME::EnumStr[15]
    }

    sub gpgme_get_dirinfo(Str --> Str) is native {}

    method homedir(GPGME::EngineInfo:D: --> Str:D)
    {
        $!homedir // gpgme_get_dirinfo('homedir')
    }

    method Str(GPGME::EngineInfo:D: --> Str:D)
    {
        qq:to/END/;
        protocol:         $.protocol
        filename:         $.filename
        version:          $.version
        required-version: $.required-version
        homedir:          $.homedir
        END
    }

    method AT-KEY(GPGME::EngineInfo:D: Str:D $key --> GPGME::EngineInfo)
    {
        my $protocol = GPGME::Protocol::{"GPGME_PROTOCOL_$key.uc()"}
                       // die X::GPGME.new(code => GPG_ERR_INV_ENGINE);

        loop (my $i = self; $i; $i = $i.next)
        {
            return $i if $i.protocol == +$protocol
        }
        GPGME::EngineInfo
    }
}

=begin pod

=head1 NAME

GPGME::EngineInfo -- Characteristics of the crypto engine

=head1 SYNOPSIS

  my $info = GPGME.engine-info;       # Get global info for all engines

  .put for $info.list;                # Stringify each info block

  with $info<OpenPGP>                 # Associative call by protocol
  {
      put .protocol;                  # openpgp
      put .filename;                  # /usr/bin/gpg
      put .version;                   # 2.1.18
      put .required-version;          # 1.4.0
      put .homedir;                   # /home/myname/.gnupg
  }

  my $info = $gpgme.engine-info;      # Get info from a context

=head1 DESCRIPTION

Use C<GPGME> to get either the global defaults for the supported crypto
engines, or the info for a specific protocol in use by a context.

See L<Engine Information|https://www.gnupg.org/documentation/manuals/gpgme/Engine-Information.html> for more details.

=head1 METHODS

=item method B<Str>(GPGME::EngineInfo:D: --> Str:D)

Return several lines of a human readable information about the crypto engine.

=item method B<protocol>(GPGME::EngineInfo:D: --> GPGME::Protocol:D)

Returns an enumeration for the protocol.  It stringifies to the
protocol name and nummifies to the protocol id.

=item method B<filename>(GPGME::EngineInfo:D: --> Str)

The file name of the executable program implementing this protocol.

=item method B<homedir>(GPGME::EngineInfo:D: --> Str)

The directory name of the configuration directory for this crypto
engine.

=item method B<version>(GPGME::EngineInfo:D: --> Str)

This is a string containing the version number of the crypto engine.

=item method B<required-version>(GPGME::EngineInfo:D: --> Str)

This is a string containing the minimum required version number of the
crypto engine for GPGME to work correctly.

=item method B<list>(--> Seq)

Returns a list of all the engines.

=item method B<AT-KEY>(GPGME::EngineInfo:D: Str:D $key --> GPGME::EngineInfo)

Looks through the list of engines for a specific protocol.

=end pod
