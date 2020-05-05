use NativeCall;
use NativeHelpers::Callback :cb;
use BitEnum;

use GPGME::Constants;
use GPGME::Context;
use GPGME::Data;
use GPGME::Check;
use GPGME::EngineInfo;

sub gpgme_check_version(Str --> Str)
    is native {}

INIT
{
    gpgme_check_version(Str) // die X::GPGME.new(code => GPG_ERR_GENERAL);
    GPGME.set-locale;
}

sub protocol-lookup(Str:D $str --> GPGME::Protocol:D)
{
   GPGME::Protocol::{"GPGME_PROTOCOL_$str.uc()"}
       // die X::GPGME.new(code => GPG_ERR_INV_ENGINE)
}

class GPGME
{
    has GPGME::Context $.context handles <genkey-result import-result
        sign-result encrypt-result decrypt-result verify-result>;
    has $.result handles **;
    has &.passphrase-sub;
    has &.status-sub;
    has &.progress-sub;

    method version(--> Str:D) { gpgme_check_version(Str) }

    method errcode(Int:D $code --> Int:D) { $code +& GPG_ERR_CODE_MASK }

    sub gpgme_set_global_flag(Str, Str --> int32)
        is native {}

    method set-global-flag(Str:D $name, Str $value)
    {
        gpgme_set_global_flag($name, $value)
    }

    sub gpgme_get_dirinfo(Str --> Str)
        is native {}

    method dirinfo(Str $what--> Str) { gpgme_get_dirinfo($what) }

    sub gpgme_engine_check_version(int32 --> uint32)
        is native {}

    multi method engine-check-version(Str:D $protocol --> Bool:D)
    {
        samewith protocol-lookup($protocol)
    }

    multi method engine-check-version(GPGME::Protocol:D $protocol --> Bool:D)
    {
        0 == check gpgme_engine_check_version($protocol)
    }

    sub setlocale(int32, Str --> Str) is native {}

    sub gpgme_set_locale(GPGME::Context, int32, Str --> uint32)
        is native {}

    method set-locale($self: Str:D $locale = "" --> Nil)
    {
        setlocale(LC_ALL, $locale) // die X::GPGME::BadLocale.new;

        check gpgme_set_locale($self ?? $!context !! GPGME::Context,
                               LC_CTYPE, setlocale(LC_CTYPE, Str));

        check gpgme_set_locale($self ?? $!context !! GPGME::Context,
                               LC_MESSAGES, setlocale(LC_MESSAGES, Str));
    }

    multi method engine-info(GPGME:U: Str:D $protocol, |opts)
    {
        samewith protocol-lookup($protocol), |opts
    }

    sub gpgme_get_engine_info(Pointer $ptr is rw --> uint32)
        is native {}

    sub gpgme_set_engine_info(int32, Str, Str --> uint32)
        is native {}

    multi method engine-info(GPGME:U: GPGME::Protocol:D $protocol,
                             Str :$filename, Str :$homedir)
    {
        check gpgme_set_engine_info($protocol, $filename, $homedir);
    }

    multi method engine-info(GPGME:U: --> GPGME::EngineInfo)
    {
        my Pointer $ptr .= new;
        check gpgme_get_engine_info($ptr);
        nativecast(GPGME::EngineInfo, $ptr)
    }

    submethod BUILD(:$protocol,
                    Str :$filename,
                    Str :$homedir,
                    Bool :$armor,
                    Bool :$textmode,
                    Bool :$offline,
                    :$signers,
                    :$passphrase,
                    :&status-callback,
                    :&progress-callback,
                    :$pin-entry-mode = 'DEFAULT',
                    :$keylist-mode)
    {
        $!context = GPGME::Context.new;

        self.protocol($protocol) with $protocol;
        self.engine-info(:$filename, :$homedir) if $filename or $homedir;
        self.armor($armor) with $armor;
        self.textmode($textmode) with $textmode;
        self.offline($offline) with $offline;
        self.keylist-mode(@$keylist-mode, :clear) if $keylist-mode;
        self.signers(@$signers) if $signers;
        self.pin-entry-mode($pin-entry-mode) if $pin-entry-mode;
        self.passphrase($_) with $passphrase;
        self.status-callback($_) with &status-callback;
        self.progress-callback($_) with &progress-callback;
    }

    method log(GPGME:D: :$log is copy, Bool :$html --> GPGME::Data)
    {
        $log = GPGME::Data.writer($log) unless $log ~~ GPGME::Data;

        my int32 $flags = $html ?? GPGME_AUDITLOG_HTML
                                !! GPGME_AUDITLOG_DEFAULT;

        my $code = $!context.getauditlog($log, $flags);

        return $log if $code == GPG_ERR_NO_ERROR || $code == GPG_ERR_NO_DATA;

        check $code;
        $log.rewind;
    }

