#INCLUDE "protheus.ch"
#INCLUDE 'FwMvcDef.ch'

#DEFINE MVC_TITLE "Rubricas Relacionadas"
#DEFINE MVC_ALIAS "PB1"

/*/{Protheus.doc} FPLSC69
Cadastro de Rubricas Relacionadas 

@author 		Michel Sander
@since 		05/09/2022
@version 	12.1.33 
/*/    

User function FSPLSC69()

	LOCAL oBrowse

	PRIVATE aRotina 	:= {}
	PRIVATE cCadastro := "Cadastro de Rubricas Relacionadas"

	oBrowse := FWMBrowse():New()
   oBrowse:SetDescription( "Rubricas Relacionadas" )
   oBrowse:SetAlias( "PB1" )
   oBrowse:SetMenuDef( "FSPLSC69" )
   oBrowse:SetLocate()
	oBrowse:Activate()

Return NIL

Static Function Menudef()

   ADD OPTION aRotina Title 'Pesquisar'   Action 'PesqBrw'			 	OPERATION 1 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  Action "VIEWDEF.FSPLSC69" 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     Action "VIEWDEF.FSPLSC69"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     Action "VIEWDEF.FSPLSC69" 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     Action "VIEWDEF.FSPLSC69" 	OPERATION 5 ACCESS 0

Return 

/*/{Protheus.doc} ModelDef
Montagem do modelo dados para MVC

@return 	oModel - Objeto do modelo de dados
@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function ModelDef()

	LOCAL oModel As OBJECT
	LOCAL oStrField As OBJECT
	LOCAL oStrPB1 As OBJECT
	LOCAL oStrPB6 As OBJECT

	// Estrutura Fake de Field
	oStrField := FWFormModelStruct():New()
	oStrField:addTable("", {"C_STRING1"}, MVC_TITLE, {|| ""})
	oStrField:addField("Patrocinadora", "Campo de texto", "C_STRING1", "C", 80)

	//Estrutura de Grid, alias Real presente no dicionário de dados
	oStrPB1 := FWFormStruct(1, MVC_ALIAS)
	oStrPB6 := FWFormStruct(1, "PB6")
	oModel := MPFormModel():New("MIDMAIN")
	oModel:addFields("CABID", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oMdl| LoadHidFld(oMdl)})
	oModel:addGrid("PB1DETAIL", "CABID", oStrPB1, /*bLinePre*/, {|oMdl| VldLine(oMdl)}/*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| LoadPB1(oMdl)})
	oModel:addGrid("PB6DETAIL", "CABID", oStrPB6, /*bLinePre*/, {|oMdl| VldLine2(oMdl)}/*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| LoadPB6(oMdl)})
   oModel:GetModel("PB1DETAIL"):SetUniqueLine({"PB1_CODIGO","PB1_CODEMP","PB1_NUMCON","PB1_VERCON","PB1_SUBCON","PB1_VERSUB","PB1_CODTIP"})
	oModel:GetModel('PB1DETAIL'):SetDescription('Rubricas Por Valor')    
	oModel:GetModel('PB1DETAIL'):SetOptional(.T.)	
	oModel:GetModel("PB6DETAIL"):SetUniqueLine({"PB6_CODIGO","PB6_CODEMP","PB6_NUMCON","PB6_VERCON","PB6_SUBCON","PB6_VERSUB","PB6_FXAINI","PB6_FXAFIN","PB6_CODTIP"})
	oModel:GetModel('PB6DETAIL'):SetDescription('Rubricas Por Faixa Etária')    
	oModel:GetModel('PB6DETAIL'):SetOptional(.T.)	
	oModel:setDescription(MVC_TITLE)
	
	oStrPB1:SetProperty("PB1_CODIGO",MODEL_FIELD_INIT, { || BQC->BQC_CODIGO })
   oStrPB1:SetProperty("PB1_CODIGO",MODEL_FIELD_WHEN, { || .F. })	
	oStrPB1:SetProperty("PB1_CODEMP",MODEL_FIELD_INIT, { || BQC->BQC_CODEMP })
   oStrPB1:SetProperty("PB1_CODEMP",MODEL_FIELD_WHEN, { || .F. })	
   oStrPB1:SetProperty("PB1_NUMCON",MODEL_FIELD_INIT, { || BQC->BQC_NUMCON })
   oStrPB1:SetProperty("PB1_NUMCON",MODEL_FIELD_WHEN, { || .F. })	
	oStrPB1:SetProperty("PB1_VERCON",MODEL_FIELD_INIT, { || BQC->BQC_VERCON })
   oStrPB1:SetProperty("PB1_VERCON",MODEL_FIELD_WHEN, { || .F. })	
	oStrPB1:SetProperty("PB1_SUBCON",MODEL_FIELD_INIT, { || BQC->BQC_SUBCON })
   oStrPB1:SetProperty("PB1_SUBCON",MODEL_FIELD_WHEN, { || .F. })		
   oStrPB1:SetProperty('PB1_VERSUB',MODEL_FIELD_INIT, { || BQC->BQC_VERSUB })
   oStrPB1:SetProperty("PB1_VERSUB",MODEL_FIELD_WHEN, { || .F. })	
	oStrPB1:SetProperty("PB1_DESEMP",MODEL_FIELD_INIT, { || BQC->BQC_DESCRI })
	oStrPB1:SetProperty("PB1_DESTIP",MODEL_FIELD_INIT, { || If(INCLUI,"",Posicione("BFQ",1,xFIlial("BFQ")+SubStr(PB1->PB1_CODIGO,1,4)+PB1->PB1_CODTIP,"BFQ_DESCRI")) })	
   
	oStrPB6:SetProperty("PB6_CODIGO",MODEL_FIELD_INIT, { || BQC->BQC_CODIGO })
   oStrPB6:SetProperty("PB6_CODIGO",MODEL_FIELD_WHEN, { || .F. })	
	oStrPB6:SetProperty("PB6_CODEMP",MODEL_FIELD_INIT, { || BQC->BQC_CODEMP })
   oStrPB6:SetProperty("PB6_CODEMP",MODEL_FIELD_WHEN, { || .F. })	
   oStrPB6:SetProperty("PB6_NUMCON",MODEL_FIELD_INIT, { || BQC->BQC_NUMCON })
   oStrPB6:SetProperty("PB6_NUMCON",MODEL_FIELD_WHEN, { || .F. })	
	oStrPB6:SetProperty("PB6_VERCON",MODEL_FIELD_INIT, { || BQC->BQC_VERCON })
   oStrPB6:SetProperty("PB6_VERCON",MODEL_FIELD_WHEN, { || .F. })	
	oStrPB6:SetProperty("PB6_SUBCON",MODEL_FIELD_INIT, { || BQC->BQC_SUBCON })
   oStrPB6:SetProperty("PB6_SUBCON",MODEL_FIELD_WHEN, { || .F. })		
   oStrPB6:SetProperty('PB6_VERSUB',MODEL_FIELD_INIT, { || BQC->BQC_VERSUB })
   oStrPB6:SetProperty("PB6_VERSUB",MODEL_FIELD_WHEN, { || .F. })	
	oStrPB6:SetProperty("PB6_DESEMP",MODEL_FIELD_INIT, { || BQC->BQC_DESCRI })
	oStrPB6:SetProperty("PB6_DESTIP",MODEL_FIELD_INIT, { || If(INCLUI,"",Posicione("BFQ",1,xFIlial("BFQ")+SubStr(PB6->PB6_CODIGO,1,4)+PB6->PB6_CODTIP,"BFQ_DESCRI")) })	
	oStrPB6:SetProperty("PB6_FXAINI",MODEL_FIELD_INIT, { || If(INCLUI,0,PB6->PB6_FXAINI) })
	oStrPB6:SetProperty("PB6_FXAFIN",MODEL_FIELD_INIT, { || If(INCLUI,999,PB6->PB6_FXAFIN) })

	// É necessário que haja alguma alteração na estrutura Field
	oModel:setActivate({ |oModel| OnActivate(oModel)})

Return oModel

/*/{Protheus.doc} ViewDef
Visão dos Dados

