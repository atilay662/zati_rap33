@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC_ATI_AKVBAS'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZC_ATI_AKVBAS 
provider contract transactional_query
as projection on ZI_ATI_AKVBAS

{
    key Musteriid,
    Musteritnm,
    Sehir,
    Adres,
    Sorumlu,
    Ticketsayisi, 
    Toplamsaat,
    Onaydrm,
    @Semantics.amount.currencyCode : 'currency'
    Toptutar,
    Currency,
    Uname,
    Timestamp,
    Aedat,
    Psotm,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    Lastchantime,
    /* Associations */
    _akvkal : redirected to composition child ZC_ATI_AKVKAL
}
