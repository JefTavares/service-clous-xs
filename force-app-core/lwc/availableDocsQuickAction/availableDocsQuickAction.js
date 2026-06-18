import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import getInsuredData from "@salesforce/apex/InstallmentController.getInsuredData";
import getDuplicatePolicy from "@salesforce/apex/InstallmentController.getDuplicatePolicy";
import sendMassificadosDocsByEmail from "@salesforce/apex/InstallmentController.sendMassificadosDocsByEmail";
import confirmAddress from "@salesforce/apex/InstallmentController.confirmAddress";
import loggedUserId from "@salesforce/user/Id";

const FIELDS = [
  "Case.Item__c",
  "Case.Numero_Operador__c",
  "Case.ID_Apolice__c",
  "Case.Apolice__c",
  "Case.Codigo_Modulo_Produto__c",
  "Case.Endosso__c",
  "Case.Classificacao_Negocio__c",
  "Case.Numero_Segurado__c"
];

const USER_FIELDS = ["User.Alias"];

export default class AvailableDocsQuickAction extends LightningElement {
  caseRecord;
  @api recordId;
  @api objectApiName;
  loggedUserId = loggedUserId;
  _isLoading = false;
  _isMassificado = false;
  _isAfinidades = false;
  _afinidadesDocs;
  _afinidadesData;
  _massificadosDocs = [{ id: 1, label: "Apólice", enabled: false, url: "" }];

  _afinidadesSendMethods = [
    { label: "E-mail", value: "email" },
    { label: "Correio", value: "correio" }
  ];

  _afinidadesSendReasons = [
    { value: "3", label: "Documento Perdido" },
    { value: "4", label: "Endereço Errado" },
    { value: "2", label: "Não Recebeu" },
    { value: "1", label: "Outros" }
  ];

  _afinidadesSelectedSendReasons = "3";

  _afinidadesSelectedSendMethod = "email";
  _isEmailFieldVisible = true;
  _isAddressVisible = false;
  _selectedAddress;

  _brazilianStates = [
    { label: "Acre", value: "AC" },
    { label: "Alagoas", value: "AL" },
    { label: "Amapá", value: "AP" },
    { label: "Amazonas", value: "AM" },
    { label: "Bahia", value: "BA" },
    { label: "Ceará", value: "CE" },
    { label: "Distrito Federal", value: "DF" },
    { label: "Espírito Santo", value: "ES" },
    { label: "Goiás", value: "GO" },
    { label: "Maranhão", value: "MA" },
    { label: "Mato Grosso", value: "MT" },
    { label: "Mato Grosso do Sul", value: "MS" },
    { label: "Minas Gerais", value: "MG" },
    { label: "Pará", value: "PA" },
    { label: "Paraíba", value: "PB" },
    { label: "Paraná", value: "PR" },
    { label: "Pernambuco", value: "PE" },
    { label: "Piauí", value: "PI" },
    { label: "Rio de Janeiro", value: "RJ" },
    { label: "Rio Grande do Norte", value: "RN" },
    { label: "Rio Grande do Sul", value: "RS" },
    { label: "Rondônia", value: "RO" },
    { label: "Roraima", value: "RR" },
    { label: "Santa Catarina", value: "SC" },
    { label: "São Paulo", value: "SP" },
    { label: "Sergipe", value: "SE" },
    { label: "Tocantins", value: "TO" }
  ];

  //User Data
  @wire(getRecord, { recordId: "$loggedUserId", fields: USER_FIELDS })
  loggedUser;

  get alias() {
    return this.loggedUser.data.fields.Alias.value;
  }

  //Case Data
  get numeroSegurado() {
    return this.caseRecord.fields.Numero_Segurado__c.value;
  }

  get item() {
    return this.caseRecord.fields.Item__c.value;
  }

  get numeroOperador() {
    return this.caseRecord.fields.Numero_Operador__c.value;
  }

  get idApolice() {
    return this.caseRecord.fields.ID_Apolice__c.value;
  }

  get numeroApolice() {
    return this.caseRecord.fields.Apolice__c.value;
  }

  get codigoModuloProduto() {
    return this.caseRecord.fields.Codigo_Modulo_Produto__c.value;
  }

  get endosso() {
    return this.caseRecord.fields.Endosso__c.value;
  }

