use NativeCall;
use GPGME::Check;
use GPGME::Constants;
use GPGME::DataHandle;

class GPGME::Data is IO::Handle
{
    has GPGME::DataHandle $.handle;
    has Bool:D $.EOF = False;
    has IO::Handle $!fh is built;
    has Str:D $!encoding is built = 'utf8';

    sub gpgme_data_new(Pointer $ptr is rw --> uint32)
        is native {}

    multi method new(GPGME::Data:U: Any:U, |opts --> GPGME::Data)
    {
        my Pointer $ptr .= new;
        check gpgme_data_new($ptr);
        samewith $ptr, |opts
    }

    sub gpgme_data_new_from_mem(Pointer is rw, Blob, size_t, int32 --> uint32)
        is native {}

    multi method new(GPGME::Data:U: Blob:D $buf, Bool :$copy = True, |opts
                     --> GPGME::Data)
    {
        my Pointer $ptr .= new;
        check gpgme_data_new_from_mem($ptr, $buf, $buf.bytes,
                                             $copy ?? 1 !! 0);
        samewith $ptr, |opts
    }

    multi method new(GPGME::Data:U: Str:D $str, |opts --> GPGME::Data)
    {
        samewith $str.encode, |opts
    }

    sub gpgme_data_new_from_file(Pointer is rw, Str, int32 --> uint32)
        is native {}

    multi method new(GPGME::Data:U: IO::Path:D $path, |opts --> GPGME::Data)
    {
        my Pointer $ptr .= new;
        check gpgme_data_new_from_file($ptr, $path.absolute, 1);
        samewith $ptr, |opts
    }

    sub gpgme_data_new_from_fd(Pointer is rw, int32 $fd --> uint32)
        is native {}

    multi method new(GPGME::Data:U: IO::Handle:D $fh, |opts --> GPGME::Data)
    {
        my Pointer $ptr .= new;
        check gpgme_data_new_from_fd($ptr, $fh.native-descriptor);
        samewith $ptr, :$fh, |opts
    }

    multi method new(GPGME::Data:U: Pointer:D $ptr, |opts)
    {
        self.bless: handle => nativecast(GPGME::DataHandle, $ptr), |opts
    }

    multi method writer(GPGME::Data:U: Any:U)
    {
        GPGME::Data.new(Str)
    }

    multi method writer(GPGME::Data:U: Str:D $str)
    {
        samewith $str.IO
    }

    multi method writer(GPGME::Data:U: IO::Path:D $path)
    {
        GPGME::Data.new: $path.open(:rw)
    }

    multi method writer(GPGME::Data:U: IO::Handle:D $fh)
    {
        GPGME::Data.new: $fh
    }

    method Str(GPGME::Data:D: :$encoding = $!encoding --> Str)
    {
        self.encoding($encoding);
        self.slurp
    }

    method identify(GPGME::Data:D: --> GPGME::DataType)
    {
        GPGME::DataType($!handle.identify) but GPGME::EnumStr[16]
    }

    multi method filename(GPGME::Data:D: --> Str) { $!handle.get-filename }

    multi method filename(GPGME::Data:D: Str:D $filename --> GPGME::Data)
    {
        check $!handle.set-filename($filename);
        self
    }

    multi method data-encoding(GPGME::Data:D: --> GPGME::DataEncoding)
    {
        GPGME::DataEncoding($!handle.get-encoding) but GPGME::EnumStr[20]
    }

    multi method data-encoding(GPGME::DataEncoding $encoding --> GPGME::Data)
    {
        check $!handle.set-encoding($encoding);
        self
    }

    multi method data-encoding(Str:D $encoding --> GPGME::Data)
    {
        samewith GPGME::DataEncoding::{"GPGME_DATA_ENCODING_$encoding.uc()"}
    }

    method WRITE(GPGME::Data:D: Blob:D \data --> Bool:D)
    {
        my $buf = data;

        loop
        {
            given $!handle.write($buf, $buf.bytes)
            {
                when -1         { die X::GPGME::Native.new }
                when $buf.bytes { return True }
                default         { $buf = $buf.subbuf($_) }
            }
        }
    }

