/**
 * @description       :
 * @author            : Leonardo Cavalcante
 * @group             :
 * @last modified on  : 06-03-2026
 * @last modified by  : Jeferson Tavares
 **/
public class InstallmentController {
  private static String orgWideEmailAdress = 'noreply@caixaresidencial.com.br';
  @AuraEnabled(cacheable=true)
  public static List<FacilitaAcxParcelasDTO.ParcelasResponse> getInstallments(String numOper) {
    if (numOper == null || numOper == '') {
      return new List<FacilitaAcxParcelasDTO.ParcelasResponse>();
    }
    return FacilitaService.getParcelas(numOper);
  }

  @AuraEnabled(cacheable=true)
  public static List<FacilitaAcxRepiqueDTO.AcxRepiqueResponse> getRepics(String idetitulo) {
    return FacilitaService.getRepique(idetitulo);
  }

  @AuraEnabled(cacheable=true)
  public static List<FacilitaAcxDetalhesCartaoDTO.DetalhesCartaoResponse> getCardInfo(String numeroTitulo) {
    return FacilitaService.getDetalhesCartao(numeroTitulo);
  }

  @AuraEnabled(cacheable=true)
  public static ConsultaServiceDetalhesParcelaDTO.DetalheParcelaResponse getInstallmentDetails(
    Integer codigoItem,
    Integer codigoEndosso,
    Integer numeroParcela
  ) {
    return ConsultaService.getDetalhesParcela(codigoItem, codigoEndosso, numeroParcela);
  }

  @AuraEnabled(cacheable=true)
  public static ConsultaServiceDadosItemSeguradoDTO.DadosItemSeguradoResponse getInsuredItem(
    Integer codigoItem,
    Integer codigoEndosso
  ) {
    return ConsultaService.getDadosItemSegurado(codigoItem, codigoEndosso);
  }

  @AuraEnabled(cacheable=true)
  public static AcselConsultaVigPropostaDTO.VigPropostaResponse getProposalValidity(Integer pNumcert, Integer pCodneg) {
    return AcselService.getVigProposta(pNumcert, pCodneg);
  }

  @AuraEnabled(cacheable=true)
  public static SegundaViaBoletoDTO.SegundaViaBoletoResponse getDuplicateBill(String cNumTitulo, String cfecVencNovo) {
    return SegundaViaService.submitSegundaViaBoleto(cNumTitulo, cfecVencNovo);
  }

  @AuraEnabled(cacheable=true)
  public static string getDuplicatePolicy(
    String idepol,
    String numCert,
    String numOper,
    String moduloProduto,
    String mail,
    String tipoDoc
  ) {
    System.debug('### getDuplicatePolicy - idepol: ' + idepol);
    System.debug('### getDuplicatePolicy - numCert: ' + numCert);
    System.debug('### getDuplicatePolicy - numOper: ' + numOper);
    System.debug('### getDuplicatePolicy - moduloProduto: ' + moduloProduto);
    System.debug('### getDuplicatePolicy - mail: ' + mail);
    System.debug('### getDuplicatePolicy - tipoDoc: ' + tipoDoc);
    return SegundaViaService.submitSegundaViaApolice(idepol, numCert, numOper, moduloProduto, mail, tipoDoc);
  }

  @AuraEnabled(cacheable=true)
  public static GNTAgendamentoDTO.AgendamentoResponse send2ViaBoletoSMS(
    String cpfCNPJ,
    String linhaDigitavel,
    String dataVencimento,
    String destino
  ) {
    List<GNTAgendamentoDTO.DestinatariosDetalhe> destinatariosDetalhes = new List<GNTAgendamentoDTO.DestinatariosDetalhe>();
    destinatariosDetalhes.add(GNTService.buildDestinatario(cpfCNPJ, destino));

    List<GNTAgendamentoDTO.Parametro> listParams = new List<GNTAgendamentoDTO.Parametro>();
    listParams.add(GNTService.buildParametro('LINHA_DIGITAVEL', linhaDigitavel));
    listParams.add(GNTService.buildParametro('DT_VENCIMENTO', dataVencimento));
    listParams.add(GNTService.buildParametro('CPF_CNPJ_SEGURADO', cpfCNPJ));

    return GNTService.submitAgendamento(
      new List<GNTAgendamentoDTO.Anexo>(),
      'SMPEOATEN0006',
      cpfCNPJ,
      destinatariosDetalhes,
      listParams,
      'S',
      'SMS'
    );
  }

