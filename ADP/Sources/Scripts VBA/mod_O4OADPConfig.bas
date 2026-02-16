Attribute VB_Name = "mod_O4OADPConfig"

'******************************************************************************
' Module de récupération de la configuration de l'outil ADP, intégré au add-in
' Outils4Octalis
'******************************************************************************

Option Explicit

'******************************************************************************
' Mise à jour automatique des informations de gestion de versions par VSS
'******************************************************************************
' ==> $Workfile: mod_O4OADPConfig.bas $
' ==> $Revision: 6 $
' ==> $Date: 24/06/03 15:00 $
' ==> $Author: Mtoledano $
' ==> $Archive: /Add-in Rose/ADP/mod_O4OADPConfig.bas $
'******************************************************************************
Public Const VSS_Infos_mod_O4OADPConfig_BAS = "$Header: /Add-in Rose/ADP/mod_O4OADPConfig.bas 6     24/06/03 15:00 Mtoledano $"
'******************************************************************************

' Identifiant du fichier, en sortie, des classes et packages
Public gInt_ADPIdOutFileClasses As Integer

' Identifiant du fichier, en sortie, des utilisations entre classes
Public gInt_ADPIdOutUsesClasses As Integer

'******************************************************************************
' NOM                  : fPubStr_GetO4OADPPathXSLTransform
' DESCRIPTION          : Récupération du chemin du fichier de transformation
' XSL utilisé lors de l'affichage des résultats (le fichier XML)
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 26/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Public Function fPubStr_GetO4OADPPathXSLTransform() As String
    Call sPub_TracerMessage("mod_O4OPRMConfig.fPubStr_GetO4OADPPathXSLTransform", NatureMessage_Fonctions)
    
    fPubStr_GetO4OADPPathXSLTransform = fPriStr_GetO4OADPConfDir() & "\" & fPriStr_GetO4OADPFichXSLTransform()
End Function

'******************************************************************************
' NOM                  : fPubBln_GetO4OADPXMLNoXSL
' DESCRIPTION          : Récupération du booléen indiquant si le fichier XSL de
' transformation est inhibé
' PARAMETRES           :
' RETOUR               : Boolean
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 26/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Public Function fPubBln_GetO4OADPXMLNoXSL() As Boolean
    Dim vStr_XMLNoXSL As String
    
    Call sPub_TracerMessage("mod_O4OADPConfig.fPubBln_GetO4OADPXMLNoXSL", NatureMessage_Fonctions)
    
    vStr_XMLNoXSL = QueryValue(fPriStr_GetO4OADPRegKey(), gcStr_ADPRegKeyXMLNoXSL)
    
    If (vStr_XMLNoXSL = "Yes") Then
        fPubBln_GetO4OADPXMLNoXSL = True
    ElseIf (vStr_XMLNoXSL = "No") Then
        fPubBln_GetO4OADPXMLNoXSL = False
    Else
        Call sPub_TracerMessage("Clé de registre incorrecte (" & gcStr_ADPRegKeyXMLNoXSL & ")(" & vStr_XMLNoXSL & ")", NatureMessage_Erreurs)
        fPubBln_GetO4OADPXMLNoXSL = False
    End If
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPRegKey
' DESCRIPTION          : Recomposition du répertoire des clés de registres
' spécifiques à l'outil ADP
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPRegKey() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPRegKey", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPRegKey = gcStr_RoseRegKey & "\AddIns\" & gcStr_O4OAddInName & "\" & gcStr_O4OADPName
End Function

'******************************************************************************
' NOM                  : fPubStr_GetO4OADPPathScriptDepend
' DESCRIPTION          : Récupération du chemin du script de reconstitution de
' l'arbre de dépendances entre classes, puis entre packages
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Public Function fPubStr_GetO4OADPPathScriptDepend() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPubStr_GetO4OADPPathScriptDepend", NatureMessage_Fonctions)
    
    fPubStr_GetO4OADPPathScriptDepend = fPriStr_GetO4OADPExecDir() & "\" & fPriStr_GetO4OADPFichScriptDepend()
End Function