@return 	oView - Objeto da view, interface
@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function viewDef()

	LOCAL oView As OBJECT
	LOCAL oModel As OBJECT
	LOCAL oStrCab As OBJECT
	LOCAL oStrPB1 As OBJECT
	LOCAL oStrPB6 As OBJECT

	BFQ->(dbSetOrder(1))

	oModel := FWLoadModel("FSPLSC69")
	oStrCab := FWFormViewStruct():New()
	
	oStrCab:addField("C_STRING1", "01" , "Patrocinadora", "Campo de texto", , "C" )
	oStrCab:SetProperty('C_STRING1',MVC_VIEW_CANCHANGE, .F. )

	//Estrutura de Grid
	oStrPB1 := FWFormStruct(2, MVC_ALIAS )
	oStrPB6 := FWFormStruct(2, "PB6" )
	
	oView := FwFormView():New()
	oView:setModel(oModel)
	oView:addField("CAB", oStrCab, "CABID")
	oView:addGrid("VIEW_PB1", oStrPB1, "PB1DETAIL")
	oView:addGrid("VIEW_PB6", oStrPB6, "PB6DETAIL")
	oView:EnableTitleView('VIEW_PB1','Rubricas Por Valor')
	oView:EnableTitleView('VIEW_PB6','Rubricas Por Faixa Etária')

	oStrPB1:SetProperty('PB1_DESEMP',MVC_VIEW_INIBROW ,BQC->BQC_DESCRI)
	oStrPB6:SetProperty('PB6_DESEMP',MVC_VIEW_INIBROW ,BQC->BQC_DESCRI)

   oView:createHorizontalBox("TOHIDE", 10 )
   oView:createHorizontalBox("TOSHOW", 45 )
   oView:createHorizontalBox("TOFAIXA", 45 )	
	oView:setOwnerView("CAB", "TOHIDE" )
	oView:setOwnerView("VIEW_PB1", "TOSHOW")
	oView:setOwnerView("VIEW_PB6", "TOFAIXA")	
	oView:setDescription( MVC_TITLE )