    sub gpgme_get_protocol_name(int32 --> Str)
        is native {}

    multi method protocol(GPGME:D: --> Str:D)
    {
        gpgme_get_protocol_name($!context.get-protocol())
    }

    multi method protocol(GPGME:D: Str:D $protocol --> GPGME:D)
    {
        samewith protocol-lookup($protocol)
    }

    multi method protocol(GPGME:D: GPGME::Protocol:D $protocol --> GPGME:D)
    {
        check $!context.set-protocol($protocol);
        self
    }

    multi method engine-info(GPGME:D: Str:D $protocol, |opts
                             --> GPGME::EngineInfo)
    {
        samewith protocol-lookup($protocol), |opts
    }

    multi method engine-info(GPGME:D: GPGME::Protocol:D $protocol
                             = GPGME::Protocol($!context.get-protocol),
                             Str :$filename, Str :$homedir --> GPGME::EngineInfo)
    {
        if $filename or $homedir
        {
            check $!context.set-engine-info($protocol, $filename, $homedir)
        }
        $!context.get-engine-info
    }

    multi method sender(GPGME:D: Str $address --> GPGME:D)
    {
        check $!context.set-sender($address);
        self
    }

    multi method sender(GPGME:D: --> Str) { $!context.get-sender }

    multi method armor(GPGME:D: Bool:D $armor --> GPGME:D)
    {
        $!context.set-armor($armor ?? 1 !! 0);
        self
    }

    multi method armor(GPGME:D: --> Bool:D) { $!context.get-armor == 1 }

    multi method textmode(GPGME:D: Bool:D $textmode --> GPGME:D)
    {
        $!context.set-textmode($textmode ?? 1 !! 0);
        self
    }

    multi method textmode(GPGME:D: --> Bool:D) { $!context.get-textmode == 1 }

    multi method offline(GPGME:D: Bool:D $offline --> GPGME:D)
    {
        $!context.set-offline($offline ?? 1 !! 0);
        self
    }

    multi method offline(GPGME:D: --> Bool:D) { $!context.get-offline == 1 }

    multi method pin-entry-mode(GPGME:D: Str:D $mode --> GPGME:D)
    {
        samewith GPGME::PinentryMode::{"GPGME_PINENTRY_MODE_$mode.uc()"}
    }

    multi method pin-entry-mode(GPGME:D: GPGME::PinentryMode:D $mode --> GPGME:D)
    {
        check $!context.set-pinentry-mode($mode);
        self
    }

    multi method pin-entry-mode(GPGME:D: --> GPGME::PinentryMode:D)
    {
        GPGME::PinentryMode($!context.get-pinentry-mode())
            but GPGME::EnumStr[20]
    }

    multi method keylist-mode(GPGME:D: Int(BitEnum) $mode --> GPGME:D)
    {
        check $!context.set-keylist-mode($mode);
        self
    }

    multi method keylist-mode(GPGME:D: *@modes, Bool :$clear --> GPGME:D)
    {
        my $keylist-mode = $.keylist-mode;
        $keylist-mode.value = 0 if $clear;
        $keylist-mode.set(@modes);

        samewith $keylist-mode
    }

    multi method keylist-mode(GPGME:D: --> BitEnum)
    {
        BitEnum[GPGME::KeylistMode, :prefix<GPGME_KEYLIST_MODE_>, :lc]
            .new($!context.get-keylist-mode)
    }

    sub gpgme_io_writen(int32, Blob, size_t --> int32)
        is native {}

    sub passphrase-proxy(int64 $id, Str $uid-hint, Str $passphrase-info,
                      int32 $prev-was-bad, int32 $fd --> uint32)
    {
        my &sub = cb.lookup($id).passphrase-sub;

        my $passphrase = &sub(:$uid-hint, :$passphrase-info,
                              prev-was-bad => $prev-was-bad == 1);

        my $buf = "$passphrase\n".encode;

        gpgme_io_writen($fd, $buf, $buf.bytes) < 0
            ?? GPG_ERR_GENERAL
            !! 0
    }

    multi method passphrase(GPGME:D: Str:D $passphrase)
    {
        samewith sub (|) { $passphrase }
    }

    multi method passphrase(GPGME:D: &sub --> GPGME:D)
    {
        &!passphrase-sub = &sub;
        cb.store(self, $!context);
        $!context.set-passphrase-callback(&passphrase-proxy, cb.id($!context));
        $!context.set-pinentry-mode(GPGME_PINENTRY_MODE_LOOPBACK);
        self
    }

    sub status-proxy(int64 $id, Str $keyword, Str $args)
    {
        my &sub = cb.lookup($id).status-sub;
        sub($keyword, $args);
        return 0
    }

    method status-callback(GPGME:D: &sub:(Str, Str) --> GPGME:D)
    {
        &!status-sub = &sub;
        cb.store(self, $!context);
        $!context.set-status-callback(&status-proxy, cb.id($!context));
        self
    }

