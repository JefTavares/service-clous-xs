@IsTest
public class CaseRestResourceTest {
    @IsTest
    public static void testCreateCase() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/api/back-office/caso';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{\n' +
                '    "data": {\n' +
                '        "conta": {\n' +
                '            "cpf": "10253133483",\n' +
                '            "nome_completo": "Emanuele Mayara Pinheiro",\n' +
                '            "email": "pinheiromanu.u@teste.com",\n' +
                '            "telefone": "84988177051"\n' +
                '        },\n' +
                '        "caso": {\n' +
                '            "servico": "Cancelamento",\n' +
                '            "motivo": "A pedido do segurado", \n' +
                '            "assunto": "Cancelamento de Renovação",\n' +
                '            "meio_de_contato": "Optin automatizada",\n' +
                '            "canal": "Optin automatizada",\n' +
                '            "origem_do_caso": "Segurado",            \n' +
                '            "descricao": "Proposta de renovação Opt-in automatizada NÃO renovada, conforme solicitação de cancelamento realizada pelo cliente via autoatendimento.",\n' +
                '            "status": "Não Retido",\n' +
                '            "produto": "Residencial",\n' +
                '            "local_de_risco": "AREA ESPECIAL 2, MOD C/D -  R. BELVEDERE",\n' +
                '            "dt_ini_vig": "2024-05-04", \n' +
                '            "dt_fim_vig": "2025-05-04",\n' +
                '            "negocio": "76289146", \n' +
                '            "apolice": "3056211", \n' +
                '            "item": "79274794", \n' +
                '            "endosso": "0",\n' +
                '            "status_negocio": "REN",\n' +
                '            "ramo": "140",\n' +
                '            "existe_sinistro": true,' +
                '             "n_aviso": 22345' +
                '        }\n' +
                '    }\n' +
                '}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CaseRestResource.createCasePosVendas();
        Test.stopTest();

        System.assertEquals(201, res.statusCode);
    }

    @IsTest
    public static void testCreateCaseError() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/api/back-office/caso';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{\n' +
                '    "data": {\n' +
                '        "conta": {\n' +
                '            "cpf": "1025313348",\n' +
                '            "nome_completo": "Emanuele Mayara Pinheiro",\n' +
                '            "email": "pinheiromanu.u@teste.com",\n' +
                '            "telefone": "84988177051"\n' +
                '        },\n' +
                '        "caso": {\n' +
                '            "servico": "Cancelamento",\n' +
                '            "motivo": "A pedido do segurado", \n' +
                '            "assunto": "Cancelamento de Renovação",\n' +
                '            "meio_de_contato": "Optin automatizada",\n' +
                '            "canal": "Optin automatizada",\n' +
                '            "origem_do_caso": "Segurado",            \n' +
                '            "descricao": "Proposta de renovação Opt-in automatizada NÃO renovada, conforme solicitação de cancelamento realizada pelo cliente via autoatendimento.",\n' +
                '            "status": "Não Retido",\n' +
                '            "produto": "Residencial",\n' +
                '            "local_de_risco": "AREA ESPECIAL 2, MOD C/D -  R. BELVEDERE",\n' +
                '            "dt_ini_vig": "2024-05-04", \n' +
                '            "dt_fim_vig": "2025-05-04",\n' +
                '            "negocio": "76289146", \n' +
                '            "apolice": "3056211", \n' +
                '            "item": "79274794", \n' +
                '            "endosso": "0",\n' +
                '            "status_negocio": "REN",\n' +
                '            "ramo": "140",\n' +
                '            "existe_sinistro": true,' +
                '             "n_aviso": 22345' +
                '        }\n' +
                '    }\n' +
                '}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CaseRestResource.createCasePosVendas();
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
    }
}