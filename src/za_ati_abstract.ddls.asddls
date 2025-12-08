@EndUserText.label: 'Abstract Entity'

define abstract entity ZA_ATI_ABSTRACT
{
  @Semantics.amount.currencyCode : 'currency_code'
  @EndUserText.label: 'Saatlik Ücret'
  Hourprice     : /dmo/flight_price;
  //@UI.hidden    : true
  currency_code : /dmo/currency_code;
}
