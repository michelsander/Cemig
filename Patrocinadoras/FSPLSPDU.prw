#INCLUDE "PROTHEUS.CH"
#INCLUDE "ApWizard.ch"
#INCLUDE "Totvs.CH"

//Wizards
#DEFINE INTRODUCAO		1
#DEFINE PAR_PARAMIXB		2
#DEFINE PAR_DIRETORIO   3
#DEFINE PAR_FINAL  		4

/*/{Protheus.doc} FSPLSPDU
Exportacaoo do arquivo de pagamentos das patrocinadoras   

@author  Michel Sander
@type    function
@since   21/09/2022
@version 1.0
@return  Nil
/*/

User Function FSPLSPDU()

   Local oWizard 	:= Nil
   Local nA		   := 0
   Local cPergEnt	:= "FSPLSPDU"

   //Objetos do Wizard 2
   Local aCpoRange	:= {}
   LOCAl oSayRegua
   local cSayRegua    := ""
   LOCAL cSayPath     := ""

   Private aMarks		:= {}
   Private aPanels	:= {}
   Private oFolder, oGetMod, oProcFinal, oSayResult, oSayDirFin, oSayDirDep
   Private cTargetDir := ""
   Private cProcFInal := ""
   Private cSayResult := ""
   Private cPath		 := ""
   Private cArqFin    := ""
   Private cArqDep    := ""
   Private cFinTxt    := ""
   Private cDepTxt    := ""   
   Private cHorArq 	 := Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)
   Private cDatHor	 := dDataBase
   Private cMes       := ""
   Private cAno       := ""
   PRIVATE aRetRange	 := {}
   Private nRegua     := 0
   PRIVATE aPRange	 := {}
   Private oRegua
   Private cCaminho := ''
   PRIVATE cLoteCob    := BDC->BDC_NUMERO
   PRIVATE oModelAtivo := FWModelActive()
   PRIVATE oViewAtivo  := FWViewActive()
   PRIVATE cItemPosic  := oModelAtivo:getModel("PB0DETAIL"):getValue("PB0_ITEM")
   PRIVATE cCanal      := oModelAtivo:getModel("PB0DETAIL"):getValue("PB0_CANAL")
   PRIVATE cNomArq     := oModelAtivo:getModel("PB0DETAIL"):getValue("PB0_NOMARQ")
   PRIVATE cTipoGer    := ""
   PRIVATE cFileName   := ""
   PRIVATE cMes1       := ""
   PRIVATE cMes2       := ""
   PRIVATE cAno1       := ""
   PRIVATE cAno2       := ""

   //Wizard 1: Introducao
   DEFINE WIZARD oWizard TITLE "Geracao de arquivo das patrocinadoras" ;
         HEADER "PAGAMENTOS" ;  
         MESSAGE "Introducao" ; 
         TEXT "Esta rotina tem o objetivo de "+CRLF+;
               "gerar um arquivo .TXT contendo informacoes de planos e co-participacao, "+CRLF+;
               "para pagamento as patrocinadoras."+CRLF; 
         NEXT {||.T.} ;
         FINISH {||.T.} ;
         PANEL

      //Wizard 2: Parametros
      CREATE PANEL oWizard;
            HEADER "Parametros";
            MESSAGE  "Selecione o(s) parametro(s) de filtro";	
            BACK {|| .T. };
            NEXT {|| fSelPatro() } ;
            FINISH {|| .T. };
            PANEL
      
            aPRange	   := {}
            aRetRange	:= {}
            aCpoRange	:= {}
            aSelFil     := { "1- Gera Pagtos","2- Gera Dependentes","3- Gera Todos" }
            
            // Montagem do Parambox de selecao pro Range  
            aAdd(aPRange,{1,"Mes/Ano Inicial do Lote" ,Space(06)                  	   ,"@!"      ,"",""	      ,""	,10,.F.,"DATAGER1"})
            aAdd(aPRange,{1,"Mes/Ano Final do Lote"   ,Space(06)                  	   ,"@!"      ,"",""	      ,""	,10,.F.,"DATAGER2"})
            aAdd(aPRange,{1,"Acao"                    ,Space(1)                        ,"@!"      ,"",""	      ,""	,10,.F.,"ACAO"})
            aAdd(aPRange,{1,"CNPJ"                    ,Space(TAMSX3("A1_CGC")[1])      ,"@!"      ,"",""	      ,""	,100,.F.,"CNPJ"})
            aAdd(aPRange,{2,"Sobre a geracao"         ,,aSelFil,60,,.T.,,,"SEL1" } )

            For nA := 1 To Len(aPRange)
               aAdd(aRetRange,aPRange[nA][3])
               aAdd(aCpoRange,aPRange[nA][10])
               &("MV_PAR"+STRZERO(nA,2)) := aRetRange[nA] := ParamLoad(cPergEnt,aPRange,nA,aPRange[nA][3])
            Next nA

            ParamBox(aPRange,"Parametros",@aRetRange,,,,,,oWizard:GetPanel(PAR_PARAMIXB))

      //Wizard 3: PROCESSAMENTO
      CREATE PANEL oWizard ;
            HEADER "Geracao de arquivo TXT" ;
            MESSAGE "Processamento";
            BACK {|| EVal({ || cArqFin := "", cArqdep := "", .T. }) };
            NEXT {|| FsGeraNew(@oSayRegua) } ;
            FINISH {|| .T. } ;
            PANEL   
            oArialN	 := TFont():New("Arial",,-12,,.T.)
            cSayPath  := "Caminho do Arquivo:"
            cSayRegua := "Clique em AVANCAR para iniciar"
            @ 05,010 SAY   oSayPath   VAR cSayPath  SIZE 150,10 FONT oArialN OF oWizard:GetPanel(PAR_DIRETORIO) PIXEL
            @ 20,010 SAY   oSayDirFin VAR cArqFin   SIZE 350,30 OF oWizard:GetPanel(PAR_DIRETORIO) PIXEL
            @ 30,010 SAY   oSayDirDep VAR cArqDep   SIZE 350,30 OF oWizard:GetPanel(PAR_DIRETORIO) PIXEL
            @ 50,010 SAY   oSayRegua  VAR cSayRegua SIZE 150,10 FONT oArialN OF oWizard:GetPanel(PAR_DIRETORIO) PIXEL
            @ 60,010 METER oRegua     VAR nRegua TOTAL 100 SIZE 215,10 OF oWizard:GetPanel(PAR_DIRETORIO) NOPERCENTAGE PIXEL
            oRegua:Hide()

      //Wizard 4: ENCERRAMENTO
      CREATE PANEL oWizard ;
            HEADER "Final de Processamento" ;
            MESSAGE "Status de Geracao de arquivo";
            BACK {|| .F. } ;
            NEXT {|| .F. } ;
            FINISH {|| .T. } ;
            PANEL   

            @ 10,010 SAY oSayResult VAR cSayResult SIZE 150,10 FONT oArialN OF oWizard:GetPanel(PAR_FINAL) PIXEL
            @ 30,010 SAY oProcFinal VAR cProcFinal SIZE 1000,500 OF oWizard:GetPanel(PAR_FINAL) PIXEL

   oWizard:Activate()

   //Salva as perguntas
   For nA := 1 To Len(aRetRange)
      &("MV_PAR"+STRZERO(nA,2)) := aRetRange[nA]
   Next nA

   ParamSave(cPergEnt,aPRange,"1")
   oModelAtivo:DeActivate()
   oModelAtivo:Activate()

