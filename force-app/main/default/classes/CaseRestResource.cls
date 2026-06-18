/**
 * @description       : 
 * @author            : Jeferson Tavares
 * @group             : 
 * @last modified on  : 05-06-2026
 * @last modified by  : Jeferson Tavares
**/
@RestResource(UrlMapping='/api/back-office/caso/*')
global with sharing class CaseRestResource {
    @HttpPost
    global static void createCasePosVendas() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 201;

        try {

            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            Map<String, Object> data = (Map<String, Object>) requestBody.get('data');


            res = data == null ? BackofficeApisUtils.createResponse(400, new Map<String, Object>{
                    'erro' => 'Missing data in the request body'
            }, res) : res;


            Map<String, Object> accountData = (Map<String, Object>) data.get('conta');
            Map<String, Object> caseData = (Map<String, Object>) data.get('caso');

            res = accountData == null || caseData == null ? BackofficeApisUtils.createResponse(400, new Map<String, Object>{
                    'erro' => 'Missing account or case data in the request body'
            }, res) : res;

            String errorFields = BackofficeApisUtils.validRequiredAccountFields(accountData);
            res = errorFields != '' ? BackofficeApisUtils.createResponse(400, new Map<String, Object>{
                    'erro' => 'campos obrigatórios ou formato inválido', 'detail' => errorFields
            }, res) : res;

            //Se o statusCode do contexto mantém 201 segue.
            if (res.statusCode == 201) {
                Account currentAccount = BackofficeApisUtils.accountHandler(accountData);

                //Cria o caso
                Case casoPosVendas = new Case();
                casoPosVendas.AccountId = currentAccount.Id;
                //Campos da Arvore de Atendimento - Informações Adicionais
                casoPosVendas.Meio_de_Contato__c = (String) caseData.get('meio_de_contato');
                casoPosVendas.Origin = (String) caseData.get('origem_do_caso');
                casoPosVendas.Canal__c = (String) caseData.get('canal');

                casoPosVendas.Servico__c = (String) caseData.get('servico');
                casoPosVendas.Motivo__c = (String) caseData.get('motivo');
                casoPosVendas.Assunto__c = (String) caseData.get('assunto');
                casoPosVendas.Produto__c = (String) caseData.get('produto');

                if (caseData.get('existe_sinistro') != null) {
                    Boolean existeSinistro = (Boolean) caseData.get('existe_sinistro');
                    casoPosVendas.Existe_Sinistro__c = existeSinistro;
                    casoPosVendas.N_do_Aviso__c = (Decimal) caseData.get('n_aviso');
                }

                casoPosVendas.Canal_de_Entrada_Susep__c = (String) caseData.get('canal_susep');
                casoPosVendas.Data_Recebimento_Email__c = String.isNotBlank((String) caseData.get('data_recebimento')) ?
                        UtilityClass.formatDateISO8601((String) caseData.get('data_recebimento')) : null;


                // Campos do negocio
                casoPosVendas.Local_de_Risco__c = (String) caseData.get('local_de_risco');
                casoPosVendas.Apolice__c = (String) caseData.get('apolice');
                casoPosVendas.Negocio__c = (String) caseData.get('negocio');
                casoPosVendas.Item__c = (String) caseData.get('item');
                casoPosVendas.Endosso__c = (String) caseData.get('endosso');
                casoPosVendas.Status__c = (String) caseData.get('status_negocio');
                
                casoPosVendas.Vigencia_Inicio__c = String.isNotBlank((String) caseData.get('dt_ini_vig')) ?
                        UtilityClass.formatDateISO8601((String) caseData.get('dt_ini_vig')) : null;
                        
                casoPosVendas.Vigencia_Fim__c = String.isNotBlank((String) caseData.get('dt_fim_vig')) ?
                        UtilityClass.formatDateISO8601((String) caseData.get('dt_fim_vig')) : null;
                        
                casoPosVendas.Ramo__c = (String) caseData.get('ramo');
                casoPosVendas.Numero_Operador__c = (String) caseData.get('numoper');
                casoPosVendas.ID_Apolice__c = (String) caseData.get('idepol');

                casoPosVendas.Descricao__c = (String) caseData.get('descricao');
                casoPosVendas.Status_Desligamento__c = (String) caseData.get('status');
                casoPosVendas.Numero_do_Ticket__c = (String) caseData.get('numero_ticket');

                //campos produto habitacional
                casoPosVendas.Numero_Segurado__c = (String) caseData.get('idSegurado');
                casoPosVendas.Certificado__c = (String) caseData.get('certificados');
                casoPosVendas.Matricula_Bilhete__c = caseData.get('matriculaBilhete') != null && String.valueOf(caseData.get('matriculaBilhete')).trim() != '' ?
                        (Decimal) caseData.get('matriculaBilhete') : null;
                casoPosVendas.Classificacao_Negocio__c = (String) caseData.get('classificacaoNegocio');

                Id caseRecordTypeId = UtilityClass.getRecordTypeId('Case', 'Pos_Vendas');
                casoPosVendas.RecordTypeId = caseRecordTypeId;

                if (caseData.get('area_solucao') != null) {
                    casoPosVendas.Status_Desligamento__c = 'Encaminhado';
                    casoPosVendas.OwnerId = BackofficeApisUtils.getQueue((String) caseData.get('area_solucao'));
                    casoPosVendas.Area_de_Solucao__c = (String) caseData.get('area_solucao');
                }


                insert casoPosVendas;

                //get CaseNumber - Protocolo
                Case protocolo = [SELECT CaseNumber FROM Case WHERE Id = :casoPosVendas.Id];

                //Envia resposta
                res = BackofficeApisUtils.createResponse(
                        201,
                        new Map<String, Object>{
                                'Id' => casoPosVendas.Id,
                                'protocolo' => protocolo.CaseNumber,
                                'nome_completo' => currentAccount.Nome_Completo__c,
                                'cpf' => accountData.get('cpf')
                        }
                        , res);
            }
        } catch (DmlException e) {

            logError('DmlException', e.getMessage(), e.getStackTraceString(),
                    req.requestURI, req.requestBody.toString(), Datetime.now());

            res = BackofficeApisUtils.createResponse(500,
                    new Map<String, Object>{
                            'erro' => 'Error creating Case', 'detail' => e.getMessage()
                    }
                    , res);


        } catch (Exception e) {

            logError('Exception', e.getMessage(), e.getStackTraceString(),
                    req.requestURI, req.requestBody.toString(), Datetime.now());

            res = BackofficeApisUtils.createResponse(
                    500,
                    new Map<String, Object>{
                            'erro' => 'Error processing request', 'detail' => e.getMessage(), 'stackTrace' => e.getStackTraceString()
                    },
                    res
            );
        }
    }

    @Future
    public static void logError(String errorType, String errorMessage, String stackTrace,
            String endpoint, String requestBody, Datetime requestDate) {
        ApiErrors__b logErro = new ApiErrors__b(
                errorType__c = errorType,
                errorMessage__c = errorMessage,
                stackTrace__c = stackTrace,
                endpoint__c = endpoint,
                requestBody__c = requestBody,
                requestDate__c = requestDate
        );

        // Não tenta inserir em Big Object durante testes
        if (Test.isRunningTest()) {
            System.debug('Simulando inserção de log de erro em contexto de teste');
            return;
        }

        Database.SaveResult sr = Database.insertImmediate(logErro);
        if (!sr.isSuccess()) {
            System.debug(LoggingLevel.ERROR, 'Falha ao salvar log de erro: ' + sr.getErrors());
        }
    }

}