@EndUserText.label: 'Abstract Entity'

define abstract entity ZA_ATI_ABSTRACT
{

    @UI.defaultValue : 'Test'
    test          : abap.char( 10 );
    @Semantics.amount.currencyCode : 'currency_code'
    @EndUserText.label: 'Saatlik Ücret'
    Hourprice     : /dmo/flight_price;
    currency_code : /dmo/currency_code;
//  @UI.hidden    : true


//  adres         : abap.sstring(70);
//  toplamsaat    : abap.int8;
//  @Semantics.amount.currencyCode : 'currency_code'
//  toptutar      : /dmo/flight_price;
//  currency_code : /dmo/currency_code;

}
