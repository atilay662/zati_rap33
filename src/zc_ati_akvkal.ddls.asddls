@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC_ATI_AKVKAL'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZC_ATI_AKVKAL as projection on ZI_ATI_AKVKAL
{
    key Musteriid,
    key Ticketno,
    Aktiviteid,
    Projeturu,
    Lokasyon,
    Ortam,
    /* Associations */
    _akvbas:redirected to parent ZC_ATI_AKVBAS
}
