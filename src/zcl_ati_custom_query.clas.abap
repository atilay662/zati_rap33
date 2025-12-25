CLASS zcl_ati_custom_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_ati_custom_query IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA: lt_result TYPE TABLE OF zi_ati_custom_ce,
          lt_final  TYPE TABLE OF zi_ati_custom_ce,
          lv_clause TYPE string,
          lv_fname1 TYPE c LENGTH 30,
          lv_tabix  TYPE char5,
          lt_sort   TYPE abap_sortorder_tab,
          ls_sort   TYPE abap_sortorder.

*    DATA ls_filtrange TYPE zati_filter_range.

    FIELD-SYMBOLS <lfs_glofilt>  TYPE any.
    FIELD-SYMBOLS <lfs_rangestr> TYPE any.

    " Sort
    DATA(lt_sort_elements) = io_request->get_sort_elements( ).

    " Filter
    DATA(lo_filter) = io_request->get_filter( ).
    DATA(lt_filter_ranges) = lo_filter->get_as_ranges( ).

    " Page Line Size
    DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
    DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                THEN 0
                                ELSE lv_page_size ).

    IF NOT io_request->is_data_requested( ).
      RETURN.
    ENDIF.

*    IF lt_filter_ranges IS NOT INITIAL.
*
*      LOOP AT lt_filter_ranges INTO DATA(ls_filter).
*        lv_tabix = sy-tabix.
*        CONDENSE lv_tabix NO-GAPS.
*
*        ASSIGN ('LS_FILTER-RANGE') TO <lfs_glofilt>.
*        CONCATENATE 'LS_FILTRANGE-FIELD' lv_tabix INTO lv_fname1.
*        ASSIGN (lv_fname1) TO <lfs_rangestr>.
*
*        <lfs_rangestr> = <lfs_glofilt>.
*        IF lv_clause IS INITIAL.
*          lv_clause = |{ ls_filter-name } IN @{ lv_fname1 }|.
*        ELSE.
*          lv_clause = |{ lv_clause } AND { ls_filter-name } IN @{ lv_fname1 }|.
*        ENDIF.
*      ENDLOOP.
*
*    ELSE.
      " Filtre yoksa tümünü getir
      SELECT * FROM zati_aktv_baslik
        INTO CORRESPONDING FIELDS OF TABLE @lt_result.
*    ENDIF.

*    SORT lt_result BY vbeln.

    " Dinamik sıralama için sort tablosunu oluştur
    IF lt_sort_elements IS NOT INITIAL.
      LOOP AT lt_sort_elements INTO DATA(ls_sort_element).
        CLEAR ls_sort.

        " Alan adını küçük harfe çevir (SAP field isimleri için)
        ls_sort-name = to_upper( ls_sort_element-element_name ).

        " Sıralama yönünü belirle
        IF ls_sort_element-descending = abap_true.
          ls_sort-descending = abap_true.
        ELSE.
          ls_sort-descending = abap_false.
        ENDIF.

        " Büyük/küçük harf duyarlılığı (opsiyonel)
        ls_sort-astext = abap_false.

        APPEND ls_sort TO lt_sort.
      ENDLOOP.

      " Dinamik sıralama uygula
      IF lt_sort IS NOT INITIAL.
        SORT lt_result BY (lt_sort).
      ENDIF.
    ENDIF.

    IF lv_max_rows > 0.
      TRY.
          lt_final = VALUE #( FOR i = lv_offset + 1 THEN i + 1 WHILE i <= lv_offset + lv_max_rows
                              ( lt_result[ i ] ) ).
        CATCH cx_root INTO DATA(lx_error).
      ENDTRY.
    ELSE.
      lt_final = lt_result.
    ENDIF.

    " Set result
    io_response->set_data( lt_final ).
    io_response->set_total_number_of_records( lines( lt_result ) ).
  ENDMETHOD.

ENDCLASS.
