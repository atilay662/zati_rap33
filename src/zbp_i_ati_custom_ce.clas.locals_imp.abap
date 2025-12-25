CLASS lhc_zi_ati_custom_ce DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_ati_custom_ce RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_ati_custom_ce RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_ati_custom_ce RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zi_ati_custom_ce.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_ati_custom_ce.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_ati_custom_ce.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_ati_custom_ce RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_ati_custom_ce.

    METHODS getdefaultsforabstract FOR READ
      IMPORTING keys FOR FUNCTION zi_ati_custom_ce~getdefaultsforabstract RESULT result.

    METHODS editline FOR MODIFY
      IMPORTING keys FOR ACTION zi_ati_custom_ce~editline RESULT result.

    METHODS precheck_editline FOR PRECHECK
      IMPORTING keys FOR ACTION zi_ati_custom_ce~editline.

ENDCLASS.

CLASS lhc_zi_ati_custom_ce IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD getdefaultsforabstract.
*    READ ENTITIES OF zi_ati_custom_ce IN LOCAL MODE
*     ENTITY zi_ati_custom_ce
*     ALL FIELDS WITH CORRESPONDING #( keys )
*     RESULT DATA(lt_head).

    DATA(ls_keys) = keys[ 1 ].

    SELECT * FROM zati_aktv_baslik
      WHERE musteriid = @ls_keys-musteriid
      INTO TABLE @DATA(lt_head).

    LOOP AT lt_head INTO DATA(ls_head).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      <lfs_result>-%tky-musteriid       = ls_head-musteriid."Key alanı vermezsen veriler dolmuyor önemli !!
      <lfs_result>-%param-adres         = ls_head-adres.
      <lfs_result>-%param-toplamsaat    = ls_head-toplamsaat.
      <lfs_result>-%param-toptutar      = ls_head-toptutar.
      <lfs_result>-%param-currency_code = 'TRY'.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_editline.
*    DATA(ls_keys) = keys[ 1 ].
*
*    READ ENTITIES OF zi_ati_custom_ce IN LOCAL MODE
*         ENTITY zi_ati_custom_ce
*         ALL FIELDS WITH CORRESPONDING #( keys )
*         RESULT DATA(lt_baslik).
*
*    DATA(ls_baslik) = lt_baslik[ 1 ].
*
*    IF ls_keys-%param-toplamsaat = ''.
*      APPEND VALUE #(
*          %tky                = ls_baslik-%tky
*          "%state_area     = 'sorumlu'
*          %element-toplamsaat = if_abap_behv=>mk-on
*          %msg                = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                       text     = |Toplam saat zorunludur boş bırakılamaz| ) )
*             TO reported-zi_ati_custom_ce.
*
*      APPEND VALUE #( %tky = ls_baslik-%tky ) TO failed-zi_ati_custom_ce.
*    ENDIF.
  ENDMETHOD.

  METHOD editline.
    DATA(ls_keys) = keys[ 1 ].
*    DATA(lv_retupd) = update_database( is_param     = ls_keys-%param
*                                       iv_musteriid = ls_keys-musteriid  ).
*    DATA(lv_retupd) = zcl_ati_database_update=>update_database( is_param     = ls_keys-%param
*                                                                iv_musteriid = ls_keys-musteriid  ).
    MODIFY ENTITIES OF zi_ati_akvbas
           ENTITY zi_ati_akvbas
           UPDATE FIELDS ( adres toplamsaat toptutar currency )
           WITH VALUE #( ( musteriid  = ls_keys-musteriid
                           adres      = ls_keys-%param-adres
                           toplamsaat = ls_keys-%param-toplamsaat
                           toptutar   = ls_keys-%param-toptutar
                           currency   = ls_keys-%param-currency_code ) ).
*    MODIFY ENTITIES OF zi_ati_custom_ce IN LOCAL MODE
*           ENTITY zi_ati_custom_ce
*           UPDATE FIELDS ( adres toplamsaat toptutar currency )
*           WITH VALUE #( ( %key-musteriid = ls_keys-musteriid
*                           adres          = ls_keys-%param-adres
*                           toplamsaat     = ls_keys-%param-toplamsaat
*                           toptutar       = ls_keys-%param-toptutar
*                           currency       = ls_keys-%param-currency_code
*                         ) ).
*    CALL FUNCTION 'ZATI_UPDATE_DB'
*      EXPORTING is_param     = ls_keys-%param
*                iv_musteriid = ls_keys-musteriid.

*    UPDATE zati_aktv_baslik SET musteriid      = @ls_keys-musteriid,
*                                adres          = @ls_keys-%param-adres,
*                                toplamsaat     = @ls_keys-%param-toplamsaat,
*                                toptutar       = @ls_keys-%param-toptutar,
*                                currency       = @ls_keys-%param-currency_code
*                     WHERE musteriid = @ls_keys-musteriid.

    " IF lv_retupd = 'X'.
    APPEND VALUE #( %tky                = ls_keys-%tky
                    "%state_area     = 'sorumlu'
                    %element-toplamsaat = if_abap_behv=>mk-on
                    %msg                = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                                 text     = |Güncelleme başarılı| ) )
           TO reported-zi_ati_custom_ce.

    "Custom entity Read Çalışmadı
    READ ENTITIES OF zi_ati_custom_ce IN LOCAL MODE
         ENTITY zi_ati_custom_ce
         ALL FIELDS WITH VALUE #( ( musteriid = ls_keys-musteriid ) )
         RESULT DATA(lt_result).

    result = VALUE #( FOR ls_keys2 IN keys
                      ( %tky = ls_keys2-%tky
                       " %param = ls_keys2-%param
                      ) ).

*    result = VALUE #( FOR ls_result IN lt_result
*                      ( %tky   = ls_result-%tky
*                        %param = ls_result ) ).

    " ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_ati_custom_ce DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_ati_custom_ce IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
