@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aktivite Kalem CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ATI_AKVKAL
  as select from zati_aktv_kalem
  association to parent ZI_ATI_AKVBAS as _akvbas on $projection.Musteriid = _akvbas.Musteriid
{
  key musteriid  as Musteriid,
  key ticketno   as Ticketno,
      aktiviteid as Aktiviteid,
      projeturu  as Projeturu,
      lokasyon   as Lokasyon,
      ortam      as Ortam,
      _akvbas // Make association public
}
