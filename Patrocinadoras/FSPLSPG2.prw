#INCLUDE "PROTHEUS.CH"
#Include 'FwMvcDef.ch'
#Include 'Stilo.ch'

/*/{Protheus.doc} FSPLSPG2
Rotina para visualizar os itens do lote de cobrança  

@type    Function
@author  Michel Sander
@since   14/12/2022
@version version
/*/

User Function FSPLSPG2()

   Local cFontUti    := "Tahoma"
	Local oFontAno    := TFont():New(cFontUti,,-38)
	Local oFontSub    := TFont():New(cFontUti,,-20)
	Local oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
	Local oFontBtn    := TFont():New(cFontUti,,-14)

   PRIVATE oTmpBM1
   PRIVATE cTrbTable   := GetNextAlias()
   PRIVATE cLoteCob    := BDC->BDC_NUMERO
	PRIVATE oModelAtivo := FWModelActive()
   PRIVATE oViewAtivo  := FWViewActive()
	PRIVATE cItemPosic  := oModelAtivo:getModel("PB0DETAIL"):getValue("PB0_ITEM")
	PRIVATE cCanal      := oModelAtivo:getModel("PB0DETAIL"):getValue("PB0_CANAL")
	PRIVATE oBrwBM1
	PRIVATE nMeses      := 0
   
	//Janela e componentes
	Private oDlgGrp
	Private oPanGrid
	Private oGetGrid
	Private aHeaderGrid := {}

	//Tamanho da janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]

   // cria tabela temporária com o lote de cobrança editado
   FTmpTable()

	//Criando a janela
	DEFINE MSDIALOG oDlgGrp TITLE "ITENS DE COBRANÇA" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	
   //Labels gerais
	@ 001, 003 SAY "FINANCEIRO"        SIZE 200, 030 FONT oFontAno  OF oDlgGrp COLORS RGB(149,179,215) PIXEL
	@ 004, 120 SAY "Itens do"          SIZE 200, 030 FONT oFontSub  OF oDlgGrp COLORS RGB(031,073,125) PIXEL
	@ 014, 120 SAY "Lote de Cobrança "+BDC->BDC_NUMERO  SIZE 200, 030 FONT oFontSubN OF oDlgGrp COLORS RGB(031,073,125) PIXEL

	//Botões
	@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar" SIZE 050, 018 OF oDlgGrp ACTION (oDlgGrp:End())   FONT oFontBtn PIXEL
   
   //Cria CSS Defualt para o Botão Sair
   cCSSBtn1 := " QPushButton {"
   cCSSBtn1 += " background-color: rgb(0, 149, 182);"
   cCSSBtn1 += " border-style: outset; "
   cCSSBtn1 += " border-width: 0.5px;"
   cCSSBtn1 += " border-color: rgb(169, 169, 169);"
   cCSSBtn1 += " border-radius: 4px;"
   cCSSBtn1 += " font: bold 12px arial;"
   cCSSBtn1 += " color: white;"
   cCSSBtn1 += " }"
   oBtnFech:setCSS(cCssBtn1)
   oBtnFech:Refresh()
	
   //Dados
	@ 024, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "Itens de Cobrança Gerados" OF oDlgGrp COLOR 0, 16777215 PIXEL

	oGrpDad:oFont := oFontBtn
	oPanGrid := TPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))
	oBrwBM1 := FWMBrowse():New()
	oBrwBM1:SetAlias(cTrbTable)
	oBrwBM1:SetTemporary(.T.)
	oBrwBM1:SetLocate()
   oBrwBM1:SetDescription( "Cobrança gerada de "+BDC_MESINI+"/"+BDC_ANOINI+" Até "+BDC_MESFIM+"/"+BDC_ANOFIM )
   oBrwBM1:AddLegend("BM1_TIPUSU == 'T'" ,'GREEN'  ,'Titular')
   oBrwBM1:AddLegend("BM1_TIPUSU == 'D'" ,'BLUE'   ,'Dependente')
   oBrwBM1:SetColumns(MontaColunas("BM1_MES"    ,FwX3Titulo("BM1_MES")    ,01,X3Picture("BM1_MES")   ,1,TamSX3("BM1_MES")[1])   ,TamSX3("BM1_MES")[2])
   oBrwBM1:SetColumns(MontaColunas("BM1_ANO"    ,FwX3Titulo("BM1_ANO")    ,02,X3Picture("BM1_ANO")   ,1,TamSX3("BM1_ANO")[1])   ,TamSX3("BM1_ANO")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_MATRIC" ,FwX3Titulo("BM1_MATRIC") ,03,X3Picture("BM1_MATRIC"),1,TamSX3("BM1_MATRIC")[1]),TamSX3("BM1_MATRIC")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_TIPUSU" ,FwX3Titulo("BM1_TIPUSU") ,04,X3Picture("BM1_TIPUSU"),1,TamSX3("BM1_TIPUSU")[1]),TamSX3("BM1_TIPUSU")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_MATUSU" ,FwX3Titulo("BM1_MATUSU") ,05,X3Picture("BM1_MATUSU"),1,TamSX3("BM1_MATUSU")[1]),TamSX3("BM1_MATUSU")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_NOMUSR" ,FwX3Titulo("BM1_NOMUSR") ,06,X3Picture("BM1_NOMUSR"),1,TamSX3("BM1_NOMUSR")[1]),TamSX3("BM1_NOMUSR")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_IDAINI" ,FwX3Titulo("BM1_IDAINI") ,12,X3Picture("BM1_IDAINI"),1,TamSX3("BM1_IDAINI")[1]),TamSX3("BM1_IDAINI")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_IDAFIN" ,FwX3Titulo("BM1_IDAFIN") ,13,X3Picture("BM1_IDAFIN"),1,TamSX3("BM1_IDAFIN")[1]),TamSX3("BM1_IDAFIN")[2])
   oBrwBM1:SetColumns(MontaColunas("BM1_VALOR"  ,FwX3Titulo("BM1_VALOR")  ,07,X3Picture("BM1_VALOR") ,2,TamSX3("BM1_VALOR")[1]) ,TamSX3("BM1_VALOR")[2])
   oBrwBM1:SetColumns(MontaColunas("BM1_CODTIP" ,FwX3Titulo("BM1_CODTIP") ,08,X3Picture("BM1_CODTIP"),1,TamSX3("BM1_CODTIP")[1]),TamSX3("BM1_CODTIP")[2])
   oBrwBM1:SetColumns(MontaColunas("BM1_DESTIP" ,FwX3Titulo("BM1_DESTIP") ,09,X3Picture("BM1_DESTIP"),1,TamSX3("BM1_DESTIP")[1]),TamSX3("BM1_DESTIP")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_PREFIX" ,FwX3Titulo("BM1_PREFIX") ,10,X3Picture("BM1_PREFIX"),1,TamSX3("BM1_PREFIX")[1]),TamSX3("BM1_PREFIX")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_NUMTIT" ,FwX3Titulo("BM1_NUMTIT") ,10,X3Picture("BM1_NUMTIT"),1,TamSX3("BM1_NUMTIT")[1]),TamSX3("BM1_NUMTIT")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_PARCEL" ,FwX3Titulo("BM1_PARCEL") ,10,X3Picture("BM1_PARCEL"),1,TamSX3("BM1_PARCEL")[1]),TamSX3("BM1_PARCEL")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_TIPTIT" ,FwX3Titulo("BM1_TIPTIT") ,10,X3Picture("BM1_TIPTIT"),1,TamSX3("BM1_TIPTIT")[1]),TamSX3("BM1_TIPTIT")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_CODEMP" ,FwX3Titulo("BM1_CODEMP") ,10,X3Picture("BM1_CODEMP"),1,TamSX3("BM1_CODEMP")[1]),TamSX3("BM1_CODEMP")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_CONEMP" ,FwX3Titulo("BM1_CONEMP") ,11,X3Picture("BM1_CONEMP"),1,TamSX3("BM1_CONEMP")[1]),TamSX3("BM1_CONEMP")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_VERCON" ,FwX3Titulo("BM1_VERCON") ,14,X3Picture("BM1_VERCON"),1,TamSX3("BM1_VERCON")[1]),TamSX3("BM1_VERCON")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_SUBCON" ,FwX3Titulo("BM1_SUBCON") ,15,X3Picture("BM1_SUBCON"),1,TamSX3("BM1_SUBCON")[1]),TamSX3("BM1_SUBCON")[2])
	oBrwBM1:SetColumns(MontaColunas("BM1_VERSUB" ,FwX3Titulo("BM1_VERSUB") ,16,X3Picture("BM1_VERSUB"),1,TamSX3("BM1_VERSUB")[1]),TamSX3("BM1_VERSUB")[2])
   oBrwBM1:SetMenuDef("FSPLSPG2")
   oBrwBM1:SetWalkThru(.F.)
   oBrwBM1:SetAmbiente(.F.)
   oBrwBM1:DisableReport()
   oBrwBM1:SetOwner(oPanGrid)
	oBrwBM1:Activate()

	ACTIVATE MsDialog oDlgGrp CENTERED
   oTmpBM1:Delete()

