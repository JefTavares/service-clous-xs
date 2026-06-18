/**
 * Created by EX300265 on 24/01/2025.
 */

@IsTest
public class BackofficeApisUtilsTest {

    @IsTest
    public static void testGetQueue() {
        Test.startTest();
        Id result = BackofficeApisUtils.getQueue('SAC 2º Nível');
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    public static void testAccountHandler() {
        Test.startTest();
        Map<String, Object> accountData = new Map<String, Object>();
        accountData.put('cpf', '32729267808');
        accountData.put('nome_completo', 'José silva');
        Account result = BackofficeApisUtils.accountHandler(accountData);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    public static void testValidRequiredAccountFields() {
        Test.startTest();
        Map<String, Object> data = new Map<String, Object>();
        String result = BackofficeApisUtils.validRequiredAccountFields(data);
        Test.stopTest();
        System.assertEquals('cpf,nome_completo', result);
    }

    @IsTest
    public static void testCreateResponse() {
        Test.startTest();
        RestResponse res = new RestResponse();
        RestResponse result = BackofficeApisUtils.createResponse(200, new Map<String, Object>(), res);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

}