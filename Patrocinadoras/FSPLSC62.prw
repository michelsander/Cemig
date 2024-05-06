#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'

#DEFINE MVC_TITLE "Transmissão de Lotes de Cobrança"
#DEFINE MVC_ALIAS "PB0"
#DEFINE MVC_VIEWDEF_NAME "VIEWDEF.FSPLSC62"

/*/{Protheus.doc} FSPLSC62
Transmissão de Arquivos de Lote de Cobrança ás Patrocinadoras    

@author  Michel Sander 
@since   27/11/2022
@version P12
/*/

User function FSPLSC62()

   PRIVATE oBrwBDC

   oBrwBDC := FWmBrowse():New()
   oBrwBDC:SetAlias( 'BDC' )
   oBrwBDC:SetDescription( 'Transmissão de Lotes de Cobrança' )
   oBrwBDC:SetMenuDef( "FSPLSC62" )
	oBrwBDC:DisableReport()
   oBrwBDC:DisableDetails()
   oBrwBDC:Activate()

Return 

/*/{Protheus.doc} MenuDef
Monta o menu

@author  Michel Sander 
@since   27/11/2022
@version P12
/*/

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Sincronizar' 		Action MVC_VIEWDEF_NAME 	OPERATION 2 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Define a model

@author  Michel Sander 
@since   27/11/2022
@version P12
/*/

Static Function ModelDef()

	LOCAL oModel      As OBJECT
	LOCAL oStruBDC   As OBJECT
	LOCAL oStruPB0    As OBJECT
   Local bPre := {|oFieldModel, cAction, cIDField, xValue| ValidPre(oFieldModel, cAction, cIDField, xValue)}
	
	// Estrutura do cabeçalho
	oStruBDC := FWFormStruct(1,"BDC")
	oStruPB0 := FWFormStruct(1,"PB0")

   oModel := MPFormModel():New("MFSPLSC62")

	//Adiciona campo da legenda de usuário
	oStruPB0:AddField( ;
	'  ' , ; 				// [01] C Titulo do campo
	'  ' , ; 				// [02] C ToolTip do campo
	'PB0_LEGEND' , ;     // [03] C identificador (ID) do Field
	'C' , ;              // [04] C Tipo do campo
	50 , ;               // [05] N Tamanho do campo
	0 , ;                // [06] N Decimal do campo
	NIL , ;              // [07] B Code-block de validação do campo
	NIL , ;              // [08] B Code-block de validação When do campo
	NIL , ;              // [09] A Lista de valores permitido do campo
	NIL , ;              // [10] L Indica se o campo tem preenchimento obrigatório
	{ || LegPar(1) } , ; // [11] B Code-block de inicializacao do campo
	NIL , ;              // [12] L Indica se trata de um campo chave
	.F. , ;              // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                // [14] L Indica se o campo é virtual

	oStruPB0:AddField( ;
	'Status' , ; 			// [01] C Titulo do campo
	'Status' , ; 			// [02] C ToolTip do campo
	'PB0_DESLEG' , ;     // [03] C identificador (ID) do Field
	'C' , ;              // [04] C Tipo do campo
	20 , ;               // [05] N Tamanho do campo
	0 , ;                // [06] N Decimal do campo
	NIL , ;              // [07] B Code-block de validação do campo
	NIL , ;              // [08] B Code-block de validação When do campo
	NIL , ;              // [09] A Lista de valores permitido do campo
	NIL , ;              // [10] L Indica se o campo tem preenchimento obrigatório
	{ || LegPar(2) } , ; // [11] B Code-block de inicializacao do campo
	NIL , ;              // [12] L Indica se trata de um campo chave
	.F. , ;              // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                // [14] L Indica se o campo é virtual

	oModel:addFields("BDCMASTER", , oStruBDC, bpre)
	oModel:addGrid("PB0DETAIL", "BDCMASTER", oStruPB0)
	oModel:GetModel("PB0DETAIL"):SetUniqueLine({"PB0_CODIGO","PB0_ITEM"})
	oModel:SetRelation("PB0DETAIL", { {"PB0_FILIAL",'FwxFilial("PB0")'}, {"PB0_CODIGO","BDC_NUMERO"  } }, PB0->(IndexKey(1)))
   oModel:GetModel("PB0DETAIL"):SetDescription(MVC_TITLE)
   oModel:SetPrimaryKey({'BDC_FILIAL', 'BDC_CODIGO'})

Return oModel

/*/{Protheus.doc} ViewDef
Visão dos Dados