    sub progress-proxy(int64 $id, Str $what, int32 $type, int32 $current,
                       int32 $total)
    {
        my &sub = cb.lookup($id).progress-sub;
        sub($what, $type, $current, $total)
    }

    method progress-callback(GPGME:D: &sub:(Str,Int,Int,Int) --> GPGME:D)
    {
        &!progress-sub = &sub;
        cb.store(self, $!context);
        $!context.set-progress-callback(&progress-proxy, cb.id($!context));
        self
    }

    method create-key(GPGME:D: Str:D $userid, Str:D :$algorithm = 'default',
                      :$expires = 0,
                      Bool :$sign, Bool :$encr, Bool :$cert, Bool :$auth,
                      Bool :$nopasswd, Bool :$force, Bool :$noexpire
                      --> GPGME::GenKeyResult)
    {
        my $flags = BitEnum[GPGME::CreateFlags].new;
        $flags.set(GPGME_CREATE_SIGN)     if $sign;
        $flags.set(GPGME_CREATE_ENCR)     if $encr;
        $flags.set(GPGME_CREATE_CERT)     if $cert;
        $flags.set(GPGME_CREATE_AUTH)     if $auth;
        $flags.set(GPGME_CREATE_NOPASSWD) if $nopasswd;
        $flags.set(GPGME_CREATE_FORCE)    if $force;
        $flags.set(GPGME_CREATE_NOEXPIRE) if $noexpire;

        check $!context.create-key($userid, $algorithm, 0,
                                   $expires.Int, GPGME::Key, +$flags);

        $!result = $!context.genkey-result;
    }

    method create-subkey(GPGME:D: GPGME::Key:D $key,
                         Str:D :$algorithm = 'default',
                         :$expires = 0,
                         Bool :$sign, Bool :$encr, Bool :$cert, Bool :$auth,
                         Bool :$nopasswd, Bool :$force, Bool :$noexpire
                         --> GPGME::GenKeyResult)
    {
        my $flags = BitEnum[GPGME::CreateFlags].new;
        $flags.set(GPGME_CREATE_SIGN)     if $sign;
        $flags.set(GPGME_CREATE_ENCR)     if $encr;
        $flags.set(GPGME_CREATE_CERT)     if $cert;
        $flags.set(GPGME_CREATE_AUTH)     if $auth;
        $flags.set(GPGME_CREATE_NOPASSWD) if $nopasswd;
        $flags.set(GPGME_CREATE_FORCE)    if $force;
        $flags.set(GPGME_CREATE_NOEXPIRE) if $noexpire;

        check $!context.create-subkey($key, $algorithm, 0,
                                      $expires.Int, +$flags);

        $!result = $!context.genkey-result;
    }

    method adduid(GPGME:D: GPGME::Key:D $key, Str:D $userid --> Nil)
    {
        check $!context.adduid($key, $userid, 0)
    }

    method revuid(GPGME:D: GPGME::Key:D $key, Str:D $userid --> Nil)
    {
        check $!context.revuid($key, $userid, 0)
    }

    method set-uid-flag(GPGME:D: GPGME::Key:D $key, Str:D $userid,
                        Str:D $name = 'primary', Str $value? --> Nil)
    {
        check $!context.set-uid-flag($key, $userid, $name, $value)
    }

    multi method genkey(GPGME:D: Str:D $parms --> GPGME::GenKeyResult)
    {
        my GPGME::Data $public .= new;
        my GPGME::Data $secret .= new;

        check $!context.genkey(qq:to/END/, $public.handle, $secret.handle);
        <GnupgKeyParms format="internal">
        $parms
        </GnupgKeyParms>
        END

        $!result = $!context.genkey-result
    }

    multi method genkey(GPGME:D: Str:D :$Key-Type = 'default', *%opts is copy)
    {
        samewith join "\n", "Key-Type: $Key-Type",
                            do for %opts.kv -> $k,$v { "$k: $v" };
    }

    method get-key(GPGME:D: Str:D $fpr, Bool :$secret --> GPGME::Key)
    {
        my Pointer $ptr .= new;
        given $!context.get-key($fpr, $ptr, $secret ?? 1 !! 0)
        {
            when GPG_ERR_NO_ERROR { nativecast(GPGME::Key, $ptr) }
            when GPG_ERR_EOF      { GPGME::Key }
            default               { check $_ }
        }
    }

    method keylist(GPGME:D: *@pattern, Bool :$secret --> Seq)
    {
        my CArray[Str] $pattern;
        $pattern .= new(@pattern, Str) if @pattern;
        my $code = $!context.keylist-start($pattern, $secret ?? 1 !! 0, 0);

        gather
        {
            while !$code
            {
                my Pointer $ptr .= new;
                $code = $!context.keylist-next($ptr);
                last if $code;
                take nativecast(GPGME::Key, $ptr);
            }
            die X::GPGME.new(:$code) if GPGME.errcode($code) != GPG_ERR_EOF;
        }
    }