  @AuraEnabled(cacheable=true)
  public static BuscarDadosSeguradoDTO.DadosSeguradoResponse getInsuredData(Integer insuredId) {
    return AffinityService.getDadosSegurado(insuredId, 'CONTACT_CENTER');
  }

  @AuraEnabled(cacheable=true)
  public static Boolean sendMassificadosDocsByEmail(String email, String subject, String body, String displayName) {
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    List<String> address = new List<String>{ email };
    Messaging.reserveSingleEmailCapacity(1);

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setSubject(subject);
    mail.setplaintextbody(body);
    mail.setToAddresses(address);
    mail.setHTMLBody(body);
    emailList.add(mail);

    try {
      OrgWideEmailAddress emailAddressORG = [
        SELECT Id, Address, DisplayName
        FROM OrgWideEmailAddress
        WHERE Address = :orgWideEmailAdress
        LIMIT 1
      ];

      mail.setOrgWideEmailAddressId(emailAddressORG.Id);
    } catch (Exception e) {
      mail.setSenderDisplayName(displayName);
    } finally {
      if (!emailList.isEmpty()) {
        return (Messaging.sendEmail(emailList))[0].isSuccess();
      } else {
        return false;
      }
    }

    return false;
  }

  @AuraEnabled(cacheable=true)
  public static ConfirmarEnderecosDTO.ConfirmarEnderecosResponse confirmAddress(String addressToConfirm) {
    ConfirmarEnderecosDTO.Confirmacao confirmacao = (ConfirmarEnderecosDTO.Confirmacao) System.JSON.deserialize(
      addressToConfirm,
      ConfirmarEnderecosDTO.Confirmacao.class
    );
    return AffinityService.confirmaEndereco(confirmacao);
  }

  @AuraEnabled(cacheable=true)
  public static GNTAgendamentoDTO.AgendamentoResponse scheduleAppointment(
    String cpfCNPJ,
    String sendServiceCode,
    String sendType,
    List<Map<String, String>> emailAddresses,
    List<Map<String, String>> params
  ) {
    //Formatacao dos Destinatarios
    List<GNTAgendamentoDTO.DestinatariosDetalhe> destinatariosDetalhes = new List<GNTAgendamentoDTO.DestinatariosDetalhe>();
    for (Map<String, String> emailMap : emailAddresses) {
      destinatariosDetalhes.add(GNTService.buildDestinatario(emailMap.get('cpfCnpj'), emailMap.get('destino')));
    }

    List<GNTAgendamentoDTO.Parametro> listParams = new List<GNTAgendamentoDTO.Parametro>();
    for (Map<String, String> param : params) {
      listParams.add(GNTService.buildParametro(param.get('nomeParametro'), param.get('valorParametro')));
    }

    return GNTService.submitAgendamento(
      new List<GNTAgendamentoDTO.Anexo>(),
      sendServiceCode,
      cpfCNPJ,
      destinatariosDetalhes,
      listParams,
      'S',
      sendType
    );
  }

