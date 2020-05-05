# Raku GPGME - GNU Privacy Guard (GPG) Made Easy

## Introduction

From the [GPGME Manual](https://gnupg.org/documentation/manuals/gpgme/index.html):

    ‘GnuPG Made Easy’ (GPGME) is a C language library that allows to
    add support for cryptography to a program. It is designed to make
    access to public key crypto engines like GnuPG or GpgSM easier for
    applications. GPGME provides a high-level crypto API for
    encryption, decryption, signing, signature verification and key
    management.

    GPGME uses GnuPG and GpgSM as its backends to support OpenPGP and
    the Cryptographic Message Syntax (CMS).

So essentially, this is a Raku Module interfacing with a C library
interfacing with GnuPG and GpgSM command line programs.

Understanding how this module works will benefit from an understanding
of the [Gnu Privacy Guard](https://gnupg.org/documentation/manuals/gnupg/)
and [GnuPG Made Easy (GPGME)](https://gnupg.org/documentation/manuals/gpgme/).

**Note, this is still a work in progress, more features may or may not
  be forthcoming!!  Patches welcome!!**

# Basic Usage

```
use GPGME;
my $gpg = GPGME.new(:armor);                     # ASCII armor for key export
$gpg.create-key('joe@foo.bar');                  # Add key to key ring
my $joes-key = $gpg.get-key('joe@foo.bar');      # Retrieve a key
put $joes-key;                                   # Stringify key summary
put my $key = $gpg.export('joe@foo.bar');        # Export from key ring
$gpg.import($key);                               # Import key

my $cipher = $gpg.encrypt('message', 'joe@foo.bar');

my $plain = $gpg.decrypt($cipher);

$gpg.signers('joe@foo.bar');
my $signed = $gpg.sign('My message');

```

# Functionality

## Basic

```
use GPGME;
put GPGME.version;
put GPGME.dirinfo('gpg-name');
GPGME.set-locale('C');
```

## GPGME Object and Context

The main [GPGME](doc/GPGME.md) object holds a `context` with various
settings, and can be used to perform various functions.

```
use GPGME;
my $gpg = GPGME.new;
my $gpg = GPGME.new(:armor, :homedir</tmp/dir>);
```

See [GPGME](doc/GPGME.md) for more information.

## Results

After performing an operation, the result of the operation can be
retrieved from the context with the C<result> method.  As a
convenience, most methods from the result objects are passed through
to the result object.

For example, after a key generation operation, the
C<GPGME::GenKeyResult> object can be retrieved with the C<result>
method.  One of the attributes of that object is the fingerprint of
the generated key, which can be retrieved with its C<fpr> method.

```
$gpg.create-key('joe@foo.bar');
my $result = $gpg.result;
my $fpr = $result.fpr;
```

This does the same thing, passing the I<fpr> from the context to the
result:

```
my $fpr = $gpg.fpr;
```

Of course, for key generation, the result object is returned from
the I<create-key> operation, so you can also just do:

```
my $fpr = $gpg.create-key('joe@foo.bar').fpr;
```

You can additionally retrieve the result object immediately following
the appropriate operation with these methods:

```
$gpg.genkey-result
$gpg.import-result
$gpg.sign-result
$gpg.encrypt-result
$gpg.decrypt-result
$gpg.verify-result
```

These are sometimes needed when an operation performs two actions
(e.g. decrypt and verify).

These are only valid immediately following the appropriate operation,
and all results must be used or copied prior to the next operation,
when the results are no longer available.

## Engine Information

```
.put for GPGME.engine-info;
GPGME.engine-info('openpgp', :homedir</tmp/dir>);
```

See [GPGME::EngineInfo](doc/GPGME/EngineInfo.md) for more information.

## Data Objects

A lot of data has to be exchanged between the user and the crypto
engine, like plaintext messages, ciphertext, signatures and
information about the keys. The technical details about exchanging the
data information are completely abstracted by GPGME. The user provides
and receives the data via `GPGME::Data` objects, regardless of the
communication protocol between GPGME and the crypto engine in use.

In general the API will construct the appropriate `GPGME::Data`
object for you.

For input objects, you can provide one of these types:

* `Blob` -- Actual data to use
* `Str` -- Actual data to use
* `IO::Path` -- Filename of file to use
* `IO::Handle` -- File with a `native-descriptor` to read from

For output objects, you can provide one of these types:

* `Str` -- Filename of file to write to
* `IO::Path` -- Filename to write to
* `IO::Handle` -- File with a C<native-descriptor> to write to

When an output object is omitted, a memory buffer will be used and
returned.

When a `GPGME::Data` object is returned, you can stringify it if and
only if the data are `utf8` encoded or ascii (usually produced when
the *:armor* option was specified during context creation).

The object can also be treated as an `IO::Handle` and read from as
usual.

## Key Management

An important fact to remember is that in addition to providing
mechanisms to manipulate keys, GPG also serves as a Key Store or 'Key
Ring'.  Keys can generally be referred to by patterns and fingerprints
that map to actual keys stored in the key store.

## Key Generation

GPGME Supports two different interfaces to Key Generation --
`create-key` and `genkey`.

```
$gpg.create-key('joe@foo.bar');
my $key = $gpg.get-key('joe@foo.bar');
$gpg.create-subkey($key);
$gpg.adduid($key, 'another@email.address');
$gpg.set-uid-flag($key, 'another@email.address');  # Make new one primary
$gpg.revuid($key, 'joe@foo.bar');                  # Revoke a user ID
```

`genkey` takes a set of parameters, expressed either as a single
string, or a set of named parameters:

```
$gpg.genkey(q:to/END/)
Key-Type: default
Name-Email: joe@foo.bar
END
```

or

```
$gpg.genkey(:Name-Email<joe@foo.bar>);  # Key-Type defaults to 'default'
```

See [GPG Key Generation](https://gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html) and [CSR and Certificate Creation](https://www.gnupg.org/documentation/manuals/gnupg/CSR-and-certificate-creation.html) for information on all the parameters.

## Listing Keys

List keys in the key ring by specifying a list of patterns and
optionally specifying the *:secret* option to retrieve secret keys.

```
$key = $gpg.get-key('me@my.key');
$key = $gpg.get-key($fpr, :secret);
.put for $gpg.keylist('me@my.key', :secret);
.put for $gpg.keylist(<alice harry bob>);
```

Individual attributes from the keys can be queried.
See [GPGME::Key](doc/GPGME/Key.md) for more information.

## Deleting Keys

```
$gpg.delete-key($key, :secret, :force);
```

- *:secret* deletes secret keys
- *:force* overrides a user confirmation, but is only available after
version 1.8.

## Signing Keys

Key signatures are a unique concept of the OpenPGP protocol. They can
be used to certify the validity of a key and are used to create the
Web-of-Trust (WoT).

```
$gpg.signers('alice@foo.bar');                     # select signers
$gpg.keysign($key);                                # Default sign all user IDs
$gpg.keysign($key, 'joe@foo.bar');                 # Specify a user ID
$gpg.keysign($key, :local);                        # Non exportable
$gpg.keysign($key, 'joe@foo.bar', expires => $DateTime);
```

## Exporting Keys

```
my $gpg = GPGME.new(:armor);                   # Use :armor to get ASCII export
put $gpg.export('joe@foo.bar');                # Stringify and print out
$gpg.export('joe@foo.bar', :out<outputfile>);  # Export to filename
$gpg.export('joe@foo.bar', out => $*OUT);      # Send to a file handle
```

## Importing Keys

```
$gpg.import($someexportedkeydata);
```

Stores the [ImportResult](doc/GPGME/ImportResult.md).

## Encrypting a Plaintext

```
$cipher = $gpg.encrypt("my message", $key);             # Encrypt for a key
$cipher = $gpg.encrypt("my message", 'joe@foo.bar');     # Encrypt for a pattern
$cipher = $gpg.encrypt("my message", 'joe@foo.bar', :sign);  # Encrypt and sign
```

Stores the [EncryptResult](doc/GPGME/EncryptResult.md).

If signed as well with the *:sign* option,
[SignResult](doc/GPGME/SignResult.md) can be examined as well.

## Decrypting

```
$plain = $gpg.decrypt($cipher);
$gpg.decrypt($cipher, out => 'filename');
$gpg.decrypt($cipher, out => $*OUT);
$gpg.decrypt($cipher, :verify);
```

Stores the [DecryptResult](doc/GPGME/DecryptResult.md).

If the signature was verified with the *:verify* option, the
[VerifyResult](doc/GPGME/VerifyResult.md) is also available.

## Signing

A signature can contain signatures by one or more keys. The set of
keys used to create a signatures is contained in a context, and is
applied to all following signing operations in this context (until the
set is changed).

They can be set either at `GPGME` creation with the *:signers* object,
or with the `.signers` method later.

```
$gpg.signers('joe@foo.bar');
my $signed = $gpg.sign('My message');
$gpg.sign($*IN, out => $*OUT);

my $signature = $gpg.sign('My message', :detach); # Detached signature
```

The [SignResult](doc/GPGME/SignResult.md) will be available after signing.

## Verifying Signature

```
$message = $gpg.verify($signed);
$gpg.verify('infile'.IO, :out<somefile>);

put $gpg.verify($signature, $message).status;      # Detached signature
```

The [VerifyResult](doc/GPGME/VerifyResult.md) will be available after
verification.

# Entropy

Some `GPGME` actions (particularly key generation with very long keys)
rely on the OS ability to generate a great deal of entropy.  Things
may appear to hang on entropy starved hosts.  Tools like
[haveged](https://www.issihosts.com/haveged/) can help the OS capture
entropy.  Even doing something simple like running `sudo dd
if=/dev/sda of=/dev/zero` in the background can help speed things up.

# INSTALL

You must install `libgpgme` which usually has the right dependencies
on GPG as well.

* For debian or ubuntu: `apt install libgpgme11`
* For alpine: `apk add gpgme`
* For CentOS: `yum install gpgme`

If you get locale errors on CentOS, you may need to run this:
```
yum install glibc-locale-source glibc-langpack-en
localedef -i en_US -f UTF-8 en_US.UTF-8
```

# License

This work is subject to the Artistic License 2.0.

See [LICENSE](LICENSE) for more information.