@return 	oView - Objeto da view, interface
@author 	Michel Sander
@since 	21/09/2022
@version 1.0
/*/

Static Function viewDef()

	LOCAL oView As OBJECT
	LOCAL oModel As OBJECT
	LOCAL oStrBDC As OBJECT
	LOCAL oStrPB0 As OBJECT

	oModel := FWLoadModel("FSPLSC62")

	//Estrutura de Grid
	oStrBDC := FWFormStruct(2, "BDC" )
   oStrPB0 := FWFormStruct(2, "PB0" )

   oView := FwFormView():New()
	oView:SetModel(oModel)
	oView:addField("CAB", oStrBDC, "BDCMASTER")
	oView:AddGrid("ITENS_PB0", oStrPB0, "PB0DETAIL")

	oStrPB0:RemoveField("PB0_CANAL")
	oStrPB0:AddField( ;	// Ord. Tipo Desc.
	'PB0_LEGEND'    , ;   	// [01]  C   Nome do Campo
	"00"            , ;     // [02]  C   Ordem
	'  '         , ;     // [03]  C   Titulo do campo
	'  '         , ;     // [04]  C   Descricao do campo
	{ '  ' }     , ;     // [05]  A   Array com Help
	'C'             , ;     // [06]  C   Tipo do campo
	'@BMP'          , ;     // [07]  C   Picture
	NIL             , ;     // [08]  B   Bloco de Picture Var
	''              , ;     // [09]  C   Consulta F3
	.F.             , ;     // [10]  L   Indica se o campo é alteravel
	NIL             , ;     // [11]  C   Pasta do campo
	NIL             , ;     // [12]  C   Agrupamento do campo
	NIL				, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL             , ;     // [15]  C   Inicializador de Browse
	.T.             , ;     // [16]  L   Indica se o campo é virtual
	NIL             , ;     // [17]  C   Picture Variavel
	NIL             )       // [18]  L   Indica pulo de linha após o campo

	oStrPB0:AddField( ;	// Ord. Tipo Desc.
	'PB0_DESLEG'    , ;   	// [01]  C   Nome do Campo
	"01"            , ;     // [02]  C   Ordem
	'Status'         , ;     // [03]  C   Titulo do campo
	'Status'         , ;     // [04]  C   Descricao do campo
	{ 'Status' }     , ;     // [05]  A   Array com Help
	'C'             , ;     // [06]  C   Tipo do campo
	NIL 	          , ;     // [07]  C   Picture
	NIL             , ;     // [08]  B   Bloco de Picture Var
	''              , ;     // [09]  C   Consulta F3
	.F.             , ;     // [10]  L   Indica se o campo é alteravel
	NIL             , ;     // [11]  C   Pasta do campo
	NIL             , ;     // [12]  C   Agrupamento do campo
	NIL				, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL             , ;     // [15]  C   Inicializador de Browse
	.T.             , ;     // [16]  L   Indica se o campo é virtual
	NIL             , ;     // [17]  C   Picture Variavel
	NIL             )       // [18]  L   Indica pulo de linha após o campo

   oView:createHorizontalBox("BOX_CABEC", 35 )
	oView:createHorizontalBox("BOX_ITENS_PB0", 65 )

   oView:setOwnerView("CAB", "BOX_CABEC" )
	oView:setOwnerView("ITENS_PB0", "BOX_ITENS_PB0")
	oView:EnableTitleView('ITENS_PB0')
	oView:SetDescription( MVC_TITLE )

Return oView

/*/{Protheus.doc} VldLine
Função para validação da linha do grid

@author 	Michel Sander
@since 	21/09/2022
@version 1.0
/*/

Static Function VldLine(oModel)

	LOCAL lVldGrid := .T.

Return ( lVldGrid )

/*/{Protheus.doc} ValidPre
//TODO Pre validaç?o de model
@author Michel Sander
@since 21/06/2018
@version undefined
@type function
/*/

Static Function ValidPre(oFieldModel, cAction, cIDField, xValue)
	
   Local lRet := .T.

Return lRet

/*/{Protheus.doc} MFSPLSC62
Ponto de Entrada do Modelo MVC da rotina principal FSPLSC62

@author 	Michel Sander
@since 	08/12/2022
@version 
@type 	function
/*/

User Function MFSPLSC62()

	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ''
	Local cIdPonto := ''
	Local cIdModel := ''
	
	If aParam <> NIL
		oObj 		:= aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		If cIdPonto == 'BUTTONBAR'
			xRet := {;
						{'Gera Arq. Financeiro', 	'FINANCEIRO', 			{ || U_FSPLSPDU() } 	},;
						{'Gera Arq. AutoPatroc.', 	'AUTOPATROCINADO', 	{ || U_FSPLSPDV() } 	},;
						{'Transmissão', 				'TRANSMISSAO', 		{ || U_FSPLSPF5() }	},; 
						{'Recepção', 					'RECEPCAO', 			{ || U_FSPLSPF6() }	},;
						{'Download', 					'DOWNLOAD', 			{ || U_FSPLSPF8(.T.) } },;
						{'Financeiro', 				'FINANCEIRO', 			{ || U_FSPLSPF9(.T.) } },;
						{'Itens do Lote Cobrança',	'ITENS',		 			{ || U_FSPLSPG2() }  },;
						{'Excluir Arquivo',			'EXCLUSAO', 			{ || U_FSPLSPEF() }  } }
		EndIf
	EndIf 

Return xRet

/*/{Protheus.doc} LegPar
Cria a legenda do grid

@author 	Michel Sander
@since 	04/07/2019
@version 
@return 
@param oModel, object, Modelo de dados
@type function
/*/

Static Function LegPAR(cParamIXB)

	LOCAL cLegenda  := ""

	If PB0->PB0_CANAL == 'E'
		If cParamIXB == 1
			cLegenda := 'BR_VERDE'
		else
			cLegenda := "Enviado"
		EndIf
	ElseIf PB0->PB0_CANAL == 'A'
		If cParamIXB == 1
			cLegenda := 'BR_AMARELO'
		else
			cLegenda := "Aguardando Envio"
		EndIf
	ElseIf PB0->PB0_CANAL == 'R'
		If cParamIXB == 1
			cLegenda := 'BR_AZUL'
		else
			cLegenda := "Retornado"
		EndIf
	ElseIf PB0->PB0_CANAL == 'G'
		If cParamIXB == 1
			cLegenda := 'BR_LARANJA'
		else
			cLegenda := "Aguardando Baixa"
		EndIf
	ElseIf PB0->PB0_CANAL == 'B'
		If cParamIXB == 1
			cLegenda := 'BR_VERMELHO'
		else
			cLegenda := "Baixado Financeiro"
		EndIf
	EndIf 

Return ( cLegenda )
