CLASS lhc_zi_ati_akvbas DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_ati_akvbas RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_ati_akvbas RESULT result.
    METHODS copyactivity FOR MODIFY
      IMPORTING keys FOR ACTION zi_ati_akvbas~copyactivity.
    METHODS acceptact FOR MODIFY
      IMPORTING keys FOR ACTION zi_ati_akvbas~acceptact RESULT result.
    METHODS rejectact FOR MODIFY
      IMPORTING keys FOR ACTION zi_ati_akvbas~rejectact RESULT result.
    METHODS mandatory_sorumlu FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_ati_akvbas~mandatory_sorumlu.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_ati_akvbas RESULT result.
    METHODS settimelog FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_ati_akvbas~settimelog.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zi_ati_akvbas.
    METHODS calcprice FOR MODIFY
      IMPORTING keys FOR ACTION zi_ati_akvbas~calcprice RESULT result.
    METHODS onaydurum FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_ati_akvbas~onaydurum.
    METHODS getdefaultsforabstract FOR READ
      IMPORTING keys FOR FUNCTION zi_ati_akvbas~getdefaultsforabstract RESULT result.
    METHODS editline FOR MODIFY
      IMPORTING keys FOR ACTION zi_ati_akvbas~editline RESULT result.
    METHODS precheck_editline FOR PRECHECK
      IMPORTING keys FOR ACTION zi_ati_akvbas~editline.
    METHODS uploadexcel FOR MODIFY
      IMPORTING keys FOR ACTION zi_ati_akvbas~uploadexcel.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_ati_akvbas.

ENDCLASS.

CLASS lhc_zi_ati_akvbas IMPLEMENTATION.
  METHOD get_instance_authorizations.
    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
         ENTITY zi_ati_akvbas
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_head)
         FAILED failed.

    IF lt_head IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<lfs_head>).
      IF <lfs_head>-musteriid = 2.
        IF requested_authorizations-%update = if_abap_behv=>mk-on.
          APPEND VALUE #( %tky    = <lfs_head>-%tky
                          %update = if_abap_behv=>auth-unauthorized ) TO result.
          EXIT.

        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
*    IF requested_authorizations-%create = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*                      ID '/DMO/CNTRY' DUMMY
*                      ID 'ACTVT' FIELD '01'.
*
*      result-%create = COND #( WHEN sy-subrc = 0
*                               THEN if_abap_behv=>auth-allowed
*                               ELSE if_abap_behv=>auth-unauthorized ).
*    ENDIF.