    multi method signers(GPGME:D: *@keys where *.elems, Bool :$clear --> GPGME:D)
    {
        $!context.signers-clear if $clear;

        for @keys
        {
            when Str        { samewith self.keylist($_,) }
            when GPGME::Key { check $!context.signers-add($_) }
            default         { die X::GPGME::BadSigner.new(signer => .Str) }
        }
        self
    }

    multi method signers(GPGME:D: --> List)
    {
        do for ^$!context.signers-count -> $num
        {
            $!context.signers-enum($num)
        }
    }

    method notation(GPGME:D: Bool :$clear, *%notations)
    {
        return $!context.sig-notation-get.Map unless $clear or %notations;

        $!context.sig-notation-clear if $clear;

        for %notations.kv -> $name,$value
        {
            check $!context.sig-notation-add($name, $value,
                                             GPGME_SIG_NOTATION_HUMAN_READABLE)
        }
    }

    method keysign(GPGME:D: GPGME::Key:D $key,
                   *@userid,
                   :$expires is copy = 0,
                   Bool :$local,
                   Bool :$noexpire
                   --> Nil)
    {
        my $flags = BitEnum[GPGME::KeySignFlags].new;
        $flags.set(GPGME_KEYSIGN_LOCAL)    if $local;
        $flags.set(GPGME_KEYSIGN_NOEXPIRE) if $noexpire;

        my Str $userid;
        if @userid.elems > 1
        {
            $userid = join("\n", @userid);
            $flags.set(GPGME_KEYSIGN_LFSEP);
        }
        elsif @userid.elems == 1
        {
            $userid = @userid[0]
        }

        $expires .= posix if $expires ~~ DateTime;

        check $!context.keysign($key, $userid, $expires, +$flags);
    }

    method export(GPGME:D: *@args,
                 :$out is copy,
                 Bool :$extern,
                 Bool :$minimal,
                 Bool :$secret,
                 Bool :$raw,
                 Bool :$pkcs12 --> GPGME::Data)
    {
        $out = GPGME::Data.writer($out) unless $out ~~ GPGME::Data;

        my $mode = BitEnum[GPGME::ExportMode].new;
        $mode.set(GPGME_EXPORT_MODE_EXTERN)  if $extern;
        $mode.set(GPGME_EXPORT_MODE_MINIMAL) if $minimal;
        $mode.set(GPGME_EXPORT_MODE_SECRET)  if $secret;
        $mode.set(GPGME_EXPORT_MODE_RAW)     if $raw;
        $mode.set(GPGME_EXPORT_MODE_PKCS12)  if $pkcs12;

        if @args
        {
            if all(@args) ~~ GPGME::Key
            {
                my CArray[GPGME::Key] $keys .= new(@args, GPGME::Key);
                check $!context.export-keys($keys, +$mode, $out.handle)
            }
            elsif all(@args) ~~ Str
            {
                my CArray[Str] $patterns .= new(@args, Str);
                check $!context.export($patterns, +$mode, $out.handle)
            }
            else
            {
                die X::GPGME.new(code => GPG_ERR_GENERAL)
            }
        }
        else
        {
            check $!context.export(CArray[Str], +$mode, $out.handle)
        }

        $out.rewind
    }

    method import(GPGME:D: $keydata is copy --> GPGME::ImportResult)
    {
        $keydata = GPGME::Data.new($keydata) unless $keydata ~~ GPGME::Data;

        check $!context.import($keydata.handle);

        $!result = $!context.import-result()
    }

    multi method delete-key(GPGME:D: Str:D $fpr, |opts --> Nil)
    {
        samewith $.get-key($fpr, |opts), |opts
    }

    multi method delete-key(GPGME:D: GPGME::Key:D $key,
                            Bool :$secret,
                            Bool :$force --> Nil)
    {
        my $flags = BitEnum[GPGME::DeleteFlags].new;
        $flags.set(GPGME_DELETE_ALLOW_SECRET) if $secret;
        $flags.set(GPGME_DELETE_FORCE)        if $force;

        check $force ?? $!context.delete-key-ext($key, +$flags)
                     !! $!context.delete-key($key, +$flags)
    }

    method sign(GPGME:D: $plain is copy,
                :$out is copy,
                Bool :$detach, Bool :$clear)
    {
        $plain = GPGME::Data.new($plain)  unless $plain ~~ GPGME::Data;
        $out   = GPGME::Data.writer($out) unless $out   ~~ GPGME::Data;

        my $mode = $detach ?? GPGME_SIG_MODE_DETACH
                           !! $clear ?? GPGME_SIG_MODE_CLEAR
                                     !! GPGME_SIG_MODE_NORMAL;

        check $!context.sign($plain.handle, $out.handle, +$mode);

        $!result = $!context.sign-result;
        $out.rewind
    }

