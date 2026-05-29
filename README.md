# Docs bases

Depois pretendo separar em uma pasta reservada para `docs`

## Fluxo action button Documentos Disponíveis

lwc: `availableDocsQuickAction`
handleRecord - configurar os campos habilitados e separa por residencial ou habitacional
`handleRequestDocs` - botão Solicitar, com base no que foi configurado ao iniciar o component ele chama:
`getDuplicatePolicy` - apólices residencial

# Metadados do projeto

## Como Organizar em Subpastas

1. Acesse o diretório padrão de classes: `force-app/main/default/classes/`.
2. Crie as subpastas que desejar diretamente dentro dele.
3. Mova os arquivos `.cls` e `.cls-meta.xml` juntos para a nova pasta.

Sua estrutura de arquivos deve ficar assim:

```notepad
force-app/
└── main/
    └── default/
        └── classes/
            ├── controllers/
            │   ├── AccountController.cls
            │   └── AccountController.cls-meta.xml
            └── handlers/
                ├── AccountTriggerHandler.cls
                └── AccountTriggerHandler.cls-meta.xml
```

### Regras Importantes para Não Errar

- Mantenha os pares juntos: Cada classe `.cls` precisa ficar na mesma pasta que o seu arquivo de metadados `.cls-meta.xml`.
- Nomes únicos: O Salesforce não aceita classes com o mesmo nome na mesma Org. Elas precisam ter nomes diferentes mesmo estando em pastas separadas.
- Deploy e Retrieve: Os comandos `SFDX: Deploy` e `SFDX:` Retrieve via clique direito no arquivo continuam funcionando normalmente.

Para trabalhar com múltiplos pacotes isolados, você deve registrar cada pasta como um package directory no arquivo sfdx-project.json. O Salesforce CLI lerá essas pastas de forma independente, permitindo separar o código por módulos, recursos ou camadas da arquitetura.

1. Estrutura de Pastas do Projeto

Em vez de colocar tudo dentro de force-app, você criará pastas de nível superior na raiz do seu projeto para cada módulo. Veja este exemplo:

```text
meu-projeto-salesforce/
├── force-app-core/             <-- Pacote Base/Core
│   └── main/default/classes/
├── force-app-financeiro/       <-- Pacote Isolado (Financeiro)
│   └── main/default/classes/
├── sfdx-project.json
└── package.json
```

2. 2. Configuração do sfdx-project.json

```json
{
  "packageDirectories": [
    {
      "path": "force-app-core",
      "default": true,
      "package": "CoreModule",
      "versionName": "Versão Core 1.0",
      "versionNumber": "1.0.0.NEXT"
    },
    {
      "path": "force-app-financeiro",
      "default": false,
      "package": "FinanceiroModule",
      "versionName": "Versão Financeiro 1.0",
      "versionNumber": "1.0.0.NEXT",
      "dependencies": [
        {
          "package": "CoreModule"
        }
      ]
    }
  ],
  "name": "meu-projeto-salesforce",
  "namespace": "",
  "sfdcLoginUrl": "https://salesforce.com",
  "sourceApiVersion": "60.0"
}
```

Atributos-Chave Explicados

- path: Caminho da pasta na raiz do projeto.
- default: Apenas um pacote pode ser true. É para onde vão os metadados novos baixados via Org Browser ou comandos genéricos de Retrieve.
- package: Nome do pacote/módulo (obrigatório se você for gerar pacotes desbloqueados - Unlocked Packages).
- dependencies: Define a ordem de build. O módulo FinanceiroModule depende do CoreModule para funcionar e compilar.

Como Criar Novos Componentes Direto no Pacote Certo

Ao usar a Paleta de Comandos (Ctrl + Shift + P) para criar uma classe ou componente, o VS Code perguntará em qual diretório você deseja salvar. Basta selecionar o caminho correspondente (ex: force-app-financeiro/...).

Para fazer o deploy ou retrieve via terminal apontando para um pacote específico, você pode usar:

```bash
# Baixar metadados apenas do módulo financeiro
sf project retrieve start --source-dir force-app-financeiro

# Enviar apenas o módulo financeiro para a Org
sf project deploy start --source-dir force-app-financeiro
```

Ativar o auto format dos códigos

```bash
npm install --save-dev --save-exact prettier prettier-plugin-apex
```

Arquivo `.prettierrc`. Aqui configuro a largura de código e para formatação dos arquivos ``*-meta.xml`.

```json
{
  "trailingComma": "none",
  "plugins": ["prettier-plugin-apex", "@prettier/plugin-xml"],
  "overrides": [
    {
      "files": "**/lwc/**/*.html",
      "options": { "parser": "lwc" }
    },
    {
      "files": "*.{cmp,page,component}",
      "options": { "parser": "html" }
    },
    {
      "files": "*-meta.xml",
      "options": { "parser": "xml", "xmlWhitespaceSensitivity": "ignore" }
    }
  ],
  "printWidth": 120
}
```