*    IF requested_authorizations-%update = if_abap_behv=>mk-on.
*      result-%update = if_abap_behv=>auth-unauthorized.
*    ENDIF.
*
*    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
*      result-%delete = if_abap_behv=>auth-unauthorized.
*    ENDIF.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lt_entity) = entities.
    DATA lo_msg TYPE REF TO if_abap_behv_message.

    DELETE lt_entity WHERE musteriid <> ''.
    SELECT MAX( musteriid ) FROM zati_aktv_baslik INTO @DATA(lv_maxmid).

    LOOP AT lt_entity INTO DATA(ls_entity).
      lv_maxmid += 1.
      CONDENSE lv_maxmid NO-GAPS.
      APPEND VALUE #( %cid      = ls_entity-%cid
                      "%key      = ls_entity-%key
                      musteriid = lv_maxmid ) TO mapped-zi_ati_akvbas.
    ENDLOOP.
    IF sy-subrc NE 0.
      " Failed
      APPEND VALUE #( %cid = ls_entity-%cid
                      %key = ls_entity-%key )
             TO failed-zi_ati_akvbas.

      " Reported
      lo_msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                      text     = 'Deneme hata mesajı!' ).

      APPEND VALUE #( %cid = ls_entity-%cid
                      %key = ls_entity-%key
                      %msg = lo_msg )
             TO reported-zi_ati_akvbas.
    ENDIF.
  ENDMETHOD.

  METHOD copyactivity.
    DATA : lt_bas_cre TYPE TABLE FOR CREATE zi_ati_akvbas,
           lt_kal_cre TYPE TABLE FOR CREATE zi_ati_akvbas\_akvkal,
           lo_msg     TYPE REF TO if_abap_behv_message.

    " Header
    ASSIGN keys[ %cid = '' ] TO FIELD-SYMBOL(<ls_without_cid>).
    ASSERT <ls_without_cid> IS NOT ASSIGNED.

    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
         ENTITY zi_ati_akvbas
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_head_r)
         FAILED DATA(lt_failed_r).

    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
         ENTITY zi_ati_akvbas BY \_akvkal
         ALL FIELDS WITH CORRESPONDING #( lt_head_r )
         RESULT DATA(lt_item_r).

    LOOP AT lt_head_r ASSIGNING FIELD-SYMBOL(<ls_head_r>).
      APPEND VALUE #( %cid  = keys[ KEY entity
                      musteriid = <ls_head_r>-musteriid ]-%cid
                      %data = CORRESPONDING #( <ls_head_r> EXCEPT musteriid ) )
             TO lt_bas_cre ASSIGNING FIELD-SYMBOL(<ls_bas_cre>).

      <ls_bas_cre>-adres = 'Kopya Adres'.

      " Tek tek alanlar Modify Yazmak İstemiyorsan Control Alanını İşaretle
      DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <ls_bas_cre>-%control ) ).
      LOOP AT lo_struct->components ASSIGNING FIELD-SYMBOL(<ls_comp>).
        IF <ls_comp>-name = 'MUSTERIID'. " Key Alanı Hariç tuttuk yoksa Dump
          CONTINUE.
        ENDIF.
        ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE <ls_bas_cre>-%control TO FIELD-SYMBOL(<lv_flag>).
        IF sy-subrc = 0.
          <lv_flag> = if_abap_behv=>mk-on. " Yani '01' - Bu alanı kaydet demek.
        ENDIF.
      ENDLOOP.

      " Item
      APPEND VALUE #( %cid_ref = <ls_bas_cre>-%cid ) TO lt_kal_cre
             ASSIGNING FIELD-SYMBOL(<ls_kal_cre>).

      LOOP AT lt_item_r ASSIGNING FIELD-SYMBOL(<ls_item_r>) USING KEY entity
           WHERE musteriid = <ls_head_r>-musteriid.

        APPEND VALUE #( %cid  = <ls_bas_cre>-%cid && <ls_item_r>-ticketno
                        %data = CORRESPONDING #( <ls_item_r> EXCEPT musteriid ) ) TO <ls_kal_cre>-%target.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_ati_akvbas IN LOCAL MODE
           ENTITY zi_ati_akvbas
           " CREATE FIELDS ( MUSTERITNM SEHIR ADRES SORUMLU TOPLAMSAAT )  WITH
           CREATE FROM
           lt_bas_cre
           ENTITY zi_ati_akvbas
           CREATE BY \_akvkal
           FIELDS ( ticketno aktiviteid projeturu lokasyon ortam )"musteriid
           WITH lt_kal_cre
           MAPPED DATA(lt_mapped)
           FAILED DATA(lt_failed)
           REPORTED DATA(lt_reported).

    IF lt_failed IS INITIAL.
      lo_msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                      text     = 'Activity copy succesfull' ).

      APPEND VALUE #( %msg = lo_msg ) TO reported-zi_ati_akvbas.
    ENDIF.

    mapped = lt_mapped.
