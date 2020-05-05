use NativeCall;
use GPGME::Check;

enum GPGME::SeekWhence <GPGME_SEEK_SET GPGME_SEEK_CUR GPGME_SEEK_END>;

class GPGME::DataHandle is repr('CPointer')
{
    method release()
        is native is symbol('gpgme_data_release') {}

    method identify(--> int32)
        is native is symbol('gpgme_data_identify') {}

    method get-filename(--> Str)
        is native is symbol('gpgme_data_get_file_name') {}

    method set-filename(Str --> uint32)
        is native is symbol('gpgme_data_set_file_name') {}

    method get-encoding(--> int32)
        is native is symbol('gpgme_data_get_encoding') {}

    method set-encoding(int32 --> uint32)
        is native is symbol('gpgme_data_set_encoding') {}

    method read(Blob, size_t --> size_t)
        is native is symbol('gpgme_data_read') {}

    method write(Blob, size_t --> size_t)
        is native is symbol('gpgme_data_write') {}

    method seek(uint64, int32 --> uint64)
        is native is symbol('gpgme_data_seek') {}
}
