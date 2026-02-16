Attribute VB_Name = "mod_O4OADPConst"

'******************************************************************************
' Module de déclaration des constantes spécifiques à l'outil ADP du add-in
' Outils4Octalis
'******************************************************************************

Option Explicit

'******************************************************************************
' Mise à jour automatique des informations de gestion de versions par VSS
'******************************************************************************
' ==> $Workfile: mod_O4OADPConst.bas $
' ==> $Revision: 11 $
' ==> $Date: 22/10/03 10:54 $
' ==> $Author: Mtoledano $
' ==> $Archive: /Add-in Rose/ADP/mod_O4OADPConst.bas $
'******************************************************************************
Public Const VSS_Infos_mod_O4OADPConst_BAS = "$Header: /Add-in Rose/ADP/mod_O4OADPConst.bas 11    22/10/03 10:54 Mtoledano $"
'******************************************************************************

'------------------------------------------------------------------------------
' Constantes utiles pour l'identification de l'outil
'------------------------------------------------------------------------------

Public Const gcStr_O4OADPName As String = "ADP"

'------------------------------------------------------------------------------
' Constantes de recherche dans la table de registre Windows
'------------------------------------------------------------------------------

Public Const gcStr_ADPRegKey As String = ""

' Nom du fichier de transformation XSL utilisé
Public Const gcStr_ADPRegKeyFichXSLTransform As String = "FichXSLTransform"

' Etat d'utilisation de la feuille de style XSL
Public Const gcStr_ADPRegKeyXMLNoXSL As String = "XMLNoXSL"

' Nom du fichier XML listant les packages et les classes
Public Const gcStr_ADPRegKeyFichPackagesClasses As String = "FichPackagesClasses"

' Nom du fichier XML des utilisations entre classes
Public Const gcStr_ADPRegKeyFichUsesClasses As String = "FichUsesClasses"

' Nom du fichier XML des dépendances entre classes
Public Const gcStr_ADPRegKeyFichDependClasses As String = "FichDependClasses"

' Nom du script à exécuter
Public Const gcStr_ADPRegKeyFichScriptDepend As String = "ScriptDepend"

'------------------------------------------------------------------------------
' Constantes de nommage des éléments de structuration du modèle Rose
'------------------------------------------------------------------------------

Public Const gcStr_ADPViewName_UseCase As String = "Use Case View"
Public Const gcStr_ADPViewName_Logical As String = "Logical View"
Public Const gcStr_ADPViewName_Component As String = "Component View"

Public Const gcStr_ADPPckgName_RecueilBesoins As String = "RecueilBesoins"
Public Const gcStr_ADPPckgName_Analyse As String = "Analyse"
Public Const gcStr_ADPPckgName_ConceptionTechnique As String = "ConceptionTechnique"

'------------------------------------------------------------------------------
' Constantes dédiées aux stéréotypes attribués aux éléments du modèle Rose
'------------------------------------------------------------------------------

Public Const gcStr_ADPStereotypeClasse_RB_metier As String = "objet_metier"

Public Const gcStr_ADPStereotypeClasse_AN_metier As String = "classe_metier"
Public Const gcStr_ADPStereotypeClasse_AN_technique As String = "classe_technique"

Public Const gcStr_ADPStereotypeClasse_CT_metier As String = "metier"
Public Const gcStr_ADPStereotypeClasse_CT_utility As String = "utility"
Public Const gcStr_ADPStereotypeClasse_CT_classe As String = "classe"
Public Const gcStr_ADPStereotypeClasse_CT_interface As String = "Interface"

'------------------------------------------------------------------------------
' Constantes dédiées au nommage des éléments du modèle Rose
'------------------------------------------------------------------------------

Public Const gcStr_ADPPrefixeClasse_RecueilBesoins As String = "OM"
Public Const gcStr_ADPPrefixeClasse_Analyse As String = "AN"

'------------------------------------------------------------------------------
' Constantes dédiées aux valeurs significatives des propriétés Rose
'------------------------------------------------------------------------------

Public Const gcInt_ADPPropMessage_Synchro_Simple As Integer = 0
Public Const gcInt_ADPPropMessage_Synchro_Synchronous As Integer = 1
Public Const gcInt_ADPPropMessage_Synchro_Balking As Integer = 2
Public Const gcInt_ADPPropMessage_Synchro_Timeout As Integer = 3
Public Const gcInt_ADPPropMessage_Synchro_Asynchronous As Integer = 4
Public Const gcInt_ADPPropMessage_Synchro_ProcedureCall As Integer = 5
Public Const gcInt_ADPPropMessage_Synchro_Return As Integer = 6

'------------------------------------------------------------------------------
' Constantes dédiées au balisage des flux XML générés
'------------------------------------------------------------------------------

Public Const gcStr_ADPTagXML_Associations As String = "associations"
Public Const gcStr_ADPTagXML_Attributes As String = "attributes"
Public Const gcStr_ADPTagXML_Class As String = "class"
Public Const gcStr_ADPTagXML_Interface As String = "interface"
Public Const gcStr_ADPTagXML_Package As String = "package"
Public Const gcStr_ADPTagXML_Parameters As String = "parameters"
Public Const gcStr_ADPTagXML_Realizes As String = "realizes"
Public Const gcStr_ADPTagXML_SuperClass As String = "superclass"
Public Const gcStr_ADPTagXML_Uses As String = "uses"

Public Const gcStr_ADPAttributeXML_Name As String = "name"
Public Const gcStr_ADPAttributeXML_QualifiedName As String = "qualifiedname"
Public Const gcStr_ADPAttributeXML_Type As String = "type"

Public Const gcStr_ADPValueXML_Type_Single As String = "simple"
Public Const gcStr_ADPValueXML_Type_Double As String = "double"

'------------------------------------------------------------------------------
' Constantes dédiées au balisage des utilisations générées
'------------------------------------------------------------------------------

Public Const gcStr_ADPTagUses_Association_Double As String = "ASCD"
Public Const gcStr_ADPTagUses_Association_Single As String = "ASCS"
Public Const gcStr_ADPTagUses_Attribute As String = "ATRB"
Public Const gcStr_ADPTagUses_Declare As String = "DECL"
Public Const gcStr_ADPTagUses_Implement As String = "IMPL"
Public Const gcStr_ADPTagUses_Inherit As String = "HERT"
Public Const gcStr_ADPTagUses_Method As String = "METH"
Public Const gcStr_ADPTagUses_Parameter As String = "PRMT"