Return ( NIL )

/*/{Protheus.doc} MenuDef
Botão para geração de planilha excel

@author    Michel Sander
@since     14.12.2022
/*/

Static Function MenuDef()

	Local aRotFin := {}
	LOCAL aSubRot := {}

	ADD OPTION aSubRot Title 'Liquidar'		 		Action 'U_FSPLSPH0()' 	OPERATION 2 ACCESS 0
	ADD OPTION aSubRot Title 'Cancelar'		 		Action 'U_FSPLSPH4()' 	OPERATION 2 ACCESS 0
	ADD OPTION aSubRot Title 'Visualizar'	 		Action 'U_FSPLSPH5()' 	OPERATION 2 ACCESS 0

	ADD OPTION aRotFin Title 'Gera Planilha' 		Action 'U_FSPLSPG3()' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotFin Title 'Aglutinação' 		Action aSubRot			 	OPERATION 2 ACCESS 0

Return ( aRotFin )

/*/{Protheus.doc} FTmpTable
Cria o arquivo temporário com os itens de lote de cobrança

@author  Michel Sander
@since   27/12/2022
@version P12.1.033
/*/

Static Function FTmpTable()

	LOCAL aCampos := {}
   LOCAl cAliasBM1 := ""
	LOCAL aMeses  := {}

	AAdd(aCampos,{"BM1_MES"   , TamSX3('BM1_MES')[3]    , TamSX3('BM1_MES')[1]    , TamSX3('BM1_MES')[2]})
	AAdd(aCampos,{"BM1_ANO"   , TamSX3('BM1_ANO')[3]    , TamSX3('BM1_ANO')[1]    , TamSX3('BM1_ANO')[2]})
	AAdd(aCampos,{"BM1_MATRIC", TamSX3('BM1_MATRIC')[3] , TamSX3('BM1_MATRIC')[1] , TamSX3('BM1_MATRIC')[2]})
	AAdd(aCampos,{"BM1_TIPUSU", TamSX3('BM1_TIPUSU')[3] , TamSX3('BM1_TIPUSU')[1] , TamSX3('BM1_TIPUSU')[2]})
	AAdd(aCampos,{"BM1_MATUSU", TamSX3('BM1_MATUSU')[3] , TamSX3('BM1_MATUSU')[1] , TamSX3('BM1_MATUSU')[2]})
	AAdd(aCampos,{"BM1_NOMUSR", TamSX3('BM1_NOMUSR')[3] , TamSX3('BM1_NOMUSR')[1] , TamSX3('BM1_NOMUSR')[2]})
	AAdd(aCampos,{"BM1_IDAINI" ,TamSX3("BM1_IDAINI")[3] , TamSX3("BM1_IDAINI")[1] , TamSX3("BM1_IDAINI")[2]})
	AAdd(aCampos,{"BM1_IDAFIN" ,TamSX3("BM1_IDAFIN")[3] , TamSX3("BM1_IDAFIN")[1] , TamSX3("BM1_IDAFIN")[2]})
	AAdd(aCampos,{"BM1_VALOR" , TamSX3('BM1_VALOR')[3]  , TamSX3('BM1_VALOR')[1]  , TamSX3('BM1_VALOR')[2]})
	AAdd(aCampos,{"BM1_CODTIP", TamSX3('BM1_CODTIP')[3] , TamSX3('BM1_CODTIP')[1] , TamSX3('BM1_CODTIP')[2]})
   AAdd(aCampos,{"BM1_DESTIP", TamSX3('BM1_DESTIP')[3] , TamSX3('BM1_DESTIP')[1] , TamSX3('BM1_DESTIP')[2]})
   AAdd(aCampos,{"BM1_PREFIX", TamSX3('BM1_PREFIX')[3] , TamSX3('BM1_PREFIX')[1] , TamSX3('BM1_PREFIX')[2]})
   AAdd(aCampos,{"BM1_NUMTIT", TamSX3('BM1_NUMTIT')[3] , TamSX3('BM1_NUMTIT')[1] , TamSX3('BM1_NUMTIT')[2]})
   AAdd(aCampos,{"BM1_PARCEL", TamSX3('BM1_PARCEL')[3] , TamSX3('BM1_PARCEL')[1] , TamSX3('BM1_PARCEL')[2]})
   AAdd(aCampos,{"BM1_TIPTIT", TamSX3('BM1_TIPTIT')[3] , TamSX3('BM1_TIPTIT')[1] , TamSX3('BM1_TIPTIT')[2]})
	AAdd(aCampos,{"BM1_CODEMP", TamSX3('BM1_CODEMP')[3] , TamSX3('BM1_CODEMP')[1] , TamSX3('BM1_CODEMP')[2]})
	AAdd(aCampos,{"BM1_CONEMP", TamSX3('BM1_CONEMP')[3] , TamSX3('BM1_CONEMP')[1] , TamSX3('BM1_CONEMP')[2]})
	AAdd(aCampos,{"BM1_VERCON", TamSX3('BM1_VERCON')[3] , TamSX3('BM1_VERCON')[1] , TamSX3('BM1_VERCON')[2]})
	AAdd(aCampos,{"BM1_SUBCON", TamSX3('BM1_SUBCON')[3] , TamSX3('BM1_SUBCON')[1] , TamSX3('BM1_SUBCON')[2]})
	AAdd(aCampos,{"BM1_VERSUB", TamSX3('BM1_VERSUB')[3] , TamSX3('BM1_VERSUB')[1] , TamSX3('BM1_VERSUB')[2]})

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If (Select((cTrbTable)) <> 0)
		(cTrbTable)->(dbCloseArea())
	Endif

	//Criar tabela temporária
	oTmpBM1 := FWTemporaryTable():New(cTrbTable)
	oTmpBM1:SetFields( aCampos )
	oTmpBM1:AddIndex("01",{'BM1_MATUSU'})
	oTmpBM1:Create()

	nMeses    := 0
   cAliasBM1 := GetNextAlias()
	BEGINSQL Alias cAliasBM1

		SELECT * FROM %Table:BM1% BM1 
               WHERE BM1_FILIAL = %Exp:FwxFilial("BM1")%
               AND BM1_PLNUCO = %Exp:BDC->BDC_CODOPE+BDC->BDC_NUMERO%
               AND BM1.%NotDel% 
					ORDER BY BM1_MES, BM1_ANO

	ENDSQL

	nMeses := 1
	AADD(aMeses,(cAliasBM1)->BM1_MES+(cAliasBM1)->BM1_ANO)

	While (cAliasBM1)->(!Eof())
		If ASCAN(aMeses, (cAliasBM1)->BM1_MES+(cAliasBM1)->BM1_ANO) == 0
			AADD(aMeses,(cAliasBM1)->BM1_MES+(cAliasBM1)->BM1_ANO)
			nMeses++
		EndIf
		RecLock((cTrbTable),.t.)
      (cTrbTable)->BM1_MES    := (cAliasBM1)->BM1_MES     
      (cTrbTable)->BM1_ANO    := (cAliasBM1)->BM1_ANO    
      (cTrbTable)->BM1_MATRIC := (cAliasBM1)->BM1_MATRIC 
      (cTrbTable)->BM1_TIPUSU := (cAliasBM1)->BM1_TIPUSU 
      (cTrbTable)->BM1_MATUSU := (cAliasBM1)->BM1_MATUSU 
      (cTrbTable)->BM1_NOMUSR := (cAliasBM1)->BM1_NOMUSR 
      (cTrbTable)->BM1_IDAINI := (cAliasBM1)->BM1_IDAINI
      (cTrbTable)->BM1_IDAFIN := (cAliasBM1)->BM1_IDAFIN
      (cTrbTable)->BM1_VALOR  := (cAliasBM1)->BM1_VALOR  
      (cTrbTable)->BM1_CODTIP := (cAliasBM1)->BM1_CODTIP 
      (cTrbTable)->BM1_DESTIP := (cAliasBM1)->BM1_DESTIP 
		(cTrbTable)->BM1_PREFIX := (cAliasBM1)->BM1_PREFIX 
		(cTrbTable)->BM1_NUMTIT := (cAliasBM1)->BM1_NUMTIT 
		(cTrbTable)->BM1_PARCEL := (cAliasBM1)->BM1_PARCEL 
		(cTrbTable)->BM1_TIPTIT := (cAliasBM1)->BM1_TIPTIT 
      (cTrbTable)->BM1_CODEMP := (cAliasBM1)->BM1_CODEMP
      (cTrbTable)->BM1_CONEMP := (cAliasBM1)->BM1_CONEMP
      (cTrbTable)->BM1_VERCON := (cAliasBM1)->BM1_VERCON 
      (cTrbTable)->BM1_SUBCON := (cAliasBM1)->BM1_SUBCON 
      (cTrbTable)->BM1_VERSUB := (cAliasBM1)->BM1_VERSUB 
      (cTrbTable)->(MsUnLock())
		(cAliasBM1)->(dbSkip())
	EndDo

   (cAliasBM1)->(dbCloseArea())
	(cTrbTable)->(DbGoTop())

Return

/*/{Protheus.doc} MontaColunas()
Monta as colunas que serão apresentadas no Browse MVC

@author Michel Sander
@since   27/12/2022
@version P12.1.033
/*/

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	  := {||}

	Default nAlign   := 1
	Default nSize 	  := 20
	Default nDecimal := 0
	Default nArrData := 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	EndIf

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}
