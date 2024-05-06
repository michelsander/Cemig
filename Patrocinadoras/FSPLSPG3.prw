#Include "Protheus.ch"
#Include "TbiCode.ch"
#Include "TbiConn.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"

#DEFINE  COBRANCA "Itens do Lote de Cobrança"

/*/{Protheus.doc} FSPLSPG3
Gera Planilha EXCEL com os itens do Lote de Cobrança 

@author  Michel Sander
@since   27/12/2022
@version 1.0
@Obs     
/*/

User Function FSPLSPG3()

   If !MsgYesNo("Deseja gerar a planilha nesse momento?","MS-Excel")
      Return 
   EndIf 

   // Verifica se EXCEL está instalado no client
   If !ApOLEClient("MsExcel")
      ApMsgStop("Relatório não será gerado.","MS-Excel não instalado.")
      Return
   EndIf

   //Executa o processamento da rotina principal
   Processa({|| fGeraBM1()})
   
Return 

/*/{Protheus.doc} FGERABM1
Processamento da rotina principal

@author  Michel Sander
@since   27/12/2022
@version 1.0
@Obs     
/*/

Static Function fGeraBM1()

   Local cTrb := ""
   Local cArquivo  := GetTempPath()+'BM1'+BDC->BDC_NUMERO+'.xml'
   Local cPlan1    := "Itens do Lote de Cobraça"
   Local aColunas  := {}
   Local nA        := 0
   Local oFWMsExcel
   Local oExcel
   LOCAL nTotalGeral := 0

   cTrb := GetNextAlias()
	BEGINSQL Alias cTrb

		SELECT * FROM %Table:BM1% BM1 
               WHERE BM1_FILIAL = %Exp:FwxFilial("BM1")%
               AND BM1_PLNUCO = %Exp:BDC->BDC_CODOPE+BDC->BDC_NUMERO%
               AND BM1.%NotDel% 

	ENDSQL

   (cTrb)->(dbEval({|| nTotalGeral++}))
   (cTrb)->(dbGotop())

   //Criando o objeto que irá gerar o conteúdo do Excel
   oFWMsExcel := FWMSExcel():New()
   oFWMsExcel:AddworkSheet(cPlan1)
   oFWMsExcel:AddTable(cPlan1, COBRANCA)

   //Compondo as colunas do relatório
   AADD(aColunas,{FwX3Titulo("BM1_MES")    ,1 ,1 })
   AADD(aColunas,{FwX3Titulo("BM1_ANO")    ,1, 1 })
	AADD(aColunas,{FwX3Titulo("BM1_MATRIC") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_TIPUSU") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_MATUSU") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_NOMUSR") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_IDAINI") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_IDAFIN") ,1 ,1 })
   AADD(aColunas,{FwX3Titulo("BM1_VALOR")  ,2 ,2 })
   AADD(aColunas,{FwX3Titulo("BM1_CODTIP") ,1 ,1 })
   AADD(aColunas,{FwX3Titulo("BM1_DESTIP") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_CODEMP") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_CONEMP") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_VERCON") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_SUBCON") ,1 ,1 })
	AADD(aColunas,{FwX3Titulo("BM1_VERSUB") ,1 ,1 })

   // Cria as colunas para planilha
   For nA := 1 to Len(aColunas)
      oFWMsExcel:AddColumn(cPlan1, COBRANCA, aColunas[nA,1], aColunas[nA,2], aColunas[nA,3])
   Next

  	// Carrega regua de processamento
	ProcRegua( nTotalGeral )
   While (cTrb)->(!Eof())
   
   	IncProc("Gerando itens calculados...")

      aLinhaAux := Array(Len(aColunas))
      aLinhaAux[1]  := (cTrb)->BM1_MES
      aLinhaAux[2]  := (cTrb)->BM1_ANO
      aLinhaAux[3]  := (cTrb)->BM1_MATRIC
      aLinhaAux[4]  := (cTrb)->BM1_TIPUSU
      aLinhaAux[5]  := (cTrb)->BM1_MATUSU
      aLinhaAux[6]  := (cTrb)->BM1_NOMUSR
      aLinhaAux[7]  := (cTrb)->BM1_IDAINI 
      aLinhaAux[8]  := (cTrb)->BM1_IDAFIN 
      aLinhaAux[9]  := (cTrb)->BM1_VALOR
      aLinhaAux[10] := (cTrb)->BM1_CODTIP
      aLinhaAux[11] := (cTrb)->BM1_DESTIP
      aLinhaAux[12] := (cTrb)->BM1_CODEMP 
      aLinhaAux[13] := (cTrb)->BM1_CONEMP 
      aLinhaAux[14] := (cTrb)->BM1_VERCON 
      aLinhaAux[15] := (cTrb)->BM1_SUBCON 
      aLinhaAux[16] := (cTrb)->BM1_VERSUB
      oFWMsExcel:AddRow(cPlan1, COBRANCA, aLinhaAux)
      (cTrb)->(dbSkip())

   End 

   //Ativando o arquivo e gerando o xml
   oFWMsExcel:Activate()
   oFWMsExcel:GetXMLFile(cArquivo)

   //Abrindo o excel e abrindo o arquivo xml
   oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
   oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
   oExcel:SetVisible(.T.)                 //Visualiza a planilha
   oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
   (cTrb)->(dbCloseArea())   

Return
