FUNCTION zati_update_db.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_PARAM) TYPE  ZA_ATI_DEFAULT_ABSTRACT
*"     REFERENCE(IV_MUSTERIID) TYPE  ZATI_E_001
*"----------------------------------------------------------------------
    UPDATE zati_aktv_baslik SET adres          = @is_param-adres,
                                toplamsaat     = @is_param-toplamsaat,
                                toptutar       = @is_param-toptutar,
                                currency       = @is_param-currency_code
                     WHERE musteriid = @iv_musteriid.

ENDFUNCTION.