    method verify(GPGME:D: $sig is copy, $signed? is copy, :$out is copy)
    {
        $sig = GPGME::Data.new($sig) unless $sig ~~ GPGME::Data;

        if $signed
        {
            $signed = GPGME::Data.new($signed) unless $signed ~~ GPGME::Data;

            check $!context.verify($sig.handle, $signed.handle,
                                   GPGME::DataHandle);

            return $!result = $!context.verify-result;
        }
        else
        {
            $out = GPGME::Data.writer($out) unless $out ~~ GPGME::Data;

            check $!context.verify($sig.handle, GPGME::DataHandle,
                                   $out.handle);

            $!result = $!context.verify-result;

            return $out.rewind
        }
    }

    method encrypt(GPGME:D: $plain is copy,
                   *@recp,
                   :$out is copy,
                   Bool :$always-trust,
                   Bool :$no-encrypt-to,
                   Bool :$prepare,
                   Bool :$expect-sign,
                   Bool :$no-compress,
                   Bool :$symmetric,
                   Bool :$throw-keyids,
                   Bool :$wrap,
                   Bool :$sign
                   --> GPGME::Data)
    {
        my @keys;

        for @recp
        {
            when Str        { @keys.append: self.keylist($_) }
            when GPGME::Key { @keys.append: $_ }
            default         { die X::GPGME.new(code => GPG_ERR_GENERAL) }
        }

        my CArray[GPGME::Key] $recp .= new(@keys, GPGME::Key);

        my $flags = BitEnum[GPGME::EncryptFlags].new;
        $flags.set(GPGME_ENCRYPT_ALWAYS_TRUST)  if $always-trust;
        $flags.set(GPGME_ENCRYPT_NO_ENCRYPT_TO) if $no-encrypt-to;
        $flags.set(GPGME_ENCRYPT_PREPARE)       if $prepare;
        $flags.set(GPGME_ENCRYPT_EXPECT_SIGN)   if $expect-sign;
        $flags.set(GPGME_ENCRYPT_NO_COMPRESS)   if $no-compress;
        $flags.set(GPGME_ENCRYPT_SYMMETRIC)     if $symmetric;
        $flags.set(GPGME_ENCRYPT_THROW_KEYIDS)  if $throw-keyids;
        $flags.set(GPGME_ENCRYPT_WRAP)          if $wrap;

        $plain = GPGME::Data.new($plain)  unless $plain  ~~ GPGME::Data;
        $out   = GPGME::Data.writer($out) unless $out ~~ GPGME::Data;

        check $sign ?? $!context.encrypt-sign($recp, +$flags, $plain.handle,
                                              $out.handle)
                    !! $!context.encrypt($recp, +$flags, $plain.handle,
                                         $out.handle);

        $!result = $!context.encrypt-result;
        $out.rewind;
    }

    method decrypt(GPGME:D: $cipher is copy, :$out is copy,
                   Bool :$verify, Bool :$unwrap,
                   --> GPGME::Data)
    {
        $cipher = GPGME::Data.new($cipher) unless $cipher ~~ GPGME::Data;
        $out    = GPGME::Data.new($out)    unless $out    ~~ GPGME::Data;

        if $unwrap and $verify
        {
            check $!context.decrypt-ext(GPGME_DECRYPT_UNWRAP +&
                                        GPGME_DECRYPT_VERIFY,
                                        $cipher.handle, $out.handle)
        }
        elsif $unwrap
        {
            check $!context.decrypt-ext(GPGME_DECRYPT_UNWRAP,
                                        $cipher.handle, $out.handle)
        }
        elsif $verify
        {
            check $!context.decrypt-verify($cipher.handle, $out.handle)
        }
        else
        {
            check $!context.decrypt($cipher.handle, $out.handle)
        }

        $!result = $!context.decrypt-result;

        $out.rewind
    }

    submethod DESTROY()
    {
        .release with $!context;
        $!context = Nil;
    }
}

=begin pod

=head1 NAME

GPGME -- Raku bindings for Gnu Privacy Guard (GPG) Made Easy

=head1 SYNOPSIS

  put GPGME.version;
  put GPGME.dirinfo('gpg-name');
  GPGME.set-locale('C');

  my $gpg = GPGME.new;

  $gpg.create-key('joe@foo.bar');

  my $result = $gpg.result;            # Retrieve result from last operation.

=head1 DESCRIPTION


=head1 METHODS

=item method B<version>(--> Str:D)

=item B<dirinfo>(Str $what--> Str)

=item multi method B<engine-check-version>(Str:D $protocol --> Bool:D)
=item multi method B<engine-check-version>(GPGME::Protocol:D $protocol --> Bool:D)

