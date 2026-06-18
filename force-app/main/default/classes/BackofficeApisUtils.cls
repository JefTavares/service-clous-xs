/**
 * @description       : 
 * @author            : Jeferson Tavares
 * @group             : 
 * @last modified on  : 05-06-2026
 * @last modified by  : Jeferson Tavares
**/
public with sharing class BackofficeApisUtils {

    public static Id getQueue(String solutionArea) {
        Areas_de_Solucoes__mdt metadataRecord = [
                SELECT Fila__c
                FROM Areas_de_Solucoes__mdt WHERE MasterLabel = :solutionArea
                LIMIT 1
        ];
        if (metadataRecord != null && metadataRecord.Fila__c != null) {
            Group queueRecord = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :metadataRecord.Fila__c LIMIT 1];
            if (queueRecord != null) {
                return queueRecord.Id;
            }
        }
        return null;
    }

    //O tratamento para contas é igual em todos os end-points. Receber o accountData validado.
    public static Account accountHandler(Map<String, Object> accountData) {
        Id accountRecordTypeId = UtilityClass.getRecordTypeId('Account', 'Segurado_Pessoa_Fisica');
        Account currentAccount = new Account();

        String email = (String) accountData.get('email');
        if (email != null && email != '') {
            currentAccount.PersonEmail = (String) accountData.get('email');
        }

        String telefone = (String) accountData.get('telefone');
        if (telefone != null) {
            if (telefone.length() == 11 || telefone.length() == 10) {
                currentAccount.DDD_Telefone__c = telefone;
            }
        }

        //Verifica se já existe a conta pessoa fisica
        for (Account acc : [
                SELECT Id, CPF_CNPJ__c, Nome_Completo__c
                FROM Account WHERE CPF_CNPJ__c = :(String) accountData.get('cpf')
                        AND RecordTypeId = :accountRecordTypeId
        ]) {
            currentAccount.Id = acc.Id;
            currentAccount.CPF_CNPJ__c = acc.CPF_CNPJ__c;
            //currentAccount.Nome_Completo__c = acc.Nome_Completo__c;
            currentAccount.Nome_Completo__c = (String) accountData.get('nome_completo');

            // if ((email != null && email != '') || telefone.length() == 11) {
            //   update currentAccount;
            // }
            update currentAccount;
        }

        if (currentAccount.Id == null) {
            currentAccount.CPF_CNPJ__c = (String) accountData.get('cpf');
            currentAccount.Nome_Completo__c = (String) accountData.get('nome_completo');
            currentAccount.RecordTypeId = accountRecordTypeId;

            insert currentAccount;
        }

        return currentAccount;
    }

    public static String validRequiredAccountFields(Map<String, Object> data) {
        List<String> result = new List<String>();
        String cpf = (String) data.get('cpf');
        if (cpf == null || cpf.trim() == '') {
            result.add('cpf');
        }

        String nome = (String) data.get('nome_completo');
        if (nome == null || nome.trim() == '') {
            result.add('nome_completo');
        } else if (nome.trim().split('\\s+').size() < 2) {
            result.add('nome_completo');
        }

        return String.join(result, ',');
    }

    public static RestResponse createResponse(Integer statusCode, Map<String, Object> data, RestResponse res) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('httpStatusCode', statusCode);
        response.put('mensagem', data);
        res.statusCode = statusCode;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        return res;
    }


}