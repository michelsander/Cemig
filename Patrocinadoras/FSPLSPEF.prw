#INCLUDE "PROTHEUS.CH"
#Include 'FwMvcDef.ch'

/*/{Protheus.doc} FSPLSPEF
Rotina para excluir arquivos de patrocinadora gerados

@type    Function
@author  Michel Sander
@since   26/12/2022
@version version
/*/

User Function FSPLSPEF()

   LOCAL lExclui       := .F.

   PRIVATE cLoteCob    := BDC->BDC_NUMERO
	PRIVATE oModelAtivo := FWModelActive()
   PRIVATE oViewAtivo  := FWViewActive()
	PRIVATE cItemPosic  := oModelAtivo:getModel("PB0DETAIL"):getValue("PB0_ITEM")
	PRIVATE cCanal      := AllTrim(oModelAtivo:getModel("PB0DETAIL"):getValue("PB0_CANAL"))
   PRIVATE cNomarq     := oModelAtivo:getModel("PB0DETAIL"):getValue("PB0_NOMARQ")

   If ( BDC->BDC_ANOINI <> BDC->BDC_ANOFIM ) .Or. ( BDC->BDC_MESINI <> BDC->BDC_MESFIM )
      If BDC->BDC_ZLIQUI == "1"
         cMsg := "Para excluir arquivo de cobrança, primeiro será necessário cancelar a aglutinação "
         cMsg += "dos títulos desse lote, pois existe mais de um período calculado e aglutinado."
         cHlp := "Acesse o botão 'Outras Ações' em 'Itens Lote de Cobrança>>Aglutinar>>Cancelar', "
         cHlp += "cancele a aglutinação do lote e em seguida repita essa operação."
         Help( NIL, 1, "ATENÇÃO", NIL, cMsg, 1, 0, , , , , , {cHlp} )
         Return 
      EndIf 
   EndIf

   If cCanal == "A" .Or. cCanal == "E"
      If cCanal == "E"
         If MsgYesNo("Esse arquivo já foi enviado. Deseja mesmo excluir o arquivo "+AllTrim(cNomArq)+" ?","Já enviado")
            lExclui := .T.
         EndIf 
      Else 
         If MsgYesNo("Deseja excluir o arquivo "+AllTrim(cNomArq)+" ?","Exclusão")
            lExclui := .T.
         EndIf
      EndIf 
      If lExclui 
         FWMsgRun(, {|| fProcDel() }, "Processando", "Excluíndo arquivo...")
      EndIf
   Else
      ApMsgStop("Exclusão não permitida para esse status.")
      Return 
   EndIf 

Return

/*/{Protheus.doc} fProcDel
Exclui linha do arquivo gerado para patrocinadora

@type    Function
@author  Michel Sander
@since   26/12/2022
@version version
/*/

Static FUnction fProcDel()

   BEGIN TRANSACTION 
      PB0->(dbSetOrder(1))
      If PB0->(dbSeek(xFilial()+cLoteCob+cItemPosic))
         PB0->(Reclock("PB0",.F.))
         PB0->(dbDelete())
         PB0->(MsUnLock())
         FErase(cNomArq)
         oModelAtivo:DeActivate()
         oModelAtivo:Activate()
      EndIf
   END TRANSACTION 
   
Return
