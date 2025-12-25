@EndUserText.label: 'Abstract Entity'

define abstract entity ZA_ATI_DEFAULT_ABSTRACT
{
  @UI.defaultValue: 'Default Adres'
  adres         : abap.sstring(70);
  toplamsaat    : abap.int8;
  @Semantics.amount.currencyCode : 'currency_code'
  toptutar      : /dmo/flight_price;
  currency_code : /dmo/currency_code;
}