Check to see if an engine is valid, the executable exists and has a
late enough version to function with GPGME.

=item method B<set-locale>(Str:D $locale = "" --> Nil)

Set the locale, either a default, or for a specific context.

=item method B<engine-info>($protocol?, Str :$filename, Str :$homedir--> GPGME::EngineInfo)

Can be called either for global defaults, or a specific context,
either retrieve the engine information, or set I<filename> or
I<homedir> for an engine.

e.g.

    put GPGME.engine-info;
    put GPGME.engine-info('openpgp');
    put GPGME.engine-info('openpgp').version;
    GPGME.engine-info('opengpg', :homedir</tmp/home>);

See C<GPGME::EngineInfo> for more information.

=item method B<new>(:$protocol, Str :$filename, Str :$homedir, Bool :$armor, Bool :$textmode, Bool :$offline, :$signers, :$passphrase, :&status-callback, :&progress-callback, :$pin-entry-mode, :$keylist-mode)

Creates a new C<GPGME> Context, and optionally applies various
settings to the context.  See other methods to see various settings.

=item method B<result>(GPGME:D:)

Retrieve the result object from the last operation.

=item method B<genkey-result>(GPGME:D: --> GPGME::GenKeyResult)
=item method B<import-result>(GPGME:D: --> GPGME::ImportResult)
=item method B<sign-result>(GPGME:D: --> GPGME::SignResult)
=item method B<encrypt-result>(GPGME:D: --> GPGME::EncryptResult)
=item method B<decrypt-result>(GPGME:D: --> GPGME::DecryptResult)
=item method B<verify-result>(GPGME:D: --> GPGME::VerifyResult)

Each of the C<*-result> methods retrieve a specific type of result.
These are only valid immediately following the appropriate operation,
and all results must be used or copied prior to the next operation,
when the results are no longer available.

=item method B<log>(GPGME:D: :$log, Bool :$html --> GPGME::Data)

I<log> can be anything C<GPGME::Data> can write to: a filename, an
C<IO::Path> or an C<IO::Handle>.  By default, it just writes to a
memory buffer and returns it.

  $gpg.log('logfile');
  $gpg.log($*ERR);
  put $gpg.log;

See L<Additional Logs|https://gnupg.org/documentation/manuals/gpgme/Additional-Logs.html> for more information.

=item multi method B<protocol>(GPGME:D: --> Str:D)
=item multi method B<protocol>(GPGME:D: Str:D $protocol --> GPGME:D)
=item multi method B<protocol>(GPGME:D: GPGME::Protocol:D $protocol --> GPGME:D)

Set or retrieve the protocol.

=item multi method B<sender>(GPGME:D: --> Str)
=item multi method B<sender>(GPGME:D: Str $address --> GPGME:D)

Set or retrieve the sender's address.

Some engines can make use of the sender’s address, for example to
figure out the best user id in certain trust models. For verification
and signing of mails, it is thus suggested to let the engine know the
sender ("From:") address.

I<address> is expected to be the “addr-spec” part of an address but my
also be a complete mailbox address, in which case this function
extracts the “addr-spec” from it. Using C<Str> for address clears the
sender address.

=item multi method B<armor>(GPGME:D: Bool:D $armor --> GPGME:D)
=item multi method B<armor>(GPGME:D: --> Bool:D)

Set or retrieve the ASCII armor setting.

=item multi method B<textmode>(GPGME:D: Bool:D $textmode --> GPGME:D)
=item multi method B<textmode>(GPGME:D: --> Bool:D)

Set or retrieve the setting for canonical text mode.

=item multi method B<offline>(GPGME:D: Bool:D $offline --> GPGME:D)
=item multi method B<offline>(GPGME:D: --> Bool:D)

Set or retrieve the setting for offline mode.  The details of the
offline mode depend on the used protocol and its backend engine. It
may eventually be extended to be more stricter and for example
completely disable the use of Dirmngr for any engine.

=item multi method B<pin-entry-mode>(GPGME:D: Str:D $mode --> GPGME:D)
=item multi method B<pin-entry-mode>(GPGME:D: GPGME::PinentryMode:D $mode --> GPGME:D)
=item multi method B<pin-entry-mode>(GPGME:D: --> GPGME::PinentryMode:D)

Set or retrieve the setting for the pin entry mode.

Possible values are default, ask, cancel, error, or loopback.

=item multi method B<keylist-mode>(GPGME:D: *@modes, Bool :$clear--> GPGME:D)
=item multi method B<keylist-mode>(GPGME:D: --> BitEnum)

Set or retrieve settings for the key listing behaviour.

This can be set to multiple values, and returns a C<BitEnum> object
that stringifies to a summary of the settings, or can check for
specific settings.

  gpg.keylist-mode('secret');
  put $gpg.keylist-mode;
  put 'secret is set' if $gpg.keylist-mode.isset('with_secret');
  my $mode = $gpg.keylist-mode;
  $mode.clear('with_secret');
  $gpg.keylist-mode($mode);