  @AuraEnabled(cacheable=true)
  public static GNTMensagemDTO.MensagemResponse getMensagem(String codigoDocumento, String recordId) {
    GNTMensagemDTO.MensagemResponse mensagemResponse = new GNTMensagemDTO.MensagemResponse();
    List<ComponentView__mdt> enviarDocumentos = [
      SELECT Id, ApiFieldsTypesAndCaseFields__c
      FROM ComponentView__mdt
      WHERE DeveloperName = 'Enviar_Documentos'
    ];
    Map<String, String> apiFieldXCaseFieldsMap = new Map<String, String>();
    Map<String, String> caseFieldXTypeFieldMap = new Map<String, String>();

    mensagemResponse = GNTService.getMensagem(codigoDocumento);
    if (enviarDocumentos.size() == 1 && String.isNotBlank(recordId)) {
      // String soql ='SELECT Id ';
      for (String apiFieldXCaseFields : enviarDocumentos[0].ApiFieldsTypesAndCaseFields__c.split(',')) {
        apiFieldXCaseFieldsMap.put(
          apiFieldXCaseFields.substringBefore(':').trim(),
          apiFieldXCaseFields.substringAfterLast(':').removeEnd(',')
        );
        caseFieldXTypeFieldMap.put(
          apiFieldXCaseFields.substringAfterLast(':').trim(),
          apiFieldXCaseFields.substringBetween(':').trim()
        );
        // soql+=','+apiFieldXCaseFields.substringAfterLast(':').removeEnd(',');
      }
      // soql+=' FROM Case WHERE Id=\''+ recordId +'\'';
      // Case caso = Database.query(soql);
      String whereClauses = 'Id =\'' + recordId + '\'';
      String extraFields = ', Account.Name, Account.CPF_CNPJ__c, Account.Nome_Completo__c, Account.Nome_Social__c';
      Case caso = (Case) UtilityClass.getSObject('Case', whereClauses, extraFields);
      Map<String, String> apiFieldXValueMapInternal = installmentController.setFieldsXValue(
        apiFieldXCaseFieldsMap.values(),
        caso
      );
      System.debug(apiFieldXValueMapInternal);
      for (GNTMensagemDTO.MensagemWrapper resposta : mensagemResponse.return_x) {
        for (GNTMensagemDTO.Parametros parametros : resposta.parametros) {
          System.debug(parametros);
          if (apiFieldXCaseFieldsMap.containsKey(parametros.nome)) {
            parametros.value = apiFieldXValueMapInternal.get(apiFieldXCaseFieldsMap.get(parametros.nome));
            parametros.type = caseFieldXTypeFieldMap.get(apiFieldXCaseFieldsMap.get(parametros.nome));
            //Exceção para o nome social (Para o GNT todos os campos são obrigatórios)
            if (parametros.nome == 'NOME_SOCIAL' && parametros.value == null) {
              parametros.value = ' ';
            }
          }
        }
      }
    }
    return mensagemResponse;
  }

  public static Map<String, String> setFieldsXValue(List<String> apiNames, sObject obj) {
    Map<String, String> returnFieldsXValue = new Map<String, String>();
    for (String campo : apiNames) {
      returnFieldsXValue.put(campo, getFieldsXValue(obj, campo));
    }
    return returnFieldsXValue;
  }

  private static String getFieldsXValue(sObject obj, String fieldName) {
    if (fieldName.contains('.')) {
      List<String> fieldParts = fieldName.split('\\.', 2);
      SObject childRecord = (SObject) obj.getSObject(fieldParts[0]);
      if (childRecord == null) {
        return null;
      } else {
        return getFieldsXValue(childRecord, fieldParts[1]);
      }
    } else {
      return String.valueOf(obj.get(fieldName));
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getRecords(String numOper) {
    Map<String, String> mapToReturn = new Map<String, String>();
    List<FacilitaAcxParcelasDTO.ParcelasResponse> installments = handleInstallments(numOper);
    mapToReturn.put('Installments', JSON.serialize(installments));

    return mapToReturn;
  }

  public static List<FacilitaAcxParcelasDTO.ParcelasResponse> handleInstallments(String numOper) {
    List<FacilitaAcxParcelasDTO.ParcelasResponse> installments = getInstallments(numOper);
    BusinessHours businessHours = [SELECT Id, TimeZoneSidKey FROM BusinessHours WHERE IsDefault = TRUE];
    for (FacilitaAcxParcelasDTO.ParcelasResponse installment : installments) {
      System.debug('installment >>>' + installment);
      installment.delayedDays = getDelayedDays(installment, businessHours.Id);
    }

    return installments;
  }

  public static Integer getDelayedDays(FacilitaAcxParcelasDTO.ParcelasResponse installment, Id bhId) {
    System.debug(installment.idetitulo);
    System.debug(installment.fecvencfact);
    if (installment.fecvencfact != null) {
      String dtString = installment.fecvencfact.substringBefore('T');
      Date dt = Date.valueOf(dtString);
      Integer delayedDays = (Integer) (System.BusinessHours.diff(
        bhId,
        Datetime.newInstance(dt.year(), dt.month(), dt.day()),
        Datetime.now()
      ) / (1000 * 60 * 60 * 9));
      System.debug('delayedDays >>>' + delayedDays);
      return delayedDays <= 0 ? 0 : delayedDays;
    }
    return 0;
  }

  public class ObjFieldWrapper {
    @AuraEnabled
    public String fieldApi { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String fieldCaseApiName { get; set; }

    public ObjFieldWrapper(String fieldApi, String type, String fieldCaseApiName) {
      this.fieldApi = fieldApi;
      this.type = type;
      this.fieldCaseApiName = fieldCaseApiName;
    }
  }
}
