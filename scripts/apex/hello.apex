// Use .apex files to store anonymous Apex.

String link = InstallmentController.getDuplicatePolicy(
  '11032596',
  '87304026',
  '265758497',
  '00077',
  'jeferson.tavares@caixaresidencial.com.br',
  'APOLICE'
);

System.debug('link>>' + link);


12:17:12:291 USER_DEBUG [52]|DEBUG|Erro nos parametros de entrada:
 idepol=0, 
 numCert=87304026, 
 numOper=265758497, 
 numEndosso=0, 
 moduloProduto=, 
 mail=jeferson.tavares@caixaresidencial.com.br, 
 tipoDoc=ENDOSSO, 
 acessoPublico=0