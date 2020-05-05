use NativeCall;
use GPGME::Check;
use GPGME::Constants;
use GPGME::EngineInfo;
use GPGME::Key;
use GPGME::SigNotation;
use GPGME::DataHandle;
use GPGME::SignResult;
use GPGME::EncryptResult;
use GPGME::DecryptResult;
use GPGME::GenKeyResult;
use GPGME::VerifyResult;
use GPGME::ImportResult;

class GPGME::Context is repr('CPointer')                       # gpgme_context
{
    sub gpgme_new(Pointer $ptr is rw --> uint32)
        is native {}

    method new(--> GPGME::Context)
    {
        my Pointer $ptr .= new;
        check gpgme_new($ptr);
        nativecast(GPGME::Context, $ptr)
    }

    method set-protocol(int32 --> uint32)
        is native is symbol('gpgme_set_protocol') {}

    method get-protocol(--> int32)
        is native is symbol('gpgme_get_protocol') {}

    method release()
        is native is symbol('gpgme_release') {}

    method get-engine-info(--> GPGME::EngineInfo)
        is native is symbol('gpgme_ctx_get_engine_info') {}

    method set-engine-info(int32 $proto, Str $filename, Str $homedir --> uint32)
        is native is symbol('gpgme_ctx_set_engine_info') {}

    method set-sender(Str $address --> uint32)
        is native is symbol('gpgme_set_sender') {}

    method get-sender(--> Str)
        is native is symbol('gpgme_get_sender') {}

    method set-armor(int32 $yes)
        is native is symbol('gpgme_set_armor') {}

    method get-armor(--> int32)
        is native is symbol('gpgme_get_armor') {}

    method set-textmode(int32 $yes)
        is native is symbol('gpgme_set_textmode') {}

    method get-textmode(--> int32)
        is native is symbol('gpgme_get_textmode') {}

    method set-offline(int32 $yes)
        is native is symbol('gpgme_set_offline') {}

    method get-offline(--> int32)
        is native is symbol('gpgme_get_offline') {}

    method set-pinentry-mode(int32 --> uint32)
        is native is symbol('gpgme_set_pinentry_mode') {}

    method get-pinentry-mode(--> int32)
        is native is symbol('gpgme_get_pinentry_mode') {}

    method set-keylist-mode(int32 --> uint32)
        is native is symbol('gpgme_set_keylist_mode') {}

    method get-keylist-mode(--> int32)
        is native is symbol('gpgme_get_keylist_mode') {}

    method create-key(Str $userid, Str $algorithm, ulong $reserved,
                      ulong $expires, GPGME::Key $extrakey, uint32 $flags
                      --> uint32)
        is native is symbol('gpgme_op_createkey') {}

    method create-subkey(GPGME::Key, Str, ulong, ulong, uint32 --> uint32)
        is native is symbol('gpgme_op_createsubkey') {}

    method adduid(GPGME::Key, Str, uint32 --> uint32)
        is native is symbol('gpgme_op_adduid') {}

    method revuid(GPGME::Key, Str, uint32 --> uint32)
        is native is symbol('gpgme_op_revuid') {}

    method set-uid-flag(GPGME::Key, Str, Str, Str --> uint32)
        is native is symbol('gpgme_op_set_uid_flag') {}

    method genkey(Str $parms, GPGME::DataHandle, GPGME::DataHandle
                  --> uint32)
        is native is symbol('gpgme_op_genkey') {}

    method genkey-result(--> GPGME::GenKeyResult)
        is native is symbol('gpgme_op_genkey_result') {}

    method get-key(Str $fpr, Pointer $key is rw, int32 $secret --> uint32)
        is native is symbol('gpgme_get_key') {}

    method keylist-start(CArray[Str], int32, int32 --> uint32)
        is native is symbol('gpgme_op_keylist_ext_start') {}

    method keylist-next(Pointer $key is rw --> uint32)
        is native is symbol('gpgme_op_keylist_next') {}

    method keysign(GPGME::Key $key, Str $userid, ulong $expires, uint32 $flags
                   --> uint32)
        is native is symbol('gpgme_op_keysign') {}

    method export(CArray[Str], uint32, GPGME::DataHandle --> uint32)
        is native is symbol('gpgme_op_export_ext') {}

    method export-keys(CArray[GPGME::Key], uint32, GPGME::DataHandle --> uint32)
        is native is symbol('gpgme_op_export_keys') {}

    method import(GPGME::DataHandle --> uint32)
        is native is symbol('gpgme_op_import') {}

    method import-result(--> GPGME::ImportResult)
        is native is symbol('gpgme_op_import_result') {}

    method delete-key(GPGME::Key, int32 --> uint32)
        is native is symbol('gpgme_op_delete') {}

    method delete-key-ext(GPGME::Key, uint32 --> uint32)
        is native is symbol('gpgme_op_delete_ext') {}

    method signers-clear()
        is native is symbol('gpgme_signers_clear') {}

    method signers-add(GPGME::Key --> uint32)
        is native is symbol('gpgme_signers_add') {}

    method signers-count(--> uint32)
        is native is symbol('gpgme_signers_count') {}

    method signers-enum(int32 --> GPGME::Key)
        is native is symbol('gpgme_signers_enum') {}

    method sign(GPGME::DataHandle, GPGME::DataHandle, int32 --> uint32)
           is native is symbol('gpgme_op_sign') {}

    method sign-result(--> GPGME::SignResult)
        is native is symbol('gpgme_op_sign_result') {}

    method set-passphrase-callback(&callback (int64, Str, Str, int32, int32
                                              --> uint32), int64)
        is native is symbol('gpgme_set_passphrase_cb') {}

    method set-status-callback(&callback (int64, Str, Str --> uint32), int64)
        is native is symbol('gpgme_set_status_cb') {}

    method set-progress-callback(&callback (int64, Str, int32, int32, int32),
                                 int64)
        is native is symbol('gpgme_set_progress_cb') {}

    method encrypt(CArray[GPGME::Key], int32, GPGME::DataHandle,
                   GPGME::DataHandle --> uint32)
        is native is symbol('gpgme_op_encrypt') {}

    method encrypt-sign(CArray[GPGME::Key], int32, GPGME::DataHandle,
                        GPGME::DataHandle --> uint32)
        is native is symbol('gpgme_op_encrypt_sign') {}

    method encrypt-result(--> GPGME::EncryptResult)
        is native is symbol('gpgme_op_encrypt_result') {}

    method decrypt(GPGME::DataHandle, GPGME::DataHandle
                       --> uint32)
        is native is symbol('gpgme_op_decrypt') {}

    method decrypt-ext(int32, GPGME::DataHandle, GPGME::DataHandle --> uint32)
        is native is symbol('gpgme_op_decrypt_ext') {}

    method decrypt-result(--> GPGME::DecryptResult)
        is native is symbol('gpgme_op_decrypt_result') {}

    method decrypt-verify(GPGME::DataHandle, GPGME::DataHandle --> uint32)
        is native is symbol('gpgme_op_decrypt_verify') {}

    method getauditlog(GPGME::DataHandle, uint32 --> uint32)
        is native is symbol('gpgme_op_getauditlog') {}

    method sig-notation-clear()
        is native is symbol('gpgme_sig_notation_clear') {}

    method sig-notation-add(Str, Str, int32 $flags --> uint32)
        is native is symbol('gpgme_sig_notation_clear') {}

    method sig-notation-get(--> GPGME::SigNotation)
        is native is symbol('gpgme_sig_notation_get') {}

    method verify(GPGME::DataHandle, GPGME::DataHandle, GPGME::DataHandle
                  --> uint32)
        is native is symbol('gpgme_op_verify') {}

    method verify-result(--> GPGME::VerifyResult)
        is native is symbol('gpgme_op_verify_result') {}
}
