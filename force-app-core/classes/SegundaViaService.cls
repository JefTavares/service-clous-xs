/**
 * @description       :
 * @author            : Gabriel Topini
 * @group             :
 * @last modified on  : 06-03-2026
 * @last modified by  : Jeferson Tavares
 **/
public class SegundaViaService {
  public class SegundaViaServiceException extends Exception {
  }

  public static SegundaViaBoletoDTO.SegundaViaBoletoResponse submitSegundaViaBoleto(
    String cNumTitulo,
    String cfecVencNovo
  ) {
    HttpResponse response;
    SegundaViaBoletoDTO.SegundaViaBoletoResponse segundaViaBoletoResponse;
    try {
      Map<String, String> mapHeader = new Map<String, String>();
      mapHeader.put('Authorization', TokenManager.getToken('local.Token.salesforceBroker', 'Get_Token'));
      SegundaViaBoletoDTO.SegundaViaBoletoRequest segundaViaBoletoRequest = new SegundaViaBoletoDTO.SegundaViaBoletoRequest();
      segundaViaBoletoRequest.cnumtitulo = cNumTitulo;
      segundaViaBoletoRequest.cfecvencnovo = cfecVencNovo;
      segundaViaBoletoRequest.corigem = 'SALESFORCE';
      response = IntegrationRest.sendRequest('Segunda_Via_Boleto', mapHeader, segundaViaBoletoRequest);

      if (response.getStatusCode() == 200) {
        segundaViaBoletoResponse = new SegundaViaBoletoDTO.SegundaViaBoletoResponse();
        segundaViaBoletoResponse = SegundaViaBoletoDTO.parse(response.getBody());
      } else {
        throw new SegundaViaServiceException('Erro na integração: ' + response.getBody());
      }
    } catch (SegundaViaServiceException e) {
      throw new SegundaViaServiceException(e.getMessage());
    }
    return segundaViaBoletoResponse;
  }

  public static String submitSegundaViaApolice(
    String idepol,
    String numCert,
    String numOper,
    String moduloProduto,
    String mail,
    String tipoDoc
  ) {
    System.debug('### submitSegundaViaApolice - idepol: ' + idepol);
    System.debug('### submitSegundaViaApolice - numCert: ' + numCert);
    System.debug('### submitSegundaViaApolice - numOper: ' + numOper);
    System.debug('### submitSegundaViaApolice - moduloProduto: ' + moduloProduto);
    System.debug('### submitSegundaViaApolice - mail: ' + mail);
    System.debug('### submitSegundaViaApolice - tipoDoc: ' + tipoDoc);

    HttpResponse response;
    String segundaViaApoliceResponse;
    try {
      Map<String, String> mapHeader = new Map<String, String>();
      mapHeader.put('Authorization', TokenManager.getToken('local.Token.salesforceBroker', 'Get_Token'));
      SegundaViaApoliceDTO.ApoliceRequest apoliceRequest = new SegundaViaApoliceDTO.ApoliceRequest();
      apoliceRequest.idepol = idepol;
      apoliceRequest.numCert = numCert;
      apoliceRequest.numOper = numOper;
      apoliceRequest.moduloProduto = moduloProduto;
      apoliceRequest.mail = mail;
      apoliceRequest.tipoDoc = tipoDoc;
      response = IntegrationRest.sendRequest('Segunda_Via_Apolice', mapHeader, apoliceRequest);

      if (response.getStatusCode() == 200) {
        segundaViaApoliceResponse = response.getBody();
      } else {
        throw new SegundaViaServiceException('Erro na integração: ' + response.getBody());
      }
    } catch (SegundaViaServiceException e) {
      throw new SegundaViaServiceException(e.getMessage());
    }
    return segundaViaApoliceResponse;
  }
}
