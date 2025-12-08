@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Müşteri Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ATI_MUSTERI_VH as select from zati_aktv_baslik
{
    key musteriid as Musteriid,
    musteritnm as Musteritnm
}