'******************************************************************************
' NOM                  : fPubStr_GetO4OADPPathPackagesClasses
' DESCRIPTION          : Récupération du chemin du fichier de la liste des
' classes par package
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Public Function fPubStr_GetO4OADPPathPackagesClasses() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPubStr_GetO4OADPPathPackagesClasses", NatureMessage_Fonctions)
    
    fPubStr_GetO4OADPPathPackagesClasses = fPriStr_GetO4OADPWorkDir() & "\" & fPriStr_GetO4OADPFichPackagesClasses()
End Function

'******************************************************************************
' NOM                  : fPubStr_GetO4OADPPathUsesClasses
' DESCRIPTION          : Récupération du chemin du fichier des utilisations
' entre classes
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 04/04/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Public Function fPubStr_GetO4OADPPathUsesClasses() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPubStr_GetO4OADPPathUsesClasses", NatureMessage_Fonctions)
    
    fPubStr_GetO4OADPPathUsesClasses = fPriStr_GetO4OADPWorkDir() & "\" & fPriStr_GetO4OADPFichUsesClasses()
End Function

'******************************************************************************
' NOM                  : fPubStr_GetO4OADPPathDependClasses
' DESCRIPTION          : Récupération du chemin du fichier des dépendances
' entre classes, trouvées lors du parcours du modèle
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Public Function fPubStr_GetO4OADPPathDependClasses() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPubStr_GetO4OADPPathDependClasses", NatureMessage_Fonctions)
    
    fPubStr_GetO4OADPPathDependClasses = fPriStr_GetO4OADPWorkDir() & "\" & fPriStr_GetO4OADPFichDependClasses()
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPConfDir
' DESCRIPTION          : Récupération du chemin du répertoire de configuration
' de l'outil ADP
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPConfDir() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPConfDir", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPConfDir = fPubStr_GetO4OInstallDir() & "\" & gcStr_O4OADPName & "\Config"
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPExecDir
' DESCRIPTION          : Récupération du chemin du répertoire des exécutables
' de l'outil ADP
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPExecDir() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPExecDir", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPExecDir = fPubStr_GetO4OInstallDir() & "\" & gcStr_O4OADPName & "\Outils"
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPWorkDir
' DESCRIPTION          : Récupération du chemin du répertoire de travail de
' l'outil ADP
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPWorkDir() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPWorkDir", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPWorkDir = fPubStr_GetO4OInstallDir() & "\" & gcStr_O4OADPName & "\Travail"
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPFichXSLTransform
' DESCRIPTION          : Récupération du nom du fichier XSL de transformation
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 26/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPFichXSLTransform() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPFichXSLTransform", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPFichXSLTransform = QueryValue(fPriStr_GetO4OADPRegKey(), gcStr_ADPRegKeyFichXSLTransform)
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPFichPackagesClasses
' DESCRIPTION          : Récupération du nom du fichier de la liste des classes
' par package
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPFichPackagesClasses() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPFichPackagesClasses", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPFichPackagesClasses = QueryValue(fPriStr_GetO4OADPRegKey(), gcStr_ADPRegKeyFichPackagesClasses)
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPFichUsesClasses
' DESCRIPTION          : Récupération du nom du fichier des utilisations entre
' classes
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 04/04/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPFichUsesClasses() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPFichUsesClasses", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPFichUsesClasses = QueryValue(fPriStr_GetO4OADPRegKey(), gcStr_ADPRegKeyFichUsesClasses)
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPFichDependClasses
' DESCRIPTION          : Récupération du nom du fichier des dépendances entre
' classes, trouvées lors du parcours du modèle
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPFichDependClasses() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPFichDependClasses", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPFichDependClasses = QueryValue(fPriStr_GetO4OADPRegKey(), gcStr_ADPRegKeyFichDependClasses)
End Function

'******************************************************************************
' NOM                  : fPriStr_GetO4OADPFichScriptDepend
' DESCRIPTION          : Récupération du nom du script à exécuter
' PARAMETRES           :
' RETOUR               : String
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function fPriStr_GetO4OADPFichScriptDepend() As String
    Call sPub_TracerMessage("mod_O4OADPConfig.fPriStr_GetO4OADPFichScriptDepend", NatureMessage_Fonctions)
    
    fPriStr_GetO4OADPFichScriptDepend = QueryValue(fPriStr_GetO4OADPRegKey(), gcStr_ADPRegKeyFichScriptDepend)
End Function