Return 

/*/{Protheus.doc} fSelPatro()
Seleciona o diretorio de geracaoo do arquivo

@author  Michel Sander
@type    function
@since   21/09/2022
@version 1.0
@return  Nil
/*/

Static Function fSelPatro()

   LOCAL lOk := .T.
   Local lJaGerado := .F.
   
   // Verifica PATH de geração de acordo com novos planos 
   cPath := Alltrim(GetNewPar("FS_DIRARQE","\ARQLCNP\"))
   cMes1 := BDC->BDC_MESINI
   cMes2 := BDC->BDC_MESFIM
   cAno1 := BDC->BDC_ANOINI
   cAno2 := BDC->BDC_ANOFIM

   // Verifica Ano/Mes do período de extração
   If SubStr(mv_par01,1,2) < cMes1 .And. SubStr(mv_par01,3,4) > cAno1
      ApMsgStop("Mês/Ano Inicial de geração não corresponde ao período do lote de cobrança "+BDC->BDC_NUMERO)
      Return(.F.)
   EndIf 
   If SubStr(mv_par02,1,2) < cMes2 .And. SubStr(mv_par02,3,4) > cAno2
      ApMsgStop("Mês/Ano Final de geração não corresponde ao período do lote de cobrança "+BDC->BDC_NUMERO)
      Return(.F.)
   EndIf 

   // Posiciona nos itens do lote de cobrança
   BM1->(dbSetOrder(8))
   If !BM1->(dbSeek(xFilial("")+BDC->BDC_CODOPE+BDC->BDC_NUMERO))
      ApMsgStop("Dados financeiros não foram encontrados. Verifique se o lote de cobrança "+BDC->BDC_NUMERO+ " gerou os títulos financeiros.")
      Return .F.
   EndIf 

   // Nome dos arquivos a serem gerados   
   cFinTxt  := "FIN"+Alltrim(cLoteCob)+'.TXT'
   cDepTxt  := "DEP"+Alltrim(cLoteCob)+".TXT"   

   // Valida se já não foi gerado antes
   cTipoGer := Substr(mv_par05,1,1)
   If cTipoGer == '3'
      lJaGerado := FCHKgerado(cFinTxt)
      If lJaGerado
         MsgAlert("Já existe o arquivo do tipo 'Financeiro' gerado para este lote", "Atenção")
         Return .F.
      EndIf 
      lJaGerado := FCHKgerado(cDepTxt)
      If lJaGerado
         MsgAlert("Já existe o arquivo do tipo 'Dependente' gerado para este lote", "Atenção")
         Return .F.
      EndIf
   ElseIf cTipoGer == '1'
      lJaGerado := FCHKgerado(cFinTxt)
      If lJaGerado
         MsgAlert("Já existe o arquivo do tipo 'Financeiro' gerado para este lote", "Atenção")
         Return .F.
      EndIf 
   ElseIf cTipoGer == '2'
      lJaGerado := FCHKgerado(cDepTxt)
      If lJaGerado
         MsgAlert("Já existe o arquivo do tipo 'Dependente' gerado para este lote", "Atenção")
         Return .F.
      EndIf
   Endif

   cMes := BDC->BDC_MESFIM
   cAno := BDC->BDC_ANOFIM

   // Verifica diretorio de destino
   If !ExistDir(cPath)
      MakeDir(cPath)
   EndIf
   If Right(cPath,1) <> "\"
      cPath += "\"
   EndIf
   cPath := cPath + cAno+cMes +"\"
   If !ExistDir(cPath)
      MakeDir(cPath)
   EndIf
   If Right(cPath,1) <> "\"
      cPath += "\"
   EndIf
   cPath := cPath + BDC->BDC_NUMERO +"\"
   If !ExistDir(cPath)
      MakeDir(cPath)
   EndIf

   cPath := cPath + "ENVIO" +"\"
   If !ExistDir(cPath)
      MakeDir(cPath)
   EndIf

   If !ExistDir(cPath)
      ApMsgStop("Não foi possível criar a pasta de envio "+cPath,"Geração de arquivos")
      lOk := .F.
   EndIf

   If lOk
      If cTipoGer $ '1*3'
         cArqFin  := AllTrim(cPath)+"FIN"+Alltrim(cLoteCob)+".TXT"
      Endif
      If cTipoGer $ '2*3'
         cArqDep  := AllTrim(cPath)+"DEP"+Alltrim(cLoteCob)+".TXT"
      EndIf
      cCaminho := AllTrim(cPath)
   EndIf 

   oSayDirFin:Refresh()
   oSayDirDep:Refresh()

Return ( lOk )

/*/{Protheus.doc} FsGeraNew()
Gera o arquivo financeiro das patrocinadoras para novos produtos

@author  Michel Sander
@type    function
@since   21/09/2022
@version 1.0
@return  Nil
/*/

Static Function FsGeraNew(oSayRegua)

   LOCAL aPatroc   := {}
   LOCAL nLotes    := nX := nReg := nLoop := nErros := 0
   LOCAL cAliasTMP := GetNextAlias()
   Local aArqGerados := {}
   LOCAL cDirTMP	 := AllTrim(GetTempPath()) //-- Diretorio temporario do Windows	
   
   BA1->(dbSetOrder(2))
   BA3->(dbSetOrder(1))
   PB1->(dbSetOrder(1))
   PB6->(dbSetOrder(1))

   oRegua:Show()

   // Gera arquivo financeiro
   If cTipoGer $ "1*3"

      // Cria arquivo de LOG
      cFileName  := cDirTmp+"LogExport_" + "Lote_FIN_" + cLoteCob+"_"+ AllTrim(StrTran(Time(),":","")) + ".TXT"
      nLogHandle := fCreate(cFileName, 0)
      fWrite(nLogHandle, "Log de Erros em " + Dtoc(Date()) + " - " + Time() + " Hs." + CRLF + ;
         "Exportação de Arquivo das Patrocinadoras" + CRLF + ;
         "Arquivo "         + cFileName + CRLF + ;
         "Rotina "          + "FSPLSPDU" + CRLF + ;
         "Tabela(s) "       + "BM1" + CRLF + CRLF)
      fClose(nLogHandle)

      dData1 := "%BM1_ANO+BM1_MES+'01' BETWEEN '"+SubStr(mv_par01,3,4)+SubStr(mv_par01,1,2)+"01' "
      dData1 += "AND '"+SubStr(mv_par02,3,4)+SubStr(mv_par02,1,2)+"01'%"

      BEGINSQL Alias cAliasTMP 
         SELECT BM1_MATUSU, BM1_NOMUSR, BM1_CODTIP, BM1_IDAINI, BM1_IDAFIN, BM1_TIPUSU, BM1_CODEMP, BM1_CONEMP, BM1_VERCON, SUM(BM1_VALOR) BM1_VALOR
         FROM %Table:BM1% BM1 
               WHERE BM1_FILIAL = %Exp:FWxFilial("BM1")%
                     AND %Exp:dData1%
                     AND BM1_PLNUCO = %Exp:BDC->BDC_CODOPE+BDC->BDC_NUMERO%
                     AND BM1.%NotDel%
                     GROUP BY BM1_MATUSU, BM1_NOMUSR, BM1_CODTIP, BM1_IDAINI, BM1_IDAFIN, BM1_TIPUSU, BM1_CODEMP, BM1_CONEMP, BM1_VERCON
                     ORDER BY BM1_CODEMP, BM1_CONEMP, BM1_VERCON
      ENDSQL

      If (cAliasTmp)->(Eof())
         ApMsgStop("Não existem movimentos gerados para o lote de cobrança "+BDC->BDC_NUMERO)
         (cAliasTMP)->(dbCloseArea())
         Return .F.
      EndIf 

      aPatroc := {}
      (cAliasTMP)->(dbEval({|| nReg++}))
      (cAliasTMP)->(dbGoTop())

      oRegua:SetTotal(nReg)

      // Adiciona as rubricas para o array de saÃ­da 
      While (cAliasTMP)->(!Eof())

         nLoop++
         oRegua:Set(nLoop)
         oSayRegua:cCaption := ("Selecionando os movimentos...")
         ProcessMessages()
         
         // Usuários
         If !BA1->(dbSeek(xFilial()+(cAliasTMP)->BM1_MATUSU))
            (cAliasTMP)->(dbSkip())
            Loop
         EndIf

         // verifica no grupo familiar
         cMatTit := SPACE(08)
         If BA3->(dbSeek(xFilial('BA3')+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC))
            If !Empty(BA3->BA3_MATEMP)
               cMatTit := RIGHT(REPLICATE('0',8) + LTRIM(RTRIM(BA3->BA3_MATEMP)),8)
            EndIf 
         EndIf

         // Verifica grupo de cobrança do produto
         If BA3->BA3_GRPCOB != BDC->BDC_GRPCOB 
            (cAliasTMP)->(dbSkip())
            Loop
         EndIf 

         cMatDep := SPACE(08)
         If (cAliasTMP)->BM1_TIPUSU != "T"
            cMatDep := BA1->BA1_MATVID
         EndIf 

         // Código da rubrica na patrocinadora
         cRubrica := SPACE(04)
         If PB6->(dbSeek(xFilial("PB6")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_CODEMP+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERCON+STR((cAliasTMP)->BM1_IDAINI,3)+STR((cAliasTMP)->BM1_IDAFIN,3)+(cAliasTMP)->BM1_CODTIP))
            cRubrica := PB6->PB6_RUBRIC
         ElseIf PB1->(dbSeek(xFilial("PB1")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_CODEMP+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERCON+(cAliasTMP)->BM1_CODTIP))
            cRubrica := PB1->PB1_RUBRIC
         Else 
            nErros   += 1
            cMsg     := "Rubrica do Item de Cobrança "+(cAliasTMP)->BM1_CODTIP+ " não encontrada. Verifique as rubricas relacionadas no sub-contrato."+CRLF
            nLogHandle := FOpen(cFileName,2)
            FSeek(nLogHandle,0,2)
            If nLogHandle > 0
               FWrite(nLogHandle, cMsg)
               FClose(nLogHandle)
            Endif
         EndIf

         AADD( aPatroc, { (cAliasTMP)->(cAno+cMes)+'01',cMatTit,cMatDep,"0015",cRubrica,(cAliasTMP)->BM1_VALOR, cArqFin})
         (cAliasTMP)->(dbSkip())

      EndDo

      (cAliasTMP)->(dbCloseArea())

      //Gera arquivo TXT
      If Len(aPatroc) > 0
         oRegua:SetTotal(Len(aPatroc))
         oRegua:Set(0)
         oSayRegua:cCaption := ("Gerando arquivo das Patrocinadoras...")
         ProcessMessages()
         nLotes    := 0 
         nHdl      := FCreate(cArqFin,0)
         cArqSaida := cArqFin
         For nX := 1 to Len(aPatroc)
            cLinha := mv_par03+AllTrim(mv_par04)+aPatroc[nX,1]+aPatroc[nX,2]+aPatroc[nX,3]+aPatroc[nX,4]+aPatroc[nX,5]+StrZero(Int(aPatroc[nX,6]*100000),17)+CRLF
            FWrite(nHdl,cLinha)
            oRegua:Set(nX)
            ProcessMessages()
         Next 
         FClose(nHdl)
         
         // Grava a tabela de arquivos vinculados
         cItemPB0 := fVerItem()
         BEGIN TRANSACTION
            PB0->(RecLock("PB0",.T.))
            PB0->PB0_FILIAL   := xFilial("PB0")
            PB0->PB0_CODIGO	:= BDC->BDC_NUMERO
            PB0->PB0_ITEM	   := cItemPB0
            PB0->PB0_CANAL	   := "A" //A=Aguardando Envio;E=Enviado;R=Verifique o Retorno;G=Aguardando Baixa;B=Baixado no Financeiro
            PB0->PB0_TIPARQ	:= "E" //E=Envio;R=Retorno   
            PB0->PB0_SINCRO   := "0" //cSinCro // 0=Não;1=Sim
            PB0->PB0_TIPGRP   := "S" //cTipGrp // G=Grupo/Empresa;C=Contrato;S=Subcontrato
            PB0->PB0_DATA	   := dDataBase
            PB0->PB0_HORA     := Time()
            PB0->PB0_USUARI	:= SubStr(cUsuario,7,15)
            PB0->PB0_ARQUIV	:= cArqSaida
            PB0->PB0_NOMARQ   := AllTrim(cFinTxt)
            PB0->(MsUnLock())
         END TRANSACTION

      EndIf

      If nErros > 0
         lErro := ApMsgYesNo("Arquivo financeiro gerado com erros. Deseja visualizar o log de processamento?")
         If lErro 
            WinExec( "Notepad.exe " + cFileName)
         Else 
            FERASE(cFileName)
         EndIf 
         cSayResult := "Processamento com ERRO!"
         cProcfinal := "O arquivo financeiro foi gerado com erros."+CRLF
         cProcFinal += "O processo de envio foi interrompido."
      Else 
         cSayResult := "Processamento OK"
         cProcFinal += "Verifque a geracao do arquivo do arquivo Financeiro:"+CRLF
         cProcFinal += cArqFin+CRLF+CRLF
      EndIf 

   EndIf 

   // Gera arquivo de dependentes
   If cTipoGer $ "2*3"
      
      // Cria arquivo de LOG
      cFileName  := cDirTmp+"LogExport_" + "Lote_DEP_" + cLoteCob+"_"+ AllTrim(StrTran(Time(),":","")) + ".TXT"
      nLogHandle := fCreate(cFileName, 0)
      fWrite(nLogHandle, "Log de Erros em " + Dtoc(Date()) + " - " + Time() + " Hs." + CRLF + ;
         "Exportação de Arquivo de dependentes das Patrocinadoras" + CRLF + ;
         "Rotina "          + "FSPLSPDU" + CRLF + ;
         "Tabela(s) "       + "BM1" + CRLF + CRLF)
      fClose(nLogHandle)

      aPatroc := aArqGerados := {}
      nReg    := nLoop := nErros := 0
      cAliasTMP := GetNextAlias()
      BEGINSQL Alias cAliasTMP 
         SELECT DISTINCT BM1_MATUSU, BM1_NOMUSR
         FROM %Table:BM1% BM1 
               WHERE BM1_FILIAL = %Exp:FWxFilial("BM1")%
                     AND ( BM1_ANO BETWEEN %Exp:SubStr(mv_par01,3,4)% AND %Exp:SubStr(mv_par02,3,4)% )
                     AND ( BM1_MES BETWEEN %Exp:SubStr(mv_par01,1,2)% AND %Exp:SubStr(mv_par02,1,2)% )
                     AND BM1_PLNUCO = %Exp:BDC->BDC_CODOPE+BDC->BDC_NUMERO%
                     AND BM1_TIPUSU = 'D'
                     AND BM1.%NotDel%
      ENDSQL

      If (cAliasTmp)->(Eof())
         ApMsgStop("Não existem movimentos gerados para o lote de cobrança "+BDC->BDC_NUMERO)
         (cAliasTMP)->(dbCloseArea())
         Return .F.
      EndIf 

      (cAliasTMP)->(dbEval({|| nReg++}))
      (cAliasTMP)->(dbGoTop())

      oRegua:SetTotal(nReg)
      oSayRegua:cCaption := ("Selecionando os movimentos...")
      ProcessMessages()

      // Adiciona as rubricas para o array de saÃ­da
      While (cAliasTMP)->(!Eof())

         nLoop++
         oRegua:Set(nLoop)
         oSayRegua:cCaption := ("Selecionando os movimentos...")
         ProcessMessages()
         
         // Usuários
         If !BA1->(dbSeek(xFilial()+(cAliasTMP)->BM1_MATUSU))
            (cAliasTMP)->(dbSkip())
            Loop
         EndIf

         cMatEmp := SPACE(8)
         If BA3->(dbSeek(xFilial('BA3')+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC))
            If !Empty(BA3->BA3_MATEMP)
               cMatEmp := RIGHT(REPLICATE('0',8) + LTRIM(RTRIM(BA3->BA3_MATEMP)),8)
            Else 
               nErros   += 1
               cMsg     := "Matrícula da empresa não configurada para o beneficiário "+PADR(BA1->BA1_NOMUSR,60)+ " não encontrada."+CRLF
               nLogHandle := FOpen(cFileName,2)
               FSeek(nLogHandle,0,2)
               If nLogHandle > 0
                  FWrite(nLogHandle, cMsg)
                  FClose(nLogHandle)
               Endif
            EndIf 
         EndIf

         // verifica no grupo familiar
         cMatVid := SubStr(BA1->BA1_MATVID,1,8)
         cCpfUsr := If( Empty(BA1->BA1_CPFUSR), Repl(' ',11), BA1->BA1_CPFUSR)
         If BA1->BA1_GRAUPA == '01' 
            cGrau :=  '99' /*--TITULAR */
         ElseIf BA1->BA1_GRAUPA == '02' 
            cGrau := '01' /*--CONJUGE / COMPANHEIRO - 1 */
         ElseIf BA1->BA1_GRAUPA == '03'
            cGrau := '02' /*--FILHO / FILHA - 2*/
         ElseIf BA1->BA1_GRAUPA == '04' 
            cGrau := '06' /*--ENTEADO / ENTEADA - 6 */
         ElseIf BA1->BA1_GRAUPA == '05' 
            cGrau := '05' /*--MENOR SOB GUARDA / TUTELADO -5 */
         ElseIf BA1->BA1_GRAUPA == '06' 
            cGrau := '10' /*--NETO - 10*/
         ElseIf BA1->BA1_GRAUPA == '07' 
            cGrau := '13' /*--EX-CONJUGE / EX-CONVIVENTE - 13*/
         ElseIf BA1->BA1_GRAUPA == '08' 
            cGrau := '17' /*--IRMÃO / IRMÃ - 17 */
         ElseIf BA1->BA1_GRAUPA == '09' 
            cGrau := '11' /*--PAI / MÃE - 11/12*/
         ElseIf BA1->BA1_GRAUPA == '10' 
            cGrau := '99' /*--TIO / TIA - 99*/
         ElseIf BA1->BA1_GRAUPA == '11' 
            cGrau := '99' /*--AVÓ / AVÔ -- 99*/
         ElseIf BA1->BA1_GRAUPA == '12' 
            cGrau := '99' /*--AGREGADO / OUTROS- 99*/
         ElseIf BA1->BA1_GRAUPA == '99' 
            cGrau := '99' /*--INDEFINIDO" - 99*/
         Else 
            cGrau := '99' /*--INDEFINIDO" - 99*/
         EndIf 
         cNomUsr := RTRIM(SUBSTRING(BA1->BA1_NOMUSR,1,80)) + REPLICATE(' ',80 - LEN(RTRIM(SUBSTRING(BA1->BA1_NOMUSR,1,80))))
         cDatNas := Dtos(BA1->BA1_DATNAS)
         AADD( aPatroc , {mv_par03, mv_par04, cMatEmp, cMatVid, cCpfUsr, cGrau, cNomUsr, cDatNas, cArqDep})
         (cAliasTMP)->(dbSkip())
      End 

      //Gera arquivo TXT
      If Len(aPatroc) > 0
         oRegua:SetTotal(Len(aPatroc))
         oRegua:Set(0)
         oSayRegua:cCaption := ("Gerando arquivo de Dependentes...")
         ProcessMessages()
         nLotes    := 0 
         nHdl      := FCreate(cArqDep,0)
         cArqSaida := cArqDep
         For nX := 1 to Len(aPatroc)
            oRegua:Set(nX)
            oSayRegua:cCaption := ("Gerando arquivo de Dependentes...")
            ProcessMessages()
            cLinha := aPatroc[nX,1]+aPatroc[nX,2]+aPatroc[nX,3]+aPatroc[nX,4]+aPatroc[nX,5]+aPatroc[nX,6]+aPatroc[nX,7]+aPatroc[nX,8]+CRLF
            FWrite(nHdl,cLinha)
            oRegua:Set(nX)
            ProcessMessages()
         Next 
         FClose(nHdl)

         // Grava a tabela de arquivos vinculados
         cItemPB0 := fVerItem()
         BEGIN TRANSACTION
            PB0->(RecLock("PB0",.T.))
            PB0->PB0_FILIAL   := xFilial("PB0")
            PB0->PB0_CODIGO	:= BDC->BDC_NUMERO
            PB0->PB0_ITEM	   := cItemPB0
            PB0->PB0_CANAL	   := "A" //A=Aguardando Envio;E=Enviado;R=Verifique o Retorno;G=Aguardando Baixa;B=Baixado no Financeiro
            PB0->PB0_TIPARQ	:= "E" //E=Envio;R=Retorno   
            PB0->PB0_SINCRO   := "0" //cSinCro // 0=Não;1=Sim
            PB0->PB0_TIPGRP   := "S" //cTipGrp // G=Grupo/Empresa;C=Contrato;S=Subcontrato
            PB0->PB0_DATA	   := dDataBase
            PB0->PB0_HORA     := Time()
            PB0->PB0_USUARI	:= SubStr(cUsuario,7,15)
            PB0->PB0_ARQUIV	:= cArqSaida
            PB0->PB0_NOMARQ   := AllTrim(cDepTxt)
            PB0->(MsUnLock())
         END TRANSACTION

      EndIf

      (cAliasTMP)->(dbCloseArea())

      If nErros > 0
         lErro := ApMsgYesNo("Arquivo de dependentes gerado com erros. Deseja visualizar o log de processamento?")
         If lErro 
            WinExec( "Notepad.exe " + cFileName)
         Else 
            FERASE(cFileName)
         EndIf 
         cSayResult := "Processamento com ERRO!"
         cProcfinal += "Arquivo de dependentes não foi gerado corretamente. Verifique o log de processamento."+CRLF
         cProcFinal += "O processo de envio foi interrompido."
      Else 
         cSayResult := "Processamento OK"
         cProcFinal += "Verifque a geracao do arquivo do arquivo de Dependentes:"+CRLF
         cProcFinal += cArqDep+CRLF
      EndIf 

   EndIf 

   oSayResult:Refresh()
   oProcFinal:Refresh()

Return .T.

/*/{Protheus.doc} fVerItem()
Busca a próxima sequência do item de arquivo

@author  Michel Sander
@type    function
@since   07/12/2022
@version 1.0
@return  Nil
/*/

Static Function fVerItem()

   Local cItemUso := ""

   PB0->(dbSetOrder(1))
   cItemUso := Repl('0',TamSX3("PB0_ITEM")[1])
   If PB0->(dbSeek(xFilial()+BDC->BDC_NUMERO))
      While PB0->(!Eof()) .And. PB0->PB0_FILIAL+PB0->PB0_CODIGO == xFilial("PB0")+BDC->BDC_NUMERO
         cItemuso := PB0->PB0_ITEM
         PB0->(dbSkip())
      End 
   EndIf 
   
   cItemUso := Soma1(cItemUso)

Return ( cItemUso )

/*/{Protheus.doc} fVerItem()
Valida se já não foi gerado anteriormente para não gerar registros/processamento em duplicidade

@author  Oscar Zanin
@type    static function
@since   11/12/2022
@version 1.0
@return  Nil
/*/
Static Function FCHKgerado(cArqUso)

   Local lRet     := .F.
   Local cTempPB0 := GetNextAlias()

   BEGINSQL Alias cTempPB0
      SELECT PB0_NOMARQ FROM %Table:PB0% PB0
                        WHERE PB0_FILIAL = %Exp:FWxFilial("PB0")% 
                        AND PB0_CODIGO = %Exp:cLoteCob%
                        AND PB0.%NotDel% 
   ENDSQL 

   While (cTempPB0)->(!Eof())
      If allTrim(cArqUso) == AllTrim((cTempPB0)->PB0_NOMARQ)
         lRet := .T.
         Exit 
      EndIf
      (cTempPB0)->(dbSkip())   
   End
   (cTempPB0)->(dbclosearea())

Return lRet