Possible values are local, extern, sigs, sig_notations, with_secret,
with_tofu, ephemeral, validate.

See L<Key Listing Mode|https://gnupg.org/documentation/manuals/gpgme/Key-Listing-Mode.html> for more information.

=item multi method B<passphrase>(GPGME:D: Str:D $passphrase)
=item multi method B<passphrase>(GPGME:D: &sub --> GPGME:D)

Configures either a static string I<passphrase> or a callback routine
called with three named parameters, C<(Str :$uid-hint, Str
:$passphrase-info, Str :$prev-was-bad)>.

It should return a C<Str> with the passphrase, or type object to
cancel the operation.

If not set, the user may be asked for a passphrase.

=item method B<status-callback>(GPGME:D: &sub:(Str, Str) --> GPGME:D)

Configure a status message callback routine.  It will be called with
the signature C<(Str $keyword, Str $args)>

=item method B<progress-callback>(GPGME:D: &sub:(Str,Int,Int,Int) --> GPGME:D)

Configure a progress callback routine.  It will be called with the
signature C<(Str $what, Int $type, Int $current, Int $total)>.

=item method B<create-key>(GPGME:D: Str:D $userid, Str:D :$algorithm = 'default', :$expires = 0, Bool :$sign, Bool :$encr, Bool :$cert, Bool :$auth, Bool :$nopasswd, Bool :$force, Bool :$noexpire)

Creates a pubic key pair.

I<$expires> can be C<Int> seconds, or a C<Duration>.

See L<Generating Keys|https://gnupg.org/documentation/manuals/gpgme/Generating-Keys.html> for more information.

=item method B<create-subkey>(GPGME:D: GPGME::Key:D $key, Str:D :$algorithm = 'default', :$expires = 0, Bool :$sign, Bool :$encr, Bool :$cert, Bool :$auth, Bool :$nopasswd, Bool :$force, Bool :$noexpire --> GPGME::GenKeyResult)

Adds a new subkey to a primary OpenPGP key.

=item method B<adduid>(GPGME:D: GPGME::Key:D $key, Str:D $userid --> Nil)

Add a new user ID to an OpenPGP key.

=item method B<revuid>(GPGME:D: GPGME::Key:D $key, Str:D $userid --> Nil)

Revoke a user ID from an OpenPGP key.

=item method B<set-uid-flag>(GPGME:D: GPGME::Key:D $key, Str:D $userid, Str:D $name = 'primary', Str $value? --> Nil)

Sets flags on a user ID from an OpenPGP Key.

a I<name> of 'primary' (the default) sets the primary key flag on the
given user ID, clearing the flag on other user IDs.

=item multi method B<genkey>(GPGME:D: Str:D $parms --> GPGME::GenKeyResult)
=item multi method B<genkey>(GPGME:D: Str:D :$Key-Type = 'default', *%opts)

An alternate method of generating a key pair.

You can eitehr specifiy a single string argument with a set of
parameters, or a selection of named parameters.

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

See L<GPG Key Generation|https://gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html> and L<CSR and Certificate Creation|https://www.gnupg.org/documentation/manuals/gnupg/CSR-and-certificate-creation.html> for more details on the parameters.

=item method B<get-key>(GPGME:D: Str:D $fpr, Bool :$secret --> GPGME::Key)

Look up and retrieve a key by fingerprint or key ID.

Set I<:secret> to retrieve the secret key.  The currently active
keylist mode is used to retrieve the key.

=item method B<keylist>(GPGME:D: *@pattern, Bool :$secret --> Seq)

Lists keys matching any of the specified patterns (or all keys if no
patterns).

Until the C<Seq> is fully retrieved, the context will be busy and
should not be used for other actions.  Either retrieve the whole list
first, or use another context.

=item multi method B<signers>(GPGME:D: *@keys, Bool :$clear --> GPGME:D)
=item multi method B<signers>(GPGME:D: --> List)

Set or retrieve a list of key signers to be used for signing actions.

Use C<:clear> to clear the list.

=item method B<notation>(GPGME:D: Bool :$clear, *%notations)

Set or retrieve signature notations.

=item method B<keysign>(GPGME:D: GPGME::Key:D $key, *@userid,
                   :$expires = 0, Bool :$local,
                   Bool :$noexpire --> GPGME:D)

Specifying no user IDs will sign with all valid user IDs.

I<expires> can be an posix time int or a C<DateTime>

See L<Signing Keys|https://gnupg.org/documentation/manuals/gpgme/Signing-Keys.html> for more information.

=item method B<export>(GPGME:D: *@patterns, :$out = GPGME::Data.new(Str); Bool :$extern, Bool :$minimal, Bool :$secret, Bool :$raw, Bool :$pkcs12 --> GPGME::Data)

