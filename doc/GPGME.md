NAME
====

GPGME -- Raku bindings for Gnu Privacy Guard (GPG) Made Easy

SYNOPSIS
========

    put GPGME.version;
    put GPGME.dirinfo('gpg-name');
    GPGME.set-locale('C');

    my $gpg = GPGME.new;

    $gpg.create-key('joe@foo.bar');

    my $result = $gpg.result;            # Retrieve result from last operation.

DESCRIPTION
===========

METHODS
=======

  * method **version**(--> Str:D)

  * **dirinfo**(Str $what--> Str)

  * multi method **engine-check-version**(Str:D $protocol --> Bool:D)

  * multi method **engine-check-version**(GPGME::Protocol:D $protocol --> Bool:D)

Check to see if an engine is valid, the executable exists and has a late enough version to function with GPGME.

  * method **set-locale**(Str:D $locale = "" --> Nil)

Set the locale, either a default, or for a specific context.

  * method **engine-info**($protocol?, Str :$filename, Str :$homedir--> GPGME::EngineInfo)

Can be called either for global defaults, or a specific context, either retrieve the engine information, or set *filename* or *homedir* for an engine.

e.g.

    put GPGME.engine-info;
    put GPGME.engine-info('openpgp');
    put GPGME.engine-info('openpgp').version;
    GPGME.engine-info('opengpg', :homedir</tmp/home>);

See `GPGME::EngineInfo` for more information.

  * method **new**(:$protocol, Str :$filename, Str :$homedir, Bool :$armor, Bool :$textmode, Bool :$offline, :$signers, :$passphrase, :&status-callback, :&progress-callback, :$pin-entry-mode, :$keylist-mode)

Creates a new `GPGME` Context, and optionally applies various settings to the context. See other methods to see various settings.

  * method **result**(GPGME:D:)

Retrieve the result object from the last operation.

  * method **genkey-result**(GPGME:D: --> GPGME::GenKeyResult)

  * method **import-result**(GPGME:D: --> GPGME::ImportResult)

  * method **sign-result**(GPGME:D: --> GPGME::SignResult)

  * method **encrypt-result**(GPGME:D: --> GPGME::EncryptResult)

  * method **decrypt-result**(GPGME:D: --> GPGME::DecryptResult)

  * method **verify-result**(GPGME:D: --> GPGME::VerifyResult)

Each of the `*-result` methods retrieve a specific type of result. These are only valid immediately following the appropriate operation, and all results must be used or copied prior to the next operation, when the results are no longer available.

  * method **log**(GPGME:D: :$log, Bool :$html --> GPGME::Data)

*log* can be anything `GPGME::Data` can write to: a filename, an `IO::Path` or an `IO::Handle`. By default, it just writes to a memory buffer and returns it.

    $gpg.log('logfile');
    $gpg.log($*ERR);
    put $gpg.log;

