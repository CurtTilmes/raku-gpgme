use NativeLibs:ver<0.0.7>:auth<github:salortiz>;

my $Lib;

INIT .fail without $Lib = NativeLibs::Loader.load('libgpgme.so.11');

class X::GPGME is Exception
{
    has uint32 $.code;

    sub gpgme_strerror_r(uint32, Blob, size_t)
        is native {}

    method message(Int:D $length = 80)
    {
        my $buf = buf8.allocate($length);
        gpgme_strerror_r($!code, $buf, $length);
        "Failure: {nativecast(Str, $buf)}"
    }
}

class X::GPGME::BadLocale is X::GPGME
{
    method message() { "Bad Locale" }
}

class X::GPGME::BadSigner is X::GPGME
{
    has Str $.signer is built = '';

    method message() { "Bad Signer: $!signer" }
}

my $errno := cglobal('libc.so.6', 'errno', int32);

class X::GPGME::Native is X::GPGME
{
    has int32 $!errno;

    submethod BUILD() { $!errno = $errno }

    sub strerror(int32 --> Str) is native {}

    method message(--> Str) { strerror($errno) }
}

multi check(0)     is export { 0 }
multi check($code) is export is hidden-from-backtrace {die X::GPGME.new(:$code)}