C<$out> can be anything a C<GPGME::Data> can write to -- a C<Str> with
a filename, an C<IO::Path> of a file to write to, a C<IO::Handle>.
The C<GPGME::Data> object is returned regardless.

See L<Exporting Keys|https://gnupg.org/documentation/manuals/gpgme/Exporting-Keys.html> for more information.

Some examples:

  put $gpg.export('joe@foo.bar');                # Stringify and print out
  $gpg.export('joe@foo.bar', :out<outputfile>);  # Export to filename
  $gpg.export('joe@foo.bar', out => $*OUT);      # Send to a file handle

=item method B<import>(GPGME:D: $keydata --> GPGME::ImportResult)

I<$keydata> can be anything that can be used for a <GPGME::Data>
object: a C<Str>, an C<IO::Path> of a file with the keys, or a
C<IO::Handle> of a file with the data.

See L<Importing Keys|https://gnupg.org/documentation/manuals/gpgme/Importing-Keys.html> for more information

Returns a C<GPGME::ImportResult>

=item multi method B<delete-key>(GPGME:D: Str:D $fpr, |opts)
=item multi method B<delete-key>(GPGME:D: GPGME::Key:D $key, Bool :$secret, Bool :$force --> Nil)

Deletes a key.

See L<Deleting Keys|https://gnupg.org/documentation/manuals/gpgme/Deleting-Keys.html> for more information

=item method B<sign>(GPGME:D: $plain, $sig?, Bool :$detach, Bool :$clear)

Creates a signature for the text in the data object I<$plain>.

I<$plain> can be anything that can be used for a <GPGME::Data> object:
a C<Buf> or C<Str> with the actual data, an C<IO::Path> of a file with
the plaintext, or a C<IO::Handle> of a file with the data.

Similarly, if specified, I<$sig> can also be a <GPGME::Data> writable
object: a C<Str> filename, an C<IO::Path> filename, or a C<IO::Handle>
to write the signature to.

The signed data is returned in a <GPGME::Data> object.

Some examples:

  my $sig = $gpg.sign('some plain text');
  put $sig;                                     # Stringify

  $gpg.sign('inputfile'.IO, 'outputfile'.IO);   # Use filenames
  $gpg.sign($*IN, $*OUT);                       # Sign STDIN, write to STDOUT

A C<GPGME::SignResult> is stored in the context and can be queried.

=item method B<verify>(GPGME:D: $sig, $signed?, $plain?)

Verify a signature in a C<GPGME::Data> object.  Can optionally specify
C<GPGME::Data> objects in I<$signed> and $<plain> as well.

If the signature is detached, specify the I<$signed> data.

I<$sig> and I<$signed> can be anything that a <GPGME::Data> object can
read from: A C<Buf> or C<Str> with the data, or a C<IO::Path> or
C<IO::Handle> with the data.

I<$plain> will get the returned plain text from the signature.  It can
be a <Str> or an <IO::Path> with a filename, or an <IO::Handle>.  By
default, a memory buffer is used and returned in a C<GPGME::Data>
object which can be stringified or read from.

A C<GPGME::VerifyReuslt> is stored in the context and can be queried.

See L<Verify|https://gnupg.org/documentation/manuals/gpgme/Verify.html> for more information.

=item method B<encrypt>(GPGME:D: $plain, *@keys, :$out, Bool :$always-trust, Bool :$no-encrypt-to, Bool :$prepare, Bool :$expect-sign, Bool :$no-compress, Bool :$symmetric, Bool :$throw-keyids, Bool :$wrap --> GPGME::Data)

I<$plain> can be anything that a <GPGME::Data> object can
read from: A C<Buf> or C<Str> with the data, or a C<IO::Path> or
C<IO::Handle> with the data.

I<$out> can be a <Str> or an <IO::Path> with a filename, or an
<IO::Handle>.  By default, a memory buffer is used and returned in a
C<GPGME::Data> object which can be stringified or read from.

A C<GPGME::EncryptResult> is stored in the context and can be queried.

See L<Encrypt|https://gnupg.org/documentation/manuals/gpgme/Encrypting-a-Plaintext.html> for more information.

=item method B<decrypt>(GPGME:D: $cipher, :$out, Bool :$verify, Bool :$unwrap, --> GPGME::Data)

I<$cipher> can be anything that a <GPGME::Data> object can
read from: A C<Buf> or C<Str> with the data, or a C<IO::Path> or
C<IO::Handle> with the data.

I<$out> can be a <Str> or an <IO::Path> with a filename, or an
<IO::Handle>.  By default, a memory buffer is used and returned in a
C<GPGME::Data> object which can be stringified or read from.

A C<GPGME::DecryptResult> is stored in the context and can be queried.

See L<Decrypt|https://gnupg.org/documentation/manuals/gpgme/Decrypt.html> for more information.

=end pod
