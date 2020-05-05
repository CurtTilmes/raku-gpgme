NAME
====

GPGME::Data -- Abstract type for conveying data to/from GPGME

SYNOPSIS
========

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

DESCRIPTION
===========

A lot of data has to be exchanged between the user and the crypto engine, like plaintext messages, ciphertext, signatures and information about the keys. The technical details about exchanging the data information are completely abstracted by GPGME. The user provides and receives the data via `GPGME::Data` objects, regardless of the communication protocol between GPGME and the crypto engine in use.

In general the API will construct the appropriate `GPGME::Data` object for you.

For input objects, you can provide one of these types:

  * `Blob` -- Actual data to use

  * `Str` -- Actual data to use

  * `IO::Path` -- Filename of file to use

  * `IO::Handle` -- File with a `native-descriptor` to read from

For output objects, you can provide one of these types:

  * `Str` -- Filename of file to write to

  * `IO::Path` -- Filename to write to

  * `IO::Handle` -- File with a `native-descriptor` to write to

When an output object is omitted, a memory buffer will be used and returned.

When a `GPGME::Data` object is returned, you can stringify it if and only if the data are `utf8` encoded or ascii (usually produced when the *:armor* option was specified during context creation).

The object can also be treated as an `IO::Handle` and read from as usual.

See [Exchanging Data](https://gnupg.org/documentation/manuals/gpgme/Exchanging-Data.html) for more information.

METHODS
=======

  * method **new**(GPGME::Data:U: Any:U)

Empty memory buffer.

  * method **new**(GPGME::Data:U: Blob:D)

Actual data to read.

  * method **new**(GPGME::Data:U: Str:D)

Actual data to read.

  * method **new**(GPGME::Data:U: IO::Path:D)

Filename of file to read.

  * method **new**(GPGME::Data:U: IO::Handle:D)

File to read from. Must have a `native-descriptor`.

  * method **writer**(GPGME::Data:U: Any:U)

Empty memory buffer to write to.

  * method **writer**(GPGME::Data:U: Str:D)

Filename to write to.

  * method **writer**(GPGME::Data:U: IO::Path:D)

Filename to write to.

  * method **writer**(GPGME::Data:U: IO::Handle:D)

File to write to. Must have a `native-descriptor`.

  * method **identify**(GPGME::Data:D --> GPGME::DataType)

Try to figure out the type of data in the object.

  * multi method **filename**(GPGME::Data:D --> Str)

  * multi method **filename**(GPGME::Data:D Str:D $filename --> GPGME::Data)

Set or retrieve the filename associated with the data.

  * multi method **data-encoding**(GPGME::Data:D: --> GPGME::DataEncoding)

  * multi method **data-encoding**(GPGME::Data:D: GPGME::DataEncoding $encoding --> GPGME::Data)

Set or retrieve the data encoding. Valid encodings are: none, binary, base64, armor, url, urlesc, url0, mime.

