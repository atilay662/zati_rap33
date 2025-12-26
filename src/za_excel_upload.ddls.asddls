@EndUserText.label: 'Excel Upload'
define abstract entity ZA_EXCEL_UPLOAD
  //with parameters parameter_name : parameter_type
{
  @Semantics.largeObject: { mimeType: 'MimeType', fileName: 'FileName', contentDispositionPreference: #ATTACHMENT }
 
  Attachment : abap.rawstring(0);
  MimeType   : abap.string(0);
   @Semantics.mimeType: true
  FileName   : abap.string(0);
}