Return oView

/*/{Protheus.doc} OnActivate
Função estática para o activate do model

@param 	oModel - Objeto do modelo de dados
@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function OnActivate(oModel)

	If oModel:GetOperation() == 1 .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE .Or. oModel:GetOperation() == 2
		Return 
	EndIf 
	
	FwFldPut("C_STRING1", BQC->BQC_DESCRI , /*nLinha*/, oModel)
	
Return

/*/{Protheus.doc} LoadPB1
Função estática para efetuar o load dos dados do grid

@return 	aData - Array com os dados para exibição no grid
@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function LoadPB1(oModel)

	LOCAL aData  	 := {}
	LOCAL cAliasPB1 := GetNextAlias()
	LOCAL cWorkArea := Alias()

   BEGINSQL Alias cAliasPB1
		SELECT *, R_E_C_N_O_ RECNO
			FROM %Table:PB1% PB1
			WHERE PB1.PB1_FILIAL = %Exp:FWxFilial("PB1")%
			AND PB1.PB1_CODIGO = %Exp:BQC->BQC_CODIGO%
         AND PB1.PB1_CODEMP = %Exp:BQC->BQC_CODEMP%
			AND PB1.PB1_NUMCON = %Exp:BQC->BQC_NUMCON%
         AND PB1.PB1_VERCON = %Exp:BQC->BQC_VERCON%
         AND PB1.PB1_SUBCON = %Exp:BQC->BQC_SUBCON%
         AND PB1.PB1_VERSUB = %Exp:BQC->BQC_VERSUB%
			AND PB1.%NotDel%
	ENDSQL

	aData := FwLoadByAlias(oModel, cAliasPB1, MVC_ALIAS, "RECNO", /*lCopy*/, .T.)
	If !Empty(cWorkArea) .And. Select(cWorkArea) > 0
		DBSelectArea(cWorkArea)
	Endif

	(cAliasPB1)->(DBCloseArea())

Return aData

/*/{Protheus.doc} LoadPB6
Carrega o GRID de rubricas por faixa

@return 	aData - Array com os dados para exibição no grid
@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function LoadPB6(oModel)

	LOCAL aData  	 := {}
	LOCAL cAliasPB6 := GetNextAlias()
	LOCAL cWorkArea := Alias()

   BEGINSQL Alias cAliasPB6
		SELECT *, R_E_C_N_O_ RECNO
			FROM %Table:PB6% PB6
			WHERE PB6.PB6_FILIAL = %Exp:FWxFilial("PB6")%
			AND PB6.PB6_CODIGO = %Exp:BQC->BQC_CODIGO%
         AND PB6.PB6_CODEMP = %Exp:BQC->BQC_CODEMP%
			AND PB6.PB6_NUMCON = %Exp:BQC->BQC_NUMCON%
         AND PB6.PB6_VERCON = %Exp:BQC->BQC_VERCON%
         AND PB6.PB6_SUBCON = %Exp:BQC->BQC_SUBCON%
         AND PB6.PB6_VERSUB = %Exp:BQC->BQC_VERSUB%
			AND PB6.%NotDel%
	ENDSQL

	aData := FwLoadByAlias(oModel, cAliasPB6, "PB6", "RECNO", /*lCopy*/, .T.)
	If !Empty(cWorkArea) .And. Select(cWorkArea) > 0
		DBSelectArea(cWorkArea)
	Endif

	(cAliasPB6)->(DBCloseArea())

Return aData

/*/{Protheus.doc} LoadHidFld
Função para load dos dados do field escondido

@return 	Array - Dados para o load do field do modelo de dados
@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function LoadHidFld(oModel)

	LOCAL aLoad := {}
	AADD(aLoad,{BQC->BQC_DESCRI})
	AADD(aLoad,1)

Return aLoad

/*/{Protheus.doc} VldLine
Função para validação da linha do grid

@author 	Michel Sander
@since 	05/09/2022
@version 1.0
/*/

Static Function VldLine(oModel)
Return ( .T. )

Static Function VldLine2(oModel)
Return ( .T. )