*        READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
*         ENTITY zi_ati_akvbas
*         ALL FIELDS WITH CORRESPONDING #( keys )
*         RESULT DATA(lt_result).
  ENDMETHOD.

  METHOD acceptact.
    DATA lo_msg TYPE REF TO if_abap_behv_message.

    MODIFY ENTITIES OF zi_ati_akvbas IN LOCAL MODE
           ENTITY zi_ati_akvbas
           UPDATE FIELDS ( onaydrm )
           WITH VALUE #( FOR ls_keys IN keys
                         ( %tky    = ls_keys-%tky
                           onaydrm = 'O' ) ).

    lo_msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                    text     = 'Activity has been approved' ).

    APPEND VALUE #( %msg = lo_msg ) TO reported-zi_ati_akvbas.

    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
         ENTITY zi_ati_akvbas
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result
                      ( %tky   = ls_result-%tky
                        %param = ls_result ) ).
  ENDMETHOD.

  METHOD rejectact.
    DATA lo_msg TYPE REF TO if_abap_behv_message.

    MODIFY ENTITIES OF zi_ati_akvbas IN LOCAL MODE
           ENTITY zi_ati_akvbas
           UPDATE FIELDS ( onaydrm )
           WITH VALUE #( FOR ls_keys IN keys
                         ( %tky    = ls_keys-%tky
                           onaydrm = 'R' ) ).

    lo_msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                    text     = 'Activity has been rejected' ).

    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
      ENTITY zi_ati_akvbas
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result
                      ( %tky   = ls_result-%tky
                        %param = ls_result ) ).
  ENDMETHOD.

  METHOD mandatory_sorumlu.
    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
         ENTITY zi_ati_akvbas
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_head_r)
         FAILED DATA(lt_failed).

    LOOP AT lt_head_r ASSIGNING FIELD-SYMBOL(<ls_head>).
      IF <ls_head>-sorumlu IS INITIAL.
        APPEND VALUE #( %tky             = <ls_head>-%tky
                        "%state_area     = 'sorumlu'
                        %element-sorumlu = if_abap_behv=>mk-on
                        %msg             = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = |Sorumlu alanı zorunludur boş bırakılamaz| )
                      ) TO reported-zi_ati_akvbas.

        APPEND VALUE #( %tky = <ls_head>-%tky ) TO failed-zi_ati_akvbas.
      ENDIF.

      IF <ls_head>-sehir IS INITIAL.
        APPEND VALUE #( %tky           = <ls_head>-%tky
                        "%state_area     = 'sorumlu'
                        %element-sehir = if_abap_behv=>mk-on
                        %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                text     = |Şehir alanı zorunludur boş bırakılamaz| )
                      ) TO reported-zi_ati_akvbas.

        APPEND VALUE #( %tky = <ls_head>-%tky ) TO failed-zi_ati_akvbas.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
         ENTITY zi_ati_akvbas
         FIELDS ( musteriid onaydrm )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_head).

    result = VALUE #( FOR ls_head IN lt_head
                      ( %tky                        = ls_head-%tky
                        %features-%action-acceptact = COND #( WHEN ls_head-onaydrm = 'O'
                                                              THEN if_abap_behv=>fc-o-disabled
                                                              ELSE if_abap_behv=>fc-o-enabled )
                        %features-%action-rejectact = COND #( WHEN ls_head-onaydrm = 'R'
                                                              THEN if_abap_behv=>fc-o-disabled
                                                              ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD settimelog.
    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
    ENTITY zi_ati_akvbas
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_head).

    DELETE lt_head WHERE aedat IS NOT INITIAL .

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<lfs_head>).
      <lfs_head>-aedat = cl_abap_context_info=>get_system_date( ).
      <lfs_head>-psotm = cl_abap_context_info=>get_system_time( ).
    ENDLOOP.

    CHECK lt_head IS NOT INITIAL.

    MODIFY ENTITIES OF zi_ati_akvbas IN LOCAL MODE
    ENTITY zi_ati_akvbas
     UPDATE FIELDS ( aedat psotm )
      WITH VALUE #( FOR wa IN lt_head
                    ( %tky  = wa-%tky
                      aedat = wa-aedat
                      psotm = wa-psotm ) ).
  ENDMETHOD.

  METHOD precheck_update.
    LOOP AT entities INTO DATA(ls_head).
      IF ls_head-ticketsayisi = '1'.
        APPEND VALUE #( %tky                  = ls_head-%tky
                        %element-ticketsayisi = if_abap_behv=>mk-on
                        %msg                  = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                       text     = |Ticket sayısı 1 olamaz! | )
        ) TO reported-zi_ati_akvbas.

        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-zi_ati_akvbas.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calcprice.
    DATA(ls_keyprm) = keys[ 1 ]-%param.

    IF ls_keyprm-hourprice IS INITIAL.
      APPEND VALUE #(
          %tky              = keys[ 1 ]-%tky
          "%element-hourprice = if_abap_behv=>mk-on
          %msg              = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                     text     = |Saatlik ücret alanı zorunludur boş bırakılamaz| )
          %action-calcprice = if_abap_behv=>mk-on ) TO reported-zi_ati_akvbas.

      APPEND VALUE #( %tky              = keys[ 1 ]-%tky ) TO failed-zi_ati_akvbas.
      RETURN.
    ENDIF.

    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
         ENTITY zi_ati_akvbas
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_head).

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<lfs_head>).
      IF ls_keyprm-hourprice IS NOT INITIAL.
        <lfs_head>-toptutar = ls_keyprm-hourprice * <lfs_head>-toplamsaat.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zi_ati_akvbas IN LOCAL MODE
           ENTITY zi_ati_akvbas
           UPDATE FIELDS ( toptutar currency )
           WITH VALUE #( ( %key     = <lfs_head>-%key
                           toptutar = <lfs_head>-toptutar
                           currency = ls_keyprm-currency_code ) ).

    result = VALUE #( FOR ls_head IN lt_head
                      ( %tky   = ls_head-%tky
                        %param = ls_head ) ).

    APPEND VALUE #( %tky = <lfs_head>-%tky
                    %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                  text     = |Toplam tutar hesaplandı| ) )
           TO reported-zi_ati_akvbas.
  ENDMETHOD.

  METHOD onaydurum.
    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
         ENTITY zi_ati_akvbas
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_head).

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<lfs_head>).
      " Toplam Tutar 1000 den Küçükse Direkt Onay
      IF <lfs_head>-toptutar > 1000 OR <lfs_head>-onaydrm = 'O'.
        CONTINUE.
      ENDIF.

      <lfs_head>-onaydrm = 'O'.

      MODIFY ENTITIES OF zi_ati_akvbas IN LOCAL MODE
             ENTITY zi_ati_akvbas
             UPDATE FIELDS ( onaydrm )
             WITH VALUE #( ( %tky    = <lfs_head>-%tky
                             onaydrm = <lfs_head>-onaydrm ) ).

      APPEND VALUE #( %tky = <lfs_head>-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                                    text     = |Onay durum güncellendi| ) )
             TO reported-zi_ati_akvbas.
    ENDLOOP.
  ENDMETHOD.

  METHOD getdefaultsforabstract.
    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
     ENTITY zi_ati_akvbas
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_head).

    LOOP AT lt_head INTO DATA(ls_head).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      <lfs_result>-%tky = ls_head-%tky.
      <lfs_result>-%param-adres = ls_head-adres.
      <lfs_result>-%param-toplamsaat = ls_head-toplamsaat.
      <lfs_result>-%param-toptutar = ls_head-toptutar.
      <lfs_result>-%param-currency_code = 'TRY'.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_editline.
    DATA(ls_keys) = keys[ 1 ].

    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
    ENTITY zi_ati_akvbas
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_baslik).

    DATA(ls_baslik) = lt_baslik[ 1 ] .

    IF ls_keys-%param-toplamsaat = ''.
      APPEND VALUE #( %tky                = ls_baslik-%tky
                      "%state_area     = 'sorumlu'
                      %element-toplamsaat = if_abap_behv=>mk-on
                      %msg                = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                   text     = |Toplam saat zorunludur boş bırakılamaz| )
                    ) TO reported-zi_ati_akvbas.

      APPEND VALUE #( %tky = ls_baslik-%tky ) TO failed-zi_ati_akvbas.

    ENDIF.
  ENDMETHOD.

  METHOD editline.
    DATA(ls_keys) = keys[ 1 ].

    MODIFY ENTITIES OF zi_ati_akvbas IN LOCAL MODE
           ENTITY zi_ati_akvbas
           UPDATE FIELDS ( adres toplamsaat toptutar currency )
           WITH VALUE #( ( %key-musteriid = ls_keys-musteriid
                           adres          = ls_keys-%param-adres
                           toplamsaat     = ls_keys-%param-toplamsaat
                           toptutar       = ls_keys-%param-toptutar
                           currency       = ls_keys-%param-currency_code
                         ) ).

    APPEND VALUE #( %tky                = ls_keys-%tky
           "%state_area     = 'sorumlu'
                    %element-toplamsaat = if_abap_behv=>mk-on
                    %msg                = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                                 text     = |Güncelleme başarılı| )
    ) TO reported-zi_ati_akvbas.

    READ ENTITIES OF zi_ati_akvbas IN LOCAL MODE
     ENTITY zi_ati_akvbas
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result
                      ( %tky   = ls_result-%tky
                        %param = ls_result ) ).
  ENDMETHOD.

  METHOD uploadExcel.
  ENDMETHOD.

ENDCLASS.
