@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aktivite Başlık CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ATI_AKVBAS
  as select from zati_aktv_baslik
  composition [0..*] of ZI_ATI_AKVKAL as _akvkal
{
  key musteriid    as Musteriid,
      musteritnm   as Musteritnm,
      sehir        as Sehir,
      adres        as Adres,
      sorumlu      as Sorumlu,
      ticketsayisi as Ticketsayisi,
      toplamsaat   as Toplamsaat,
      onaydrm      as Onaydrm,
      @Semantics.amount.currencyCode : 'currency'
      toptutar     as Toptutar,
      currency     as Currency,
      @Semantics.user.lastChangedBy: true
      uname        as Uname,
      @Semantics.systemDateTime.lastChangedAt: true
      timestamp    as Timestamp,
      aedat        as Aedat,
      psotm        as Psotm,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      lastchantime as Lastchantime,
      _akvkal // Make association public
}
