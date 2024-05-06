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
         cMsg := "Para excluir arquivo de cobran�a, primeiro ser� necess�rio cancelar a aglutina��o "
         cMsg += "dos t�tulos desse lote, pois existe mais de um per�odo calculado e aglutinado."
         cHlp := "Acesse o bot�o 'Outras A��es' em 'Itens Lote de Cobran�a>>Aglutinar>>Cancelar', "
         cHlp += "cancele a aglutina��o do lote e em seguida repita essa opera��o."
         Help( NIL, 1, "ATEN��O", NIL, cMsg, 1, 0, , , , , , {cHlp} )
         Return 
      EndIf 
   EndIf

   If cCanal == "A" .Or. cCanal == "E"
      If cCanal == "E"
         If MsgYesNo("Esse arquivo j� foi enviado. Deseja mesmo excluir o arquivo "+AllTrim(cNomArq)+" ?","J� enviado")
            lExclui := .T.
         EndIf 
      Else 
         If MsgYesNo("Deseja excluir o arquivo "+AllTrim(cNomArq)+" ?","Exclus�o")
            lExclui := .T.
         EndIf
      EndIf 
      If lExclui 
         FWMsgRun(, {|| fProcDel() }, "Processando", "Exclu�ndo arquivo...")
      EndIf
   Else
      ApMsgStop("Exclus�o n�o permitida para esse status.")
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