    method READ(GPGME::Data:D: \bytes --> Buf:D)
    {
        my buf8 $buf .= allocate(bytes);
        given $!handle.read($buf, bytes)
        {
            when -1 { die X::GPGME::Native.new }
            when 0  { $!EOF = True; $buf.reallocate($_) }
            default { $buf.reallocate($_) }
        }
    }

    method rewind(GPGME::Data:D: --> GPGME::Data)
    {
        $!handle.seek(0, GPGME_SEEK_SET);  # Ignore errors on unseekable things
        self
    }

    submethod DESTROY()
    {
        .close with $!fh;
        .release with $!handle;
        $!handle = Nil;
    }
}

=begin pod

=head1 NAME

GPGME::Data -- Abstract type for conveying data to/from GPGME

=head1 SYNOPSIS

  GPGME::Data.new(Str);                  # Empty memory buffer for writing
  GPGME::Data.new(buf8.new(1,2,3,4,5));  # Data to read from
  GPGME::Data.new("some text to read");
  GPGME::Data.new("filename".IO);        # File to read from
  GPGME::Data.new($*IN);                 # Read from STDIN
  GPGME::Data.writer('somefilename');
  GPGME::Data.writer('filename'.IO);
  GPGME::Data.writer($*OUT);             # Write to STDOUT

  put $dataobj;                          # Stringify data from object
  my $blob = $dataobj.slurp;             # Read data from object

=head1 DESCRIPTION

A lot of data has to be exchanged between the user and the crypto
engine, like plaintext messages, ciphertext, signatures and
information about the keys. The technical details about exchanging the
data information are completely abstracted by GPGME. The user provides
and receives the data via C<GPGME::Data> objects, regardless of the
communication protocol between GPGME and the crypto engine in use.

In general the API will construct the appropriate C<GPGME::Data>
object for you.

For input objects, you can provide one of these types:

=item C<Blob> -- Actual data to use
=item C<Str> -- Actual data to use
=item C<IO::Path> -- Filename of file to use
=item C<IO::Handle> -- File with a C<native-descriptor> to read from

For output objects, you can provide one of these types:

=item C<Str> -- Filename of file to write to
=item C<IO::Path> -- Filename to write to
=item C<IO::Handle> -- File with a C<native-descriptor> to write to

When an output object is omitted, a memory buffer will be used and
returned.

When a C<GPGME::Data> object is returned, you can stringify it if and
only if the data are C<utf8> encoded or ascii (usually produced when
the I<:armor> option was specified during context creation).

The object can also be treated as an C<IO::Handle> and read from as
usual.

See L<Exchanging Data|https://gnupg.org/documentation/manuals/gpgme/Exchanging-Data.html> for more information.


=head1 METHODS

=item method B<new>(GPGME::Data:U: Any:U)

Empty memory buffer.

=item method B<new>(GPGME::Data:U: Blob:D)

Actual data to read.

=item method B<new>(GPGME::Data:U: Str:D)

Actual data to read.

=item method B<new>(GPGME::Data:U: IO::Path:D)

Filename of file to read.

=item method B<new>(GPGME::Data:U: IO::Handle:D)

File to read from.  Must have a C<native-descriptor>.

=item method B<writer>(GPGME::Data:U: Any:U)

Empty memory buffer to write to.

=item method B<writer>(GPGME::Data:U: Str:D)

Filename to write to.

=item method B<writer>(GPGME::Data:U: IO::Path:D)

Filename to write to.

=item method B<writer>(GPGME::Data:U: IO::Handle:D)

File to write to. Must have a C<native-descriptor>.

=item method B<identify>(GPGME::Data:D --> GPGME::DataType)

Try to figure out the type of data in the object.

=item multi method B<filename>(GPGME::Data:D --> Str)
=item multi method B<filename>(GPGME::Data:D Str:D $filename --> GPGME::Data)

Set or retrieve the filename associated with the data.

=item multi method B<data-encoding>(GPGME::Data:D: --> GPGME::DataEncoding)
=item multi method B<data-encoding>(GPGME::Data:D: GPGME::DataEncoding $encoding --> GPGME::Data)

Set or retrieve the data encoding.  Valid encodings are:
none, binary, base64, armor, url, urlesc, url0, mime.

=end pod