See [Additional Logs](https://gnupg.org/documentation/manuals/gpgme/Additional-Logs.html) for more information.

  * multi method **protocol**(GPGME:D: --> Str:D)

  * multi method **protocol**(GPGME:D: Str:D $protocol --> GPGME:D)

  * multi method **protocol**(GPGME:D: GPGME::Protocol:D $protocol --> GPGME:D)

Set or retrieve the protocol.

  * multi method **sender**(GPGME:D: --> Str)

  * multi method **sender**(GPGME:D: Str $address --> GPGME:D)

Set or retrieve the sender's address.

Some engines can make use of the sender’s address, for example to figure out the best user id in certain trust models. For verification and signing of mails, it is thus suggested to let the engine know the sender ("From:") address.

*address* is expected to be the “addr-spec” part of an address but my also be a complete mailbox address, in which case this function extracts the “addr-spec” from it. Using `Str` for address clears the sender address.

  * multi method **armor**(GPGME:D: Bool:D $armor --> GPGME:D)

  * multi method **armor**(GPGME:D: --> Bool:D)

Set or retrieve the ASCII armor setting.

  * multi method **textmode**(GPGME:D: Bool:D $textmode --> GPGME:D)

  * multi method **textmode**(GPGME:D: --> Bool:D)

Set or retrieve the setting for canonical text mode.

  * multi method **offline**(GPGME:D: Bool:D $offline --> GPGME:D)

  * multi method **offline**(GPGME:D: --> Bool:D)

Set or retrieve the setting for offline mode. The details of the offline mode depend on the used protocol and its backend engine. It may eventually be extended to be more stricter and for example completely disable the use of Dirmngr for any engine.

  * multi method **pin-entry-mode**(GPGME:D: Str:D $mode --> GPGME:D)

  * multi method **pin-entry-mode**(GPGME:D: GPGME::PinentryMode:D $mode --> GPGME:D)

  * multi method **pin-entry-mode**(GPGME:D: --> GPGME::PinentryMode:D)

Set or retrieve the setting for the pin entry mode.

Possible values are default, ask, cancel, error, or loopback.

  * multi method **keylist-mode**(GPGME:D: *@modes, Bool :$clear--> GPGME:D)

  * multi method **keylist-mode**(GPGME:D: --> BitEnum)

Set or retrieve settings for the key listing behaviour.

This can be set to multiple values, and returns a `BitEnum` object that stringifies to a summary of the settings, or can check for specific settings.

    gpg.keylist-mode('secret');
    put $gpg.keylist-mode;
    put 'secret is set' if $gpg.keylist-mode.isset('with_secret');
    my $mode = $gpg.keylist-mode;
    $mode.clear('with_secret');
    $gpg.keylist-mode($mode);

Possible values are local, extern, sigs, sig_notations, with_secret, with_tofu, ephemeral, validate.

See [Key Listing Mode](https://gnupg.org/documentation/manuals/gpgme/Key-Listing-Mode.html) for more information.

  * multi method **passphrase**(GPGME:D: Str:D $passphrase)

  * multi method **passphrase**(GPGME:D: &sub --> GPGME:D)

Configures either a static string *passphrase* or a callback routine called with three named parameters, `(Str :$uid-hint, Str :$passphrase-info, Str :$prev-was-bad)`.

It should return a `Str` with the passphrase, or type object to cancel the operation.

If not set, the user may be asked for a passphrase.

  * method **status-callback**(GPGME:D: &sub:(Str, Str) --> GPGME:D)

Configure a status message callback routine. It will be called with the signature `(Str $keyword, Str $args)`

  * method **progress-callback**(GPGME:D: &sub:(Str,Int,Int,Int) --> GPGME:D)

Configure a progress callback routine. It will be called with the signature `(Str $what, Int $type, Int $current, Int $total)`.

  * method **create-key**(GPGME:D: Str:D $userid, Str:D :$algorithm = 'default', :$expires = 0, Bool :$sign, Bool :$encr, Bool :$cert, Bool :$auth, Bool :$nopasswd, Bool :$force, Bool :$noexpire)

Creates a pubic key pair.

*$expires* can be `Int` seconds, or a `Duration`.

See [Generating Keys](https://gnupg.org/documentation/manuals/gpgme/Generating-Keys.html) for more information.

  * method **create-subkey**(GPGME:D: GPGME::Key:D $key, Str:D :$algorithm = 'default', :$expires = 0, Bool :$sign, Bool :$encr, Bool :$cert, Bool :$auth, Bool :$nopasswd, Bool :$force, Bool :$noexpire --> GPGME::GenKeyResult)

Adds a new subkey to a primary OpenPGP key.

  * method **adduid**(GPGME:D: GPGME::Key:D $key, Str:D $userid --> Nil)

Add a new user ID to an OpenPGP key.

  * method **revuid**(GPGME:D: GPGME::Key:D $key, Str:D $userid --> Nil)

Revoke a user ID from an OpenPGP key.

  * method **set-uid-flag**(GPGME:D: GPGME::Key:D $key, Str:D $userid, Str:D $name = 'primary', Str $value? --> Nil)

Sets flags on a user ID from an OpenPGP Key.

a *name* of 'primary' (the default) sets the primary key flag on the given user ID, clearing the flag on other user IDs.

  * multi method **genkey**(GPGME:D: Str:D $parms --> GPGME::GenKeyResult)

  * multi method **genkey**(GPGME:D: Str:D :$Key-Type = 'default', *%opts)

An alternate method of generating a key pair.

You can eitehr specifiy a single string argument with a set of parameters, or a selection of named parameters.

Some examples:

    $gpg.genkey(q:to/END/)
    Key-Type: default
    Subkey-Type: default
    Name-Real: Joe Tester
    Name-Comment: with stupid passphrase
    Name-Email: joe@foo.bar
    Expire-Date: 0
    Passphrase: abc
    END

    $gpg.genkey(q:to/END/)
    Key-Type: RSA
    Key-Length: 1024
    Name-DN: C=de,O=g10 code,OU=Testlab,CN=Joe 2 Tester
    Name-Email: joe@foo.bar
    END

    $gpg.genkey(:Subkey-Type<default>, :Name-Email<joe@foo.bar>, :Passphrase<abc);

See [GPG Key Generation](https://gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html) and [CSR and Certificate Creation](https://www.gnupg.org/documentation/manuals/gnupg/CSR-and-certificate-creation.html) for more details on the parameters.

  * method **get-key**(GPGME:D: Str:D $fpr, Bool :$secret --> GPGME::Key)

Look up and retrieve a key by fingerprint or key ID.

Set *:secret* to retrieve the secret key. The currently active keylist mode is used to retrieve the key.

  * method **keylist**(GPGME:D: *@pattern, Bool :$secret --> Seq)

Lists keys matching any of the specified patterns (or all keys if no patterns).

Until the `Seq` is fully retrieved, the context will be busy and should not be used for other actions. Either retrieve the whole list first, or use another context.

  * multi method **signers**(GPGME:D: *@keys, Bool :$clear --> GPGME:D)

  * multi method **signers**(GPGME:D: --> List)

Set or retrieve a list of key signers to be used for signing actions.

Use `:clear` to clear the list.

  * method **notation**(GPGME:D: Bool :$clear, *%notations)

Set or retrieve signature notations.

  * method **keysign**(GPGME:D: GPGME::Key:D $key, *@userid, :$expires = 0, Bool :$local, Bool :$noexpire --> GPGME:D)

Specifying no user IDs will sign with all valid user IDs.

*expires* can be an posix time int or a `DateTime`

See [Signing Keys](https://gnupg.org/documentation/manuals/gpgme/Signing-Keys.html) for more information.

  * method **export**(GPGME:D: *@patterns, :$out = GPGME::Data.new(Str); Bool :$extern, Bool :$minimal, Bool :$secret, Bool :$raw, Bool :$pkcs12 --> GPGME::Data)

`$out` can be anything a `GPGME::Data` can write to -- a `Str` with a filename, an `IO::Path` of a file to write to, a `IO::Handle`. The `GPGME::Data` object is returned regardless.

See [Exporting Keys](https://gnupg.org/documentation/manuals/gpgme/Exporting-Keys.html) for more information.

Some examples:

    put $gpg.export('joe@foo.bar');                # Stringify and print out
    $gpg.export('joe@foo.bar', :out<outputfile>);  # Export to filename
    $gpg.export('joe@foo.bar', out => $*OUT);      # Send to a file handle

  * method **import**(GPGME:D: $keydata --> GPGME::ImportResult)

*$keydata* can be anything that can be used for a <GPGME::Data> object: a `Str`, an `IO::Path` of a file with the keys, or a `IO::Handle` of a file with the data.

See [Importing Keys](https://gnupg.org/documentation/manuals/gpgme/Importing-Keys.html) for more information

Returns a `GPGME::ImportResult`

  * multi method **delete-key**(GPGME:D: Str:D $fpr, |opts)

  * multi method **delete-key**(GPGME:D: GPGME::Key:D $key, Bool :$secret, Bool :$force --> Nil)

Deletes a key.

See [Deleting Keys](https://gnupg.org/documentation/manuals/gpgme/Deleting-Keys.html) for more information

  * method **sign**(GPGME:D: $plain, $sig?, Bool :$detach, Bool :$clear)

Creates a signature for the text in the data object *$plain*.

*$plain* can be anything that can be used for a <GPGME::Data> object: a `Buf` or `Str` with the actual data, an `IO::Path` of a file with the plaintext, or a `IO::Handle` of a file with the data.

Similarly, if specified, *$sig* can also be a <GPGME::Data> writable object: a `Str` filename, an `IO::Path` filename, or a `IO::Handle` to write the signature to.

The signed data is returned in a <GPGME::Data> object.

Some examples:

    my $sig = $gpg.sign('some plain text');
    put $sig;                                     # Stringify

    $gpg.sign('inputfile'.IO, 'outputfile'.IO);   # Use filenames
    $gpg.sign($*IN, $*OUT);                       # Sign STDIN, write to STDOUT

A `GPGME::SignResult` is stored in the context and can be queried.

  * method **verify**(GPGME:D: $sig, $signed?, $plain?)

Verify a signature in a `GPGME::Data` object. Can optionally specify `GPGME::Data` objects in *$signed* and $<plain> as well.

If the signature is detached, specify the *$signed* data.

*$sig* and *$signed* can be anything that a <GPGME::Data> object can read from: A `Buf` or `Str` with the data, or a `IO::Path` or `IO::Handle` with the data.

*$plain* will get the returned plain text from the signature. It can be a <Str> or an <IO::Path> with a filename, or an <IO::Handle>. By default, a memory buffer is used and returned in a `GPGME::Data` object which can be stringified or read from.

A `GPGME::VerifyReuslt` is stored in the context and can be queried.

See [Verify](https://gnupg.org/documentation/manuals/gpgme/Verify.html) for more information.

  * method **encrypt**(GPGME:D: $plain, *@keys, :$out, Bool :$always-trust, Bool :$no-encrypt-to, Bool :$prepare, Bool :$expect-sign, Bool :$no-compress, Bool :$symmetric, Bool :$throw-keyids, Bool :$wrap --> GPGME::Data)

*$plain* can be anything that a <GPGME::Data> object can read from: A `Buf` or `Str` with the data, or a `IO::Path` or `IO::Handle` with the data.

*$out* can be a <Str> or an <IO::Path> with a filename, or an <IO::Handle>. By default, a memory buffer is used and returned in a `GPGME::Data` object which can be stringified or read from.

A `GPGME::EncryptResult` is stored in the context and can be queried.

See [Encrypt](https://gnupg.org/documentation/manuals/gpgme/Encrypting-a-Plaintext.html) for more information.

  * method **decrypt**(GPGME:D: $cipher, :$out, Bool :$verify, Bool :$unwrap, --> GPGME::Data)

*$cipher* can be anything that a <GPGME::Data> object can read from: A `Buf` or `Str` with the data, or a `IO::Path` or `IO::Handle` with the data.

*$out* can be a <Str> or an <IO::Path> with a filename, or an <IO::Handle>. By default, a memory buffer is used and returned in a `GPGME::Data` object which can be stringified or read from.

A `GPGME::DecryptResult` is stored in the context and can be queried.

See [Decrypt](https://gnupg.org/documentation/manuals/gpgme/Decrypt.html) for more information.

