CLASS zcl_ati_database_update DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS update_database
      IMPORTING is_param          TYPE za_ati_default_abstract
                iv_musteriid      TYPE zati_e_001
      RETURNING VALUE(rv_success) TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_ati_database_update IMPLEMENTATION.
  METHOD update_database.
    UPDATE zati_aktv_baslik SET adres          = @is_param-adres,
                                toplamsaat     = @is_param-toplamsaat,
                                toptutar       = @is_param-toptutar,
                                currency       = @is_param-currency_code
                     WHERE musteriid = @iv_musteriid.
  ENDMETHOD.
ENDCLASS.