  get classificacaoNegocio() {
    return this.caseRecord.fields.Classificacao_Negocio__c.value;
  }

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  handleRecord({ error, data }) {
    if (error) {
      console.log("Error");
      console.log(JSON.stringify(error));
    }

    if (data) {
      this.caseRecord = data;
      console.log("classificação neg: >>>", this.classificacaoNegocio);
      this._isAfinidades = this.classificacaoNegocio === "Afinidades";
      this._isMassificado =
        this.classificacaoNegocio === "Massificados" ||
        this.classificacaoNegocio === "Apolices_Ativas" ||
        this.classificacaoNegocio === "Apolices_com_Endossos" ||
        this.classificacaoNegocio === "Apolices_Encerradas" ||
        this.classificacaoNegocio === "Propostas_Recusadas" ||
        this.classificacaoNegocio === "Propostas_em_Analise";

      let emptyFields = [];
      //Fluxo para Massificado - Apolices do Residencial
      if (this._isMassificado) {
        if (this.item === undefined || this.item === null) {
          emptyFields.push("Item");
        }

        if (this.numeroOperador === undefined || this.numeroOperador === null) {
          emptyFields.push("Número do Operador");
        }

        if (this.idApolice === undefined || this.idApolice === null) {
          emptyFields.push("ID da Apólice");
        }

        if (this.codigoModuloProduto === undefined || this.codigoModuloProduto === null) {
          emptyFields.push("Módulo do Produto");
        }

        if (emptyFields.length > 0) {
          const evt = new ShowToastEvent({
            title: "Documentos Disponíveis",
            message: `Os seguintes campos obrigatórios estão em branco: ${emptyFields.join(", ")}`,
            variant: "warning"
          });

          this.dispatchEvent(evt);
          this._isLoading = false;
        } else {
          console.log("Dados Recuperados: MASSIFICADO");
          console.log(JSON.stringify(data));
        }
      } else if (this._isAfinidades) {
        this._isLoading = true;

        if (this.numeroSegurado) {
          getInsuredData({
            insuredId: this.numeroSegurado
          })
            .then((result) => {
              this._afinidadesData = { ...result };

              if (this._afinidadesData && this._afinidadesData?.documentos) {
                this._afinidadesDocs = this._afinidadesData.documentos.map((elem) => {
                  let tmp = { ...elem };
                  tmp.id = Number(tmp.id ?? tmp.idDocumento);
                  tmp.enabled = false;

                  if (tmp.carteirinha === "N") {
                    tmp.carteirinhaLabel = "Não";
                  } else if (tmp.carteirinha === "S") {
                    tmp.carteirinhaLabel = "Sim";
                  }

                  tmp.eventDescription = this.getAfinidadesEventDescription(tmp.idDocumento);

                  return tmp;
                });

                this._afinidadesData.documentos = this._afinidadesDocs;
              }

              if (this._afinidadesData?.enderecos) {
                this._afinidadesData.enderecos = this._afinidadesData.enderecos.map((elem, index) => {
                  let tmp = { ...elem };
                  tmp.id = index;
                  tmp.label = `Endereço ${index + 1}`;
                  tmp.class = `slds-form address-section-${index}`;
                  return tmp;
                });
              }

              this._isLoading = false;
            })
            .catch((errorCatch) => {
              console.log("Error");
              console.log(JSON.stringify(errorCatch));
              this._isLoading = false;
            });
        } else {
          this.dispatchEvent(new CloseActionScreenEvent());
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Documentos Disponíveis",
              message: `ID do Segurado vazio.`,
              variant: "warning"
            })
          );
        }
      }
    }
  }

  handleMassificadosDocSelection(event) {
    const docId = Number(event.target.dataset.id);
    const doc = this._massificadosDocs.find((item) => item.id === docId);

    if (doc) {
      doc.enabled = event.target.checked;
    }
  }

  get getDocsMassificadosSelecionados() {
    return this._massificadosDocs.filter((item) => item.enabled).map((item) => item.label) || null;
  }

  handleAfinidadesDocSelection(event) {
    const docId = Number(event.currentTarget?.dataset?.id ?? event.target?.dataset?.id);
    const doc = this._afinidadesDocs.find((item) => Number(item.id ?? item.idDocumento) === docId);

    if (doc) {
      doc.enabled = event.target.checked;
    }
  }

  get getDocsAfinidadesSelecionados() {
    const selectedDocs = (this._afinidadesDocs || []).filter((item) => item.enabled);
    return selectedDocs;
  }

  handleRequestDocs() {
    let emailAddress = this.refs.emailAddress;

    if (this._isMassificado) {
      if (!emailAddress.checkValidity() || emailAddress.value.length === 0) {
        const evt = new ShowToastEvent({
          title: "Documentos Disponíveis",
          message: `Informe um e-mail válido para continuar.`,
          variant: "warning"
        });

        this.dispatchEvent(evt);
      } else {
        if (this.getDocsMassificadosSelecionados.length > 0) {
          this._massificadosDocs.forEach((doc) => {
            if (doc.enabled && doc.label === "Apólice") {
              this._isLoading = true;
              let tipoDoc = "APOLICE";

              console.log("this.idApolice", this.idApolice);
              console.log("this.endosso", this.endosso);
              console.log("this.item", this.item);
              console.log("this.numeroOperador", this.numeroOperador);
              console.log("this.codigoModuloProduto", this.codigoModuloProduto);
              console.log("emailAddress.value", emailAddress.value);
              console.log("tipoDoc", tipoDoc);

              // if (this.endosso !== 0 && this.endosso !== "" && this.endosso !== null && this.endosso !== undefined) {
              //   tipoDoc = "ENDOSSO";
              //   idepol = this.endosso;
              // }

              let codModProd = String(this.codigoModuloProduto);
              console.log("codModProd", codModProd);

              getDuplicatePolicy({
                idepol: this.idApolice,
                numCert: this.item,
                numOper: this.numeroOperador,
                moduloProduto: codModProd,
                mail: emailAddress.value,
                tipoDoc: tipoDoc
              })
                .then((result) => {
                  if (result) {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Documentos Disponíveis",
                        message: "Documento solicitado e enviado para o e-mail com sucesso!",
                        variant: "success"
                      })
                    );
                    doc.url = result;
                  } else {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Documentos Disponíveis",
                        message: "Falha ao buscar documento da apólice. Sistema externo indisponível no momento.",
                        variant: "warning",
                        mode: "sticky"
                      })
                    );
                  }

                  this._isLoading = false;
                })
                .catch((error) => {
                  console.log("Error");
                  console.log(JSON.stringify(error));
                  this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Erro ao consultar documento",
                      message: "Falha ao buscar documento da apólice. Sistema externo indisponível no momento.",
                      variant: "warning",
                      mode: "sticky"
                    })
                  );
                  this._isLoading = false;
                });
            }
          });
        } else {
          const evt = new ShowToastEvent({
            title: "Documentos Disponíveis",
            message: `Selecione ao menos um documento.`,
            variant: "warning"
          });

          this.dispatchEvent(evt);
        }
      }
    } else if (this._isAfinidades) {
      if (this._afinidadesSelectedSendMethod === "email") {
        if (!emailAddress.checkValidity() || emailAddress.value.length === 0) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Documentos Disponíveis",
              message: `Informe um e-mail válido para continuar.`,
              variant: "warning"
            })
          );
        } else if (this.getDocsAfinidadesSelecionados.length === 0) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Documentos Disponíveis",
              message: `Selecione ao menos um documento.`,
              variant: "warning"
            })
          );
        } else {
          //Script to Send E-mail
          this._isLoading = true;

          let docsHtml = this.getDocsAfinidadesSelecionados.map((elem) => {
            return `<li><strong>${elem.nomeKit}</strong> - ${elem.url}</li>`;
          });

          let htmlBody = `<p>Documentos solicitados:</p><ul>${docsHtml.join("\n")}</ul>`;
          sendMassificadosDocsByEmail({
            email: emailAddress.value,
            subject: "Documentos Segurado",
            body: htmlBody,
            displayName: "Atendimento Caixa Residencial"
          })
            .then((emailSendResult) => {
              if (emailSendResult) {
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Documentos Disponíveis",
                    message: `E-mail enviado com sucesso!`,
                    variant: "success"
                  })
                );
              } else {
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Documentos Disponíveis",
                    message: `Erro ao enviar o e-mail.`,
                    variant: "warning"
                  })
                );
              }

              this._isLoading = false;
            })
            .catch((emailSendError) => {
              console.log("Error");
              console.log(JSON.stringify(emailSendError));
              this._isLoading = false;
            });
        }
      } else if (this._afinidadesSelectedSendMethod === "correio") {
        this._isLoading = true;

        if (!this._selectedAddress) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Documentos Disponíveis",
              message: `Selecione ao menos um endereço.`,
              variant: "warning"
            })
          );

          this._isLoading = false;
        } else if (this.getDocsAfinidadesSelecionados.length === 0) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Documentos Disponíveis",
              message: `Selecione ao menos um documento.`,
              variant: "warning"
            })
          );
          this._isLoading = false;
        } else {
          let requests = this.getDocsAfinidadesSelecionados.map((doc) => {
            let confirmacaoRequest = {};

            confirmacaoRequest = this._selectedAddress;
            confirmacaoRequest.destinatario = "SEGURADO";
            confirmacaoRequest.email = "";
            confirmacaoRequest.localInterno = "";
            confirmacaoRequest.meioEnvio = "CORREIO";
            confirmacaoRequest.responsavel = "";
            confirmacaoRequest.somenteCartao = doc.carteirinha;
            confirmacaoRequest.motivoSegundaVia = this._afinidadesSelectedSendReasons;
            confirmacaoRequest.usuarioSolicitacao = this.alias;
            confirmacaoRequest.idKit = Number(doc.id);
            confirmacaoRequest.idSegurado = Number(this.numeroSegurado);
            confirmacaoRequest.origemChamada = "CONTACT_CENTER";

            return confirmacaoRequest;
          });

          requests.forEach((request) => {
            confirmAddress({
              addressToConfirm: JSON.stringify(request)
            })
              .then((result) => {
                this._isLoading = false;
                //let response = {"return_x":{"inconsistencias":[{"mensagem":"ERRO XPTO","campo":"ABC"}, {"mensagem":"ERRO ABC","campo":"DEF"}],"erro":true}};
                let response = result;

                if (response && response?.return_x?.erro) {
                  let errorMessage = response?.return_x?.inconsistencias.map((elem) => {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Documentos Disponíveis",
                        message: `O campo ${elem.campo} possui um valor inválido. Detalhes do erro: ${elem.mensagem}`,
                        variant: "warning",
                        mode: "sticky"
                      })
                    );

                    return `O campo ${elem.campo} possui um valor inválido. Detalhes do erro: ${elem.mensagem}`;
                  });
                  console.log(errorMessage);
                } else if (response && !response?.return_x?.erro) {
                  this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Documentos Disponíveis",
                      message: `Pedido de envio concluído com sucesso.`,
                      variant: "success"
                    })
                  );
                }
              })
              .catch((error) => {
                this._isLoading = false;
                console.log(JSON.stringify(error));
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Documentos Disponíveis",
                    message: `Erro ao solicitar envio por correios. Tente novamente.`,
                    variant: "error"
                  })
                );
              });
          });
        }
      }
    }
  }

  handleSelectAddress(event) {
    let selectedAddress = event.target.dataset.id;
    let addressSection = this.template.querySelector(`.address-section-${selectedAddress}`);

    let allSelectAddressButtons = this.template.querySelectorAll(".select-address-button");
    allSelectAddressButtons.forEach((customBtn) => {
      customBtn.innerHTML =
        '<button class="slds-button slds-button_brand" aria-disabled="false" type="button">Selecionar</button>';
    });

    event.currentTarget.innerHTML =
      '<button class="slds-button slds-button_brand" aria-disabled="false" type="button">Selecionado</button>';

    let logradouro = addressSection.querySelector(".logradouro").value;
    let complemento = addressSection.querySelector(".complemento").value;
    let cidade = addressSection.querySelector(".cidade").value;
    let bairro = addressSection.querySelector(".bairro").value;
    let numero = addressSection.querySelector(".numero").value;
    let cep = addressSection.querySelector(".cep").value;
    let pais = addressSection.querySelector(".pais").value;
    let estado = addressSection.querySelector(".estado").value;

    this._selectedAddress = {};

    if (
      this._afinidadesData.enderecos[selectedAddress].logradouro !== logradouro ||
      this._afinidadesData.enderecos[selectedAddress].complemento !== complemento ||
      this._afinidadesData.enderecos[selectedAddress].cidade !== cidade ||
      this._afinidadesData.enderecos[selectedAddress].bairro !== bairro ||
      this._afinidadesData.enderecos[selectedAddress].numero !== numero ||
      this._afinidadesData.enderecos[selectedAddress].cep !== cep ||
      this._afinidadesData.enderecos[selectedAddress].pais !== pais ||
      this._afinidadesData.enderecos[selectedAddress].estado !== estado
    ) {
      this._selectedAddress.enderecoAlterado = "S";
    } else {
      this._selectedAddress.enderecoAlterado = "N";
    }

    this._selectedAddress.bairro = bairro;
    this._selectedAddress.cep = cep;
    this._selectedAddress.cidade = cidade;
    this._selectedAddress.complemento = complemento;
    this._selectedAddress.endereco = logradouro;
    this._selectedAddress.estado = estado;
    this._selectedAddress.numero = numero;
    this._selectedAddress.pais = pais;
  }

  handleAfinidadesSendMethodChange(event) {
    this._afinidadesSelectedSendMethod = event.detail.value;
    this._isEmailFieldVisible = this._afinidadesSelectedSendMethod === "email";
    this._isAddressVisible = this._afinidadesSelectedSendMethod === "correio";
  }

  handleAfinidadesSendReasonsChange(event) {
    this._afinidadesSelectedSendReasons = event.detail.value;
  }

  getAfinidadesEventDescription(eventCode) {
    switch (eventCode) {
      case "0":
        return "Legado";
      case "1":
        return "Adesão ao Seguro/Primeiro pagamento";
      case "2":
        return "Movimentações Coberturas/Servico";
      case "3":
        return "Renovação do Seguro";
      case "4":
        return "Cancelamento do Seguro";
      default:
        return "";
    }
  }
}
