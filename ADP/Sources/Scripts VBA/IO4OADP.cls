VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IO4OADP"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False

'******************************************************************************
' CLASSE               : IO4OADP
' COUCHE               : Outils4Octalis (Add-In Rose)
' DESCRIPTION          : Classe d'interface apportant, au add-in Outils4Octalis,
' les fonctionnalités d'assistance à la Conception Technique
'******************************************************************************

Option Explicit

'******************************************************************************
' Mise à jour automatique des informations de gestion de versions par VSS
'******************************************************************************
' ==> $Workfile: IO4OADP.cls $
' ==> $Revision: 19 $
' ==> $Date: 22/10/03 10:54 $
' ==> $Author: Mtoledano $
' ==> $Archive: /Add-in Rose/ADP/IO4OADP.cls $
'******************************************************************************
Const VSS_Infos_IO4OADP_CLS = "$Header: /Add-in Rose/ADP/IO4OADP.cls 19    22/10/03 10:54 Mtoledano $"
'******************************************************************************

'******************************************************************************
' NOM                  : msPub_ReconstituerDependances
' DESCRIPTION          : Point d'entrée de l'outil ADP, dédié au parcours du
' modèle Rose en vue de la reconstitution des dépendances entre classes, puis
' entre packages.
' PARAMETRES           :
' RETOUR               :
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 21/03/03
'******************************************************************************
' DESCRIPTION          : Modification appel à 'ParcourirPackageVue' pour
' filtrage sélectif des classes candidates.
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 27/03/03
'******************************************************************************
' DESCRIPTION          : Ajout point d'entrée pour analyse des diagrammes de
' scénarios (si UCV / RecueilBesoins).
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 17/10/03
'******************************************************************************

Public Sub msPub_ReconstituerDependances()
    Dim vBln_Ok As Boolean
    Dim vCol_Cat As RoseCategoryCollection
    Dim vObj_Cat As RoseCategory
    Dim vObj_CatParcours As RoseCategory
    Dim vStr_TypeVue As String
    Dim vStr_Cmd As String
    Dim vBln_ResultOuvert As Boolean
    Dim vBln_Fin As Boolean
    Dim vInt_Cpt As Integer
    
    vBln_Ok = True
    vBln_ResultOuvert = False
    vBln_Fin = False
    
    Set vObj_CatParcours = Nothing
    
    vStr_TypeVue = ""
    
    Set vCol_Cat = Nothing
    Set vObj_Cat = Nothing
    
    Call sPub_TracerMessage("IO4OADP.msPub_ReconstituerDependances", NatureMessage_Fonctions)
    
    Call sPub_TracerMessage("Outils4Octalis: Demande de reconstitution des dépendances inter-packages", NatureMessage_Messages)
    
    If (aObj_envRoseAppInst Is Nothing) Then
        Call sPub_TracerMessage("<msPub_ReconstituerDependances> Référence à l'application Rose non initialisée !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If
    
    If (aObj_IHMChoixVueTravail Is Nothing) Then
        Call sPub_TracerMessage("<msPub_ReconstituerDependances> IHM de choix de la vue de travail non initialisée !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération du package sélectionné
    If vBln_Ok Then
        Set vCol_Cat = aObj_envRoseAppInst.CurrentModel.GetSelectedCategories()
        
        If (vCol_Cat.Count = 1) Then
            Set vObj_Cat = vCol_Cat.GetAt(1)
            
            If Not (vObj_Cat Is Nothing) Then
                If (vBln_Ok) Then
                    ' Récupération du type de vue concernée
                    vBln_Ok = mfPriBln_ValiderPackageSel(vObj_Cat, vStr_TypeVue)
                    
                    If ((Not vBln_Ok) Or (vStr_TypeVue = "")) Then
                        Call sPub_TracerMessage("<msPub_ReconstituerDependances> Echec récupération vue package [" & vObj_Cat.GetQualifiedName() & "] !", NatureMessage_Erreurs)
                    End If
               Else
                    Call sPub_TracerMessage("<msPub_ReconstituerDependances> Echec traitement package [" & vObj_Cat.Name & "] !", NatureMessage_Erreurs)
                End If
            Else
                Call sPub_TracerMessage("<msPub_ReconstituerDependances> Package vide trouvé !", NatureMessage_Erreurs)
                vBln_Ok = False
            End If
        ElseIf (vCol_Cat.Count > 1) Then
            Call sPub_TracerMessage("<msPub_ReconstituerDependances> Plusieurs packages sélectionnés !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Arrêt des traitements si aucun élément récupéré
    If vBln_Ok Then
        If (vObj_Cat Is Nothing) Then
            Call sPub_TracerMessage("... Aucun package sélectionné !", NatureMessage_Messages)
            vBln_Fin = True
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Intialisation et affichage de la fenêtre de choix
    If (vBln_Ok And Not vBln_Fin) Then
        Call aObj_IHMChoixVueTravail.sPub_Initialiser(vStr_TypeVue)
        
        ' Affichage de l'IHM pour choix de la vue
        Call aObj_IHMChoixVueTravail.Show(vbModal)
        
        ' Récupération du type de vue retenue
        If (aObj_IHMChoixVueTravail.mgBln_Retour) Then
            ' Mémorisation du type de vue à parcourir
            If (aObj_IHMChoixVueTravail.mgStr_TypeVue <> vStr_TypeVue) Then
                vStr_TypeVue = aObj_IHMChoixVueTravail.mgStr_TypeVue
            Else
                ' Initialisation du package à parcourir à l'aide de celui sélectionné
                If Not (vObj_Cat Is Nothing) Then
                    Set vObj_CatParcours = vObj_Cat
                End If
            End If
            
            Call sPub_TracerMessage("... Etude des dépendances [" & vStr_TypeVue & "]", NatureMessage_Messages)
        Else
            Call sPub_TracerMessage("... Etude des dépendances annulée", NatureMessage_Messages)
            vBln_Fin = True
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération du package à parcourir, si non initialisés
    If (vBln_Ok And Not vBln_Fin And (vObj_CatParcours Is Nothing)) Then
        vBln_Ok = mfPriBln_RecupererPackageVue(vStr_TypeVue, vObj_CatParcours)
        
        If Not vBln_Ok Then
            Call sPub_TracerMessage("<msPub_ReconstituerDependances> Récupération package à parcourir incorrect !", NatureMessage_Erreurs)
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Ouverture, en écriture, du fichier des classes et packages
    If vBln_Ok Then
        vBln_Ok = fPubBln_OpenOutputFile(fPubStr_GetO4OADPPathPackagesClasses(), gInt_ADPIdOutFileClasses)
        
        If vBln_Ok Then
            vBln_ResultOuvert = True
        Else
            Call sPub_TracerMessage("<msPub_ReconstituerDependances> Ouverture fichier des classes et packages incorrecte [" & fPubStr_GetO4OADPPathPackagesClasses() & "] !", NatureMessage_Erreurs)
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Ouverture, en écriture, du fichier des utilisations entre classes
    If vBln_Ok Then
        vBln_Ok = fPubBln_OpenOutputFile(fPubStr_GetO4OADPPathUsesClasses(), gInt_ADPIdOutUsesClasses)
        
        If vBln_Ok Then
            vBln_ResultOuvert = True
        Else
            Call sPub_TracerMessage("<msPub_ReconstituerDependances> Ouverture fichier des utilisations entre classes incorrecte [" & fPubStr_GetO4OADPPathUsesClasses() & "] !", NatureMessage_Erreurs)
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Parcours de tous les packages, à partir de celui récupéré ci-dessus
    If (vBln_Ok And Not vBln_Fin) Then
        vBln_Ok = mfPriBln_ParcourirPackageVue(vObj_CatParcours, vStr_TypeVue)
        
        If Not vBln_Ok Then
            Call sPub_TracerMessage("<msPub_ReconstituerDependances> Parcours des packages incorrect !", NatureMessage_Erreurs)
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Si vue Use Case / RecueilBesoins, boucle sur les diagrammes de scénario pour récupération des messages entre classes
    If (vBln_Ok And Not vBln_Fin And (vStr_TypeVue = gcStr_O4OTypeVue_URB)) Then
        vBln_Ok = mfPriBln_ParcourirScenarioDiagrams(vObj_CatParcours, vStr_TypeVue)
        
        If Not vBln_Ok Then
            Call sPub_TracerMessage("<msPub_ReconstituerDependances> Parcours des diagrammes de scénario incorrect !", NatureMessage_Erreurs)
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Fermeture des fichiers ouverts
    If vBln_ResultOuvert Then
        If Not fPubBln_CloseOutputFile(fPubStr_GetO4OADPPathPackagesClasses(), gInt_ADPIdOutFileClasses) Then
            Call sPub_TracerMessage("<msPub_ReconstituerDependances> Fermeture fichier des classes et packages incorrecte [" & fPubStr_GetO4OADPPathPackagesClasses() & "] !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
        
        If Not fPubBln_CloseOutputFile(fPubStr_GetO4OADPPathUsesClasses(), gInt_ADPIdOutUsesClasses) Then
            Call sPub_TracerMessage("<msPub_ReconstituerDependances> Fermeture fichier des utilisations entre classes incorrecte [" & fPubStr_GetO4OADPPathUsesClasses() & "] !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    If (vBln_Ok And Not vBln_Fin) Then
        Call sPub_TracerMessage("Analyse des utilisations pour obtention des dépendances ...", NatureMessage_Messages)
        
        vStr_Cmd = fPubStr_GetO4OADPPathScriptDepend()

        vBln_Ok = fPubBln_WSHExecFichAvecTrace(vStr_Cmd)
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    Set vCol_Cat = Nothing
    Set vObj_Cat = Nothing
    
    If vBln_Ok Then
        Call sPub_TracerMessage("... Reconstitution des dépendances inter-packages terminée", NatureMessage_Messages)
    Else
        Call sPub_TracerMessage("<msPub_ReconstituerDependances> Reconstitution des dépendances inter-packages incorrecte !", NatureMessage_Erreurs)
    End If
End Sub

'******************************************************************************
' NOM                  : mfPriBln_ParcourirPackageVue
' DESCRIPTION          : Parcours de la vue pour récupération des packages et
' des classes
' PARAMETRES           : RoseCategory, String
' RETOUR               : Boolean
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 25/03/03
'******************************************************************************
' DESCRIPTION          : Ajout paramètre supplémentaire pour filtrage fin des
' classes candidates, en fonction du type de vue retenue.
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 27/03/03
'******************************************************************************

Private Function mfPriBln_ParcourirPackageVue(ByVal pObj_Cat As RoseCategory, ByVal pStr_TypeVue As String) As Boolean
    Dim vBln_Ok As Boolean
    Dim vCol_Cls As RoseClassCollection
    Dim vObj_Cls As RoseClass
    Dim vInt_Cpt As Integer
    
    vBln_Ok = True
    
    Set vCol_Cls = Nothing
    Set vObj_Cls = Nothing
    
    Call sPub_TracerMessage("IO4OACT.mfPriBln_ParcourirPackageVue", NatureMessage_Fonctions)
    
    If (pObj_Cat Is Nothing) Then
        Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Package vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    If (pStr_TypeVue = "") Then
        Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Type de vue vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Début d'extraction
    If vBln_Ok Then
        Print #gInt_ADPIdOutFileClasses, "<?xml version=""1.0"" encoding=""ISO8859-1""?>"
        
        If Not fPubBln_GetO4OADPXMLNoXSL() Then
            Print #gInt_ADPIdOutFileClasses, "<?xml:stylesheet type=""text/xsl"" href=""" & fPubStr_GetO4OADPPathXSLTransform() & """?>"
        End If
        
        Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Uses & " " & gcStr_ADPAttributeXML_Name & "=""" & pObj_Cat.Name & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & pObj_Cat.GetQualifiedName() & """>"
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération, en cascade, des classes contenues dans le package à parcourir
    If vBln_Ok Then
        Set vCol_Cls = pObj_Cat.GetAllClassesEx(True, False)
        
        If (vCol_Cls Is Nothing) Then
            Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Collection de classes vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Boucle sur les classes trouvées pour extraction de informations significatives
    If vBln_Ok Then
        For vInt_Cpt = 1 To vCol_Cls.Count
            Set vObj_Cls = vCol_Cls.GetAt(vInt_Cpt)
            
            If Not (vObj_Cls Is Nothing) Then
                ' Restriction aux seules classes candidates
                If mfPriBln_EstClasseCandidate(vObj_Cls, pStr_TypeVue) Then
                    vBln_Ok = mfPriBln_ExtraireDependancesClasse(vObj_Cls, pStr_TypeVue)
                    
                    If Not vBln_Ok Then
                        Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Extraction informations classe incorrecte [" & vObj_Cls.Name & "] !", NatureMessage_Erreurs)
                        Exit For
                    End If
                End If
            Else
                Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Classe vide récupérée (" & vInt_Cpt & ") !", NatureMessage_Erreurs)
                vBln_Ok = False
                Exit For
            End If
        Next vInt_Cpt
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Fin d'extraction
    If vBln_Ok Then
        Print #gInt_ADPIdOutFileClasses, "</" & gcStr_ADPTagXML_Uses & ">"
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    Set vCol_Cls = Nothing
    Set vObj_Cls = Nothing
    
    mfPriBln_ParcourirPackageVue = vBln_Ok
End Function

'******************************************************************************
' NOM                  : mfPriBln_ExtraireDependancesClasse
' DESCRIPTION          : Extraction des informations significatives, en vue de
' la reconstitution des dépendances dune classe donnée
' PARAMETRES           : RoseClass, String
' RETOUR               : Boolean
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 26/03/03
'******************************************************************************
' DESCRIPTION          : Ajout paramètre supplémentaire pour filtrage fin des
' classes candidates, en fonction du type de vue retenue.
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 27/03/03
'******************************************************************************

Private Function mfPriBln_ExtraireDependancesClasse(ByVal pObj_Cls As RoseClass, ByVal pStr_TypeVue As String) As Boolean
    Dim vBln_Ok As Boolean
    Dim vObj_Cat As RoseCategory
    Dim vCol_ClsLiee As RoseClassCollection
    Dim vObj_ClsLiee As RoseClass
    Dim vCol_Intf As RoseRealizeRelationCollection
    Dim vObj_Intf As RoseRealizeRelation
    Dim vCol_Attr As RoseAttributeCollection
    Dim vObj_Attr As RoseAttribute
    Dim vCol_Assc As RoseAssociationCollection
    Dim vObj_Assc As RoseAssociation
    Dim vObj_Role1 As RoseRole
    Dim vObj_Role2 As RoseRole
    Dim vCol_Oper As RoseOperationCollection
    Dim vObj_Oper As RoseOperation
    Dim vCol_Parm As RoseParameterCollection
    Dim vObj_Parm As RoseParameter
    Dim vBln_NavigRoleCls As Boolean
    Dim vBln_NavigRoleClsLiee As Boolean
    Dim vBln_BlocOuvert As Boolean
    Dim vInt_CptI As Integer
    Dim vInt_CptJ As Integer
    
    vBln_Ok = True
    vBln_BlocOuvert = False
    
    Set vObj_Cat = Nothing
    Set vCol_ClsLiee = Nothing
    Set vObj_ClsLiee = Nothing
    Set vCol_Intf = Nothing
    Set vObj_Intf = Nothing
    Set vCol_Attr = Nothing
    Set vObj_Attr = Nothing
    Set vCol_Assc = Nothing
    Set vObj_Assc = Nothing
    Set vObj_Role1 = Nothing
    Set vObj_Role2 = Nothing
    Set vCol_Oper = Nothing
    Set vObj_Oper = Nothing
    Set vCol_Parm = Nothing
    Set vObj_Parm = Nothing
    
    Call sPub_TracerMessage("IO4OACT.mfPriBln_ExtraireDependancesClasse", NatureMessage_Fonctions)
    
    If (pObj_Cls Is Nothing) Then
        Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Classe vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Début d'extraction
    If vBln_Ok Then
        Call sPub_TracerMessage("... Extraction des dépendances de la classe [" & pObj_Cls.Name & "]", NatureMessage_Details)
        
        Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Class & " " & gcStr_ADPAttributeXML_Name & "=""" & pObj_Cls.Name & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & pObj_Cls.GetQualifiedName() & """>"
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération du package parent de la classe à traiter
    If vBln_Ok Then
        Set vObj_Cat = pObj_Cls.ParentCategory
        
        If (vObj_Cat Is Nothing) Then
            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Package parent vide récupéré !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Extraction des noms qualifiés de classe et de package
    If vBln_Ok Then
        Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Package & " " & gcStr_ADPAttributeXML_Name & "=""" & vObj_Cat.Name & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & vObj_Cat.GetQualifiedName() & """/>"
        
        Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Declare & "|" & pObj_Cls.Name & "|" & pObj_Cls.GetQualifiedName() & "|" & vObj_Cat.Name & "|" & vObj_Cat.GetQualifiedName()
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération de l'éventuelle classe mère directe
    If vBln_Ok Then
        Set vCol_ClsLiee = pObj_Cls.GetSuperclasses()
        
        If Not (vCol_ClsLiee Is Nothing) Then
            ' Vérification du nombre de classes trouvées
            If (vCol_ClsLiee.Count = 1) Then
                ' Récupération de la classe mère directe
                Set vObj_ClsLiee = vCol_ClsLiee.GetAt(1)
                
                If Not (vObj_ClsLiee Is Nothing) Then
                    ' Restriction aux seules classes candidates
                    If mfPriBln_EstClasseCandidate(vObj_ClsLiee, pStr_TypeVue) Then
                        Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_SuperClass & " " & gcStr_ADPAttributeXML_Name & "=""" & vObj_ClsLiee.Name & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & vObj_ClsLiee.GetQualifiedName() & """/>"
                        
                        Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Inherit & "|" & pObj_Cls.Name & "|" & pObj_Cls.GetQualifiedName() & "|" & vObj_ClsLiee.Name & "|" & vObj_ClsLiee.GetQualifiedName()
                    End If
                Else
                    Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Classe mère vide récupérée !", NatureMessage_Erreurs)
                    vBln_Ok = False
                End If
            ElseIf (vCol_ClsLiee.Count > 1) Then
                Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Nombre de classes mères récupérées incorrect (" & vCol_ClsLiee.Count & ") !", NatureMessage_Erreurs)
                vBln_Ok = False
            End If
        Else
            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Collection de classes mères vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération des éventuelles interfaces réalisées
    If vBln_Ok Then
        Set vCol_Intf = pObj_Cls.GetRealizeRelations()
        
        If Not (vCol_Intf Is Nothing) Then
            vBln_BlocOuvert = False
            
            ' Boucle sur les réalisations d'interfaces trouvées
            For vInt_CptI = 1 To vCol_Intf.Count
                ' Récupération de la réalisation d'interface
                Set vObj_Intf = vCol_Intf.GetAt(vInt_CptI)
                
                If Not (vObj_Intf Is Nothing) Then
                    ' Récupération de la classe liée
                    Set vObj_ClsLiee = vObj_Intf.GetSupplierClass()
                    
                    If Not (vObj_ClsLiee Is Nothing) Then
                        ' Restriction aux seules classes candidates
                        If mfPriBln_EstClasseCandidate(vObj_ClsLiee, pStr_TypeVue) Then
                            ' Ouverture du bloc correspondant, si nécessaire
                            If Not vBln_BlocOuvert Then
                                Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Realizes & ">"
                                vBln_BlocOuvert = True
                            End If
                            
                            Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Interface & " " & gcStr_ADPAttributeXML_Name & "=""" & vObj_ClsLiee.Name & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & vObj_ClsLiee.GetQualifiedName() & """/>"
                            
                            Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Implement & "|" & pObj_Cls.Name & "|" & pObj_Cls.GetQualifiedName() & "|" & vObj_ClsLiee.Name & "|" & vObj_ClsLiee.GetQualifiedName()
                        End If
                    Else
                        Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Classe de réalisation d'interface vide récupérée !", NatureMessage_Erreurs)
                        vBln_Ok = False
                    End If
                Else
                    Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Réalisation d'interface vide récupérée !", NatureMessage_Erreurs)
                    vBln_Ok = False
                End If
            Next vInt_CptI
            
            ' Fermeture du bloc ouvert, si nécessaire
            If (vBln_Ok And vBln_BlocOuvert) Then
                Print #gInt_ADPIdOutFileClasses, "</" & gcStr_ADPTagXML_Realizes & ">"
            End If
        Else
            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Collection de réalisations d'interface vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Traitement des attributs de la classe
    If vBln_Ok Then
        Set vCol_Attr = pObj_Cls.Attributes

        If Not (vCol_Attr Is Nothing) Then
            vBln_BlocOuvert = False
            
            ' Boucle sur les attributs trouvés
            For vInt_CptI = 1 To vCol_Attr.Count
                ' Récupération de l'attribut
                Set vObj_Attr = vCol_Attr.GetAt(vInt_CptI)

                If Not (vObj_Attr Is Nothing) Then
                    ' Récupération de la classe liée au type, si elle existe
                    Set vObj_ClsLiee = vObj_Attr.GetTypeClass()
                    
                    If Not (vObj_ClsLiee Is Nothing) Then
                        ' Restriction aux seules classes candidates
                        If mfPriBln_EstClasseCandidate(vObj_ClsLiee, pStr_TypeVue) Then
                            ' Ouverture du bloc correspondant, si nécessaire
                            If Not vBln_BlocOuvert Then
                                Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Attributes & ">"
                                vBln_BlocOuvert = True
                            End If
                            
                            Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Class & " " & gcStr_ADPAttributeXML_Name & "=""" & vObj_ClsLiee.Name & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & vObj_ClsLiee.GetQualifiedName() & """/>"
                            
                            Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Attribute & "|" & pObj_Cls.Name & "|" & pObj_Cls.GetQualifiedName() & "|" & vObj_ClsLiee.Name & "|" & vObj_ClsLiee.GetQualifiedName()
                        End If
                    End If
                Else
                    Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Attribut vide récupéré (" & vInt_CptI & ") !", NatureMessage_Erreurs)
                    vBln_Ok = False
                    Exit For
                End If
            Next vInt_CptI
            
            ' Fermeture du bloc ouvert, si nécessaire
            If (vBln_Ok And vBln_BlocOuvert) Then
                Print #gInt_ADPIdOutFileClasses, "</" & gcStr_ADPTagXML_Attributes & ">"
            End If
        Else
            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Collection d'attributs vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Traitement des associations de la classe
    If vBln_Ok Then
        Set vCol_Assc = pObj_Cls.GetAssociations()

        If Not (vCol_Assc Is Nothing) Then
            vBln_BlocOuvert = False
            
            ' Boucle sur les associations trouvées
            For vInt_CptI = 1 To vCol_Assc.Count
                ' Récupération de l'attribut
                Set vObj_Assc = vCol_Assc.GetAt(vInt_CptI)

                If Not (vObj_Assc Is Nothing) Then
                    ' Récupération du rôle 1
                    Set vObj_Role1 = vObj_Assc.Role1
                    
                    If (vObj_Role1 Is Nothing) Then
                        Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Rôle vide récupéré (1) !", NatureMessage_Erreurs)
                        vBln_Ok = False
                        Exit For
                    End If
                    
                    ' Récupération du rôle 2
                    Set vObj_Role2 = vObj_Assc.Role2
                    
                    If (vObj_Role2 Is Nothing) Then
                        Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Rôle vide récupéré (2) !", NatureMessage_Erreurs)
                        vBln_Ok = False
                        Exit For
                    End If
                    
                    ' Vérification de la non-réflexivité de la relation
                    If (vObj_Role1.SupplierName <> vObj_Role2.SupplierName) Then
                        ' Récupération et test de la classe liée au rôle 1
                        Set vObj_ClsLiee = vObj_Role1.Class
                        
                        If Not (vObj_ClsLiee Is Nothing) Then
                            If (vObj_ClsLiee.GetUniqueID() <> pObj_Cls.GetUniqueID()) Then
                                ' Récupération des cardinalités
                                vBln_NavigRoleCls = vObj_Role2.Navigable
                                vBln_NavigRoleClsLiee = vObj_Role1.Navigable
                            Else
                                ' Récupération de la classe liée au rôle 2
                                Set vObj_ClsLiee = vObj_Role2.Class
                                
                                If Not (vObj_ClsLiee Is Nothing) Then
                                    ' Récupération des cardinalités
                                    vBln_NavigRoleCls = vObj_Role1.Navigable
                                    vBln_NavigRoleClsLiee = vObj_Role2.Navigable
                                Else
                                    Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Classe vide récupérée (rôle2) !", NatureMessage_Erreurs)
                                    vBln_Ok = False
                                    Exit For
                                End If
                            End If
                        Else
                            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Classe vide récupérée (rôle1) !", NatureMessage_Erreurs)
                            vBln_Ok = False
                            Exit For
                        End If
                        
                        ' Restriction aux seules classes candidates
                        If mfPriBln_EstClasseCandidate(vObj_ClsLiee, pStr_TypeVue) Then
                            ' Déclaration d'une association doublement navigable
                            If (vBln_NavigRoleCls And vBln_NavigRoleClsLiee) Then
                                ' Ouverture du bloc correspondant, si nécessaire
                                If Not vBln_BlocOuvert Then
                                    Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Associations & ">"
                                    vBln_BlocOuvert = True
                                End If
                                
                                Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Class & " " & gcStr_ADPAttributeXML_Name & "=""" & vObj_ClsLiee.Name & """ " & gcStr_ADPAttributeXML_Type & "=""" & gcStr_ADPValueXML_Type_Double & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & vObj_ClsLiee.GetQualifiedName() & """/>"
                                
                                Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Association_Double & "|" & pObj_Cls.Name & "|" & pObj_Cls.GetQualifiedName() & "|" & vObj_ClsLiee.Name & "|" & vObj_ClsLiee.GetQualifiedName()
                            
                            ' Déclaration d'une association simplement navigable
                            ' (le cas du rôle direct navigable est traité par l'autre classe)
                            ElseIf vBln_NavigRoleClsLiee Then
                                ' Ouverture du bloc correspondant, si nécessaire
                                If Not vBln_BlocOuvert Then
                                    Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Associations & ">"
                                    vBln_BlocOuvert = True
                                End If
                                
                                Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Class & " " & gcStr_ADPAttributeXML_Name & "=""" & vObj_ClsLiee.Name & """ " & gcStr_ADPAttributeXML_Type & "=""" & gcStr_ADPValueXML_Type_Single & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & vObj_ClsLiee.GetQualifiedName() & """/>"
                                
                                Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Association_Single & "|" & pObj_Cls.Name & "|" & pObj_Cls.GetQualifiedName() & "|" & vObj_ClsLiee.Name & "|" & vObj_ClsLiee.GetQualifiedName()
                            End If
                        End If
                    End If
                Else
                    Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Association vide récupérée (" & vInt_CptI & ") !", NatureMessage_Erreurs)
                    vBln_Ok = False
                    Exit For
                End If
            Next vInt_CptI
            
            ' Fermeture du bloc ouvert, si nécessaire
            If (vBln_Ok And vBln_BlocOuvert) Then
                Print #gInt_ADPIdOutFileClasses, "</" & gcStr_ADPTagXML_Associations & ">"
            End If
        Else
            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Collection d'associations vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Traitement des paramètres d'opération de la classe
    If vBln_Ok Then
        Set vCol_Oper = pObj_Cls.Operations

        If Not (vCol_Oper Is Nothing) Then
            vBln_BlocOuvert = False
            
            ' Boucle sur les opérations trouvées
            For vInt_CptI = 1 To vCol_Oper.Count
                ' Récupération de l'opération
                Set vObj_Oper = vCol_Oper.GetAt(vInt_CptI)

                If Not (vObj_Oper Is Nothing) Then
                    ' Récupération des paramètres de l'opération
                    Set vCol_Parm = vObj_Oper.Parameters
                    
                    If Not (vCol_Parm Is Nothing) Then
                        ' Boucle sur les paramètres trouvés
                        For vInt_CptJ = 1 To vCol_Parm.Count
                            Set vObj_Parm = vCol_Parm.GetAt(vInt_CptJ)
                            
                            If Not (vObj_Parm Is Nothing) Then
                                ' Récupération de la classe liée au type, si elle existe
                                Set vObj_ClsLiee = vObj_Parm.GetTypeClass()
                                
                                If Not (vObj_ClsLiee Is Nothing) Then
                                    ' Restriction aux seules classes candidates
                                    If mfPriBln_EstClasseCandidate(vObj_ClsLiee, pStr_TypeVue) Then
                                        ' Ouverture du bloc correspondant, si nécessaire
                                        If Not vBln_BlocOuvert Then
                                            Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Parameters & ">"
                                            vBln_BlocOuvert = True
                                        End If
                                        
                                        Print #gInt_ADPIdOutFileClasses, "<" & gcStr_ADPTagXML_Class & " " & gcStr_ADPAttributeXML_Name & "=""" & vObj_ClsLiee.Name & """ " & gcStr_ADPAttributeXML_QualifiedName & "=""" & vObj_ClsLiee.GetQualifiedName() & """/>"
                                        
                                        Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Parameter & "|" & pObj_Cls.Name & "|" & pObj_Cls.GetQualifiedName() & "|" & vObj_ClsLiee.Name & "|" & vObj_ClsLiee.GetQualifiedName()
                                    End If
                                End If
                            Else
                                Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Paramètre vide récupéré (" & vInt_CptJ & ") !", NatureMessage_Erreurs)
                                vBln_Ok = False
                                Exit For
                            End If
                        Next vInt_CptJ
                        
                        If Not vBln_Ok Then
                            Exit For
                        End If
                    Else
                        Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Collection de paramètres vide récupérée !", NatureMessage_Erreurs)
                        vBln_Ok = False
                        Exit For
                    End If
                Else
                    Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Opération vide récupérée (" & vInt_CptI & ") !", NatureMessage_Erreurs)
                    vBln_Ok = False
                    Exit For
                End If
            Next vInt_CptI
            
            ' Fermeture du bloc ouvert, si nécessaire
            If (vBln_Ok And vBln_BlocOuvert) Then
                Print #gInt_ADPIdOutFileClasses, "</" & gcStr_ADPTagXML_Parameters & ">"
            End If
        Else
            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesClasse> Collection d'opérations vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Fin d'extraction
    If vBln_Ok Then
        Print #gInt_ADPIdOutFileClasses, "</" & gcStr_ADPTagXML_Class & ">"
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    Set vObj_Cat = Nothing
    Set vCol_ClsLiee = Nothing
    Set vObj_ClsLiee = Nothing
    Set vCol_Intf = Nothing
    Set vObj_Intf = Nothing
    Set vCol_Attr = Nothing
    Set vObj_Attr = Nothing
    Set vCol_Assc = Nothing
    Set vObj_Assc = Nothing
    Set vObj_Role1 = Nothing
    Set vObj_Role2 = Nothing
    Set vCol_Oper = Nothing
    Set vObj_Oper = Nothing
    Set vCol_Parm = Nothing
    Set vObj_Parm = Nothing
    
    mfPriBln_ExtraireDependancesClasse = vBln_Ok
End Function

'******************************************************************************
' NOM                  : mfPriBln_ParcourirScenarioDiagrams
' DESCRIPTION          : Dans le cas du traitement de la Use Case View, parcours
' des diagrammes de scénario (séquence & collaboration), de tous les packages et
' use cases, pour récupération des messages échangés entre classes.
' PARAMETRES           : RoseCategory, String
' RETOUR               : Boolean
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 16/10/03
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Private Function mfPriBln_ParcourirScenarioDiagrams(ByVal pObj_Cat As RoseCategory, ByVal pStr_TypeVue As String) As Boolean
    Dim vBln_Ok As Boolean
    Dim vCol_SubCat As RoseCategoryCollection
    Dim vObj_SubCat As RoseCategory
    Dim vCol_UseCase As RoseUseCaseCollection
    Dim vObj_UseCase As RoseUseCase
    Dim vCol_ScnDiag As RoseScenarioDiagramCollection
    Dim vObj_ScnDiag As RoseScenarioDiagram
    Dim vInt_CptI As Integer
    Dim vInt_CptJ As Integer
    
    vBln_Ok = True
    
    Set vCol_SubCat = Nothing
    Set vObj_SubCat = Nothing
    Set vCol_UseCase = Nothing
    Set vObj_UseCase = Nothing
    Set vCol_ScnDiag = Nothing
    Set vObj_ScnDiag = Nothing
    
    Call sPub_TracerMessage("IO4OACT.mfPriBln_ParcourirScenarioDiagrams", NatureMessage_Fonctions)
    
    If (pObj_Cat Is Nothing) Then
        Call sPub_TracerMessage("<mfPriBln_ParcourirScenarioDiagrams> Package vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    If Not (pStr_TypeVue = gcStr_O4OTypeVue_URB) Then
        Call sPub_TracerMessage("<mfPriBln_ParcourirScenarioDiagrams> Type de vue incorrect en paramètre [" & pStr_TypeVue & "] !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération des diagrammes de scénarios du package courant
    If vBln_Ok Then
        Call sPub_TracerMessage("... Recherche des diagrammes de scénario pour package [" & pObj_Cat.Name & "]", NatureMessage_Details)
        
        Set vCol_ScnDiag = pObj_Cat.ScenarioDiagrams
        
        If (vCol_ScnDiag Is Nothing) Then
            Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Collection de diagrammes de scénario vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Boucle sur les diagrammes de scénarios trouvés
    If vBln_Ok Then
        ' Boucle sur les diagrammes trouvés
        For vInt_CptI = 1 To vCol_ScnDiag.Count
            Set vObj_ScnDiag = vCol_ScnDiag.GetAt(vInt_CptI)
            
            If Not (vObj_ScnDiag Is Nothing) Then
                ' Analyse du diagramme de scénario pour récupération des utilisations de méthodes
                vBln_Ok = mfPriBln_ExtraireDependancesScenario(vObj_ScnDiag, pObj_Cat, pStr_TypeVue)
                
                If Not vBln_Ok Then
                    Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Analyse diagramme de scénario incorrecte [" & vObj_ScnDiag.Name & "] !", NatureMessage_Erreurs)
                    Exit For
                End If
            Else
                Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Diagramme vide récupéré (" & vInt_CptI & ") !", NatureMessage_Erreurs)
                vBln_Ok = False
                Exit For
            End If
        Next vInt_CptI
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération des cas d'utilisation du package courant
    If vBln_Ok Then
        Set vCol_UseCase = pObj_Cat.UseCases

        If (vCol_UseCase Is Nothing) Then
            Call sPub_TracerMessage("<mfPriBln_ParcourirScenarioDiagrams> Collection de cas d'utilisation vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Boucle sur les cas d'utilisation trouvés
    If vBln_Ok Then
        For vInt_CptI = 1 To vCol_UseCase.Count
            Set vObj_UseCase = vCol_UseCase.GetAt(vInt_CptI)

            If Not (vObj_UseCase Is Nothing) Then
                Call sPub_TracerMessage("... Recherche des diagrammes de scénario pour cas d'utilisation [" & vObj_UseCase.Name & "]", NatureMessage_Details)
                
                ' Récupération des diagrammes de scénarios associés
                Set vCol_ScnDiag = vObj_UseCase.ScenarioDiagrams

                If Not (vCol_ScnDiag Is Nothing) Then
                    ' Boucle sur les diagrammes trouvés
                    For vInt_CptJ = 1 To vCol_ScnDiag.Count
                        Set vObj_ScnDiag = vCol_ScnDiag.GetAt(vInt_CptJ)

                        If Not (vObj_ScnDiag Is Nothing) Then
                            ' Analyse du diagramme de scénario pour récupération des utilisations de méthodes
                            vBln_Ok = mfPriBln_ExtraireDependancesScenario(vObj_ScnDiag, pObj_Cat, pStr_TypeVue)

                            If Not vBln_Ok Then
                                Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Analyse diagramme de scénario incorrecte [" & vObj_ScnDiag.Name & "] !", NatureMessage_Erreurs)
                                Exit For
                            End If
                        Else
                            Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Diagramme vide récupéré (" & vInt_CptI & "," & vInt_CptJ & ") !", NatureMessage_Erreurs)
                            vBln_Ok = False
                            Exit For
                        End If
                    Next vInt_CptJ

                    ' Propagation des erreurs
                    If Not vBln_Ok Then
                        Exit For
                    End If
                Else
                    Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Collection de diagrammes de scénario vide récupérée (" & vInt_CptI & ") !", NatureMessage_Erreurs)
                    vBln_Ok = False
                    Exit For
                End If
            Else
                Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Cas d'utilisation vide récupéré (" & vInt_CptI & ") !", NatureMessage_Erreurs)
                vBln_Ok = False
                Exit For
            End If
        Next vInt_CptI
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Rebouclage sur les sous-packages du package courant
    If vBln_Ok Then
        Set vCol_SubCat = pObj_Cat.Categories
        
        If Not (vCol_SubCat Is Nothing) Then
            ' Boucle sur les sous-packages trouvés
            For vInt_CptI = 1 To vCol_SubCat.Count
                Set vObj_SubCat = vCol_SubCat.GetAt(vInt_CptI)
                
                If Not (vObj_SubCat Is Nothing) Then
                    ' Rebouclage sur le sous-package correspondant
                    vBln_Ok = mfPriBln_ParcourirScenarioDiagrams(vObj_SubCat, pStr_TypeVue)
                    
                    If Not vBln_Ok Then
                        Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Analyse diagramme de scénario incorrecte [" & vObj_ScnDiag.Name & "] !", NatureMessage_Erreurs)
                        Exit For
                    End If
                Else
                    Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Sous-package vide récupéré (" & vInt_CptI & ") !", NatureMessage_Erreurs)
                    vBln_Ok = False
                    Exit For
                End If
            Next vInt_CptI
        Else
            Call sPub_TracerMessage("<mfPriBln_ParcourirPackageVue> Collection de sous-package vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    Set vCol_SubCat = Nothing
    Set vObj_SubCat = Nothing
    Set vCol_UseCase = Nothing
    Set vObj_UseCase = Nothing
    Set vCol_ScnDiag = Nothing
    Set vObj_ScnDiag = Nothing
    
    mfPriBln_ParcourirScenarioDiagrams = vBln_Ok
End Function

'******************************************************************************
' NOM                  : mfPriBln_ExtraireDependancesScenario
' DESCRIPTION          : Extraction des appels de méthodes entre classes, à
' partir d'un diagramme de scénario.
' PARAMETRES           : RoseScenarioDiagram, RoseCategory, String
' RETOUR               : Boolean
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 16/10/03
'******************************************************************************
' DESCRIPTION          : Restriction des déclarations d'utilisation aux seuls
' messages entre classes de package distincts.
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 17/10/03
'******************************************************************************

Private Function mfPriBln_ExtraireDependancesScenario(ByVal pObj_ScnDiag As RoseScenarioDiagram, ByVal pObj_Cat As RoseCategory, ByVal pStr_TypeVue As String) As Boolean
    Dim vBln_Ok As Boolean
    Dim vCol_Msg As RoseMessageCollection
    Dim vObj_Msg As RoseMessage
    Dim vObj_InstSnd As RoseObjectInstance
    Dim vObj_InstRcv As RoseObjectInstance
    Dim vObj_ClsSnd As RoseClass
    Dim vObj_ClsRcv As RoseClass
    Dim vInt_Cpt As Integer
    
    vBln_Ok = True
    
    Set vCol_Msg = Nothing
    Set vObj_Msg = Nothing
    Set vObj_InstSnd = Nothing
    Set vObj_InstRcv = Nothing
    Set vObj_ClsSnd = Nothing
    Set vObj_ClsRcv = Nothing
    
    Call sPub_TracerMessage("IO4OACT.mfPriBln_ExtraireDependancesScenario", NatureMessage_Fonctions)
    
    If (pObj_ScnDiag Is Nothing) Then
        Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Diagramme vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If
    
    If (pObj_Cat Is Nothing) Then
        Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Package vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    If Not (pStr_TypeVue = gcStr_O4OTypeVue_URB) Then
        Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Type de vue incorrect en paramètre [" & pStr_TypeVue & "] !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération des messages échangés dans le diagramme courant
    If vBln_Ok Then
        Call sPub_TracerMessage("... Analyse dépendances pour diagramme de scénario [" & pObj_ScnDiag.Name & "]", NatureMessage_Details)
        
        Set vCol_Msg = pObj_ScnDiag.GetMessages()
        
        If (vCol_Msg Is Nothing) Then
            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Collection de messages vide récupérée !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Boucle sur les messages pour récupération des classes concernées et obtention des utilisations
    If vBln_Ok Then
        For vInt_Cpt = 1 To vCol_Msg.Count
            Set vObj_Msg = vCol_Msg.GetAt(vInt_Cpt)
            
            If Not (vObj_Msg Is Nothing) Then
                ' Elimination des messages de retour de valeur
                If (vObj_Msg.Synchronization <> gcInt_ADPPropMessage_Synchro_Return) Then
                    ' Restriction de l'analyse des utilisations aux seuls messages non-réflexifs
                    If Not (vObj_Msg.IsMessageToSelf()) Then
                        ' Récupération de l'émetteur et du receveur
                        Set vObj_InstSnd = vObj_Msg.GetSenderObject()
                        Set vObj_InstRcv = vObj_Msg.GetReceiverObject()
                        
                        If (vObj_InstSnd Is Nothing) Then
                            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Objet émetteur vide récupéré [" & vObj_Msg.Name & "][" & pObj_ScnDiag.Name & "][" & pObj_Cat.Name & "] !", NatureMessage_Erreurs)
                            vBln_Ok = False
                            Exit For
                        End If
                        
                        If (vObj_InstRcv Is Nothing) Then
                            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Objet receveur vide récupéré [" & vObj_Msg.Name & "][" & pObj_ScnDiag.Name & "][" & pObj_Cat.Name & "] !", NatureMessage_Erreurs)
                            vBln_Ok = False
                            Exit For
                        End If
                        
                        ' Récupération de leur classe respective
                        Set vObj_ClsSnd = vObj_InstSnd.GetClass()
                        Set vObj_ClsRcv = vObj_InstRcv.GetClass()
                        
                        If (vObj_ClsSnd Is Nothing) Then
                            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Classe d'objet émetteur vide récupérée [" & vObj_Msg.Name & "][" & pObj_ScnDiag.Name & "][" & pObj_Cat.Name & "] !", NatureMessage_Erreurs)
                            vBln_Ok = False
                            Exit For
                        End If
                        
                        If (vObj_ClsRcv Is Nothing) Then
                            Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Classe d'objet receveur vide récupérée [" & vObj_Msg.Name & "][" & pObj_ScnDiag.Name & "][" & pObj_Cat.Name & "] !", NatureMessage_Erreurs)
                            vBln_Ok = False
                            Exit For
                        End If
                        
                        ' Vérification préalable d'une non-réflexivité masquée
                        If Not (vObj_ClsSnd.GetUniqueID() = vObj_ClsRcv.GetUniqueID()) Then
                            ' Limitation aux seules messages inter-package (boucle autorisée en mono-package)
                            If Not (vObj_ClsSnd.ParentCategory.GetUniqueID() = vObj_ClsRcv.ParentCategory.GetUniqueID()) Then
                                ' Restriction aux seules classes candidates
                                If (mfPriBln_EstClasseCandidate(vObj_ClsSnd, pStr_TypeVue) And mfPriBln_EstClasseCandidate(vObj_ClsRcv, pStr_TypeVue)) Then
                                    ' Traitement spécifique d'un message non nommé
                                    If (Len(Trim(vObj_Msg.Name)) = 0) Then
                                        ' Ajout de l'utilisation spécifique trouvée
                                        Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Method & "|" & vObj_ClsSnd.Name & "|" & vObj_ClsSnd.GetQualifiedName() & "|" & vObj_ClsRcv.Name & "|" & vObj_ClsRcv.GetQualifiedName() & "|(sans nom)|" & pObj_ScnDiag.GetQualifiedName()
                                    Else
                                        ' Ajout de l'utilisation spécifique trouvée
                                        Print #gInt_ADPIdOutUsesClasses, gcStr_ADPTagUses_Method & "|" & vObj_ClsSnd.Name & "|" & vObj_ClsSnd.GetQualifiedName() & "|" & vObj_ClsRcv.Name & "|" & vObj_ClsRcv.GetQualifiedName() & "|" & vObj_Msg.Name & "|" & pObj_ScnDiag.GetQualifiedName()
                                    End If
                                End If
                            End If
                        End If
                    End If
                End If
            Else
                Call sPub_TracerMessage("<mfPriBln_ExtraireDependancesScenario> Message vide récupéré (" & vInt_Cpt & ") !", NatureMessage_Erreurs)
                vBln_Ok = False
                Exit For
            End If
        Next vInt_Cpt
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    Set vCol_Msg = Nothing
    Set vObj_Msg = Nothing
    Set vObj_InstSnd = Nothing
    Set vObj_InstRcv = Nothing
    Set vObj_ClsSnd = Nothing
    Set vObj_ClsRcv = Nothing
    
    mfPriBln_ExtraireDependancesScenario = vBln_Ok
End Function

'******************************************************************************
' NOM                  : mfPriBln_RecupererPackageVue
' DESCRIPTION          : Récupération du package à partir du type de vue
' PARAMETRES           : String, RoseCategory
' RETOUR               : Boolean
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 25/03/03
'******************************************************************************
' DESCRIPTION          : Suppression prise en compte 'UAN' et 'LRB'.
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 16/10/03
'******************************************************************************

Private Function mfPriBln_RecupererPackageVue(ByVal pStr_TypeVue As String, ByRef pObj_Cat As RoseCategory) As Boolean
    Dim vBln_Ok As Boolean
    Dim vObj_Mdl As RoseModel
    Dim vObj_CatPere As RoseCategory
    Dim vCol_Cat As RoseCategoryCollection
    Dim vObj_Cat As RoseCategory
    Dim vStr_NomCat As String
    Dim vInt_Cpt As Integer
    
    vBln_Ok = True
    
    Set pObj_Cat = Nothing
    
    Set vObj_CatPere = Nothing
    Set vCol_Cat = Nothing
    Set vObj_Cat = Nothing
    
    vStr_NomCat = ""
    
    Call sPub_TracerMessage("IO4OACT.mfPriBln_RecupererPackageVue", NatureMessage_Fonctions)
    
    If (pStr_TypeVue = "") Then
        Call sPub_TracerMessage("<mfPriBln_RecupererPackageVue> Type de vue vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération du modèle courant
    If vBln_Ok Then
        Set vObj_Mdl = aObj_envRoseAppInst.CurrentModel
        
        If (vObj_Mdl Is Nothing) Then
            Call sPub_TracerMessage("<mfPriBln_RecupererPackageVue> Modèle courant vide récupéré !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération du package père
    If vBln_Ok Then
        Select Case pStr_TypeVue
            Case gcStr_O4OTypeVue_URB
                ' Package père <== Vue 'Use Case'
                Set vObj_CatPere = vObj_Mdl.RootUseCaseCategory
                vStr_NomCat = gcStr_ADPPckgName_RecueilBesoins
            
            Case gcStr_O4OTypeVue_LAN
                ' Package père <== Vue 'Logique'
                Set vObj_CatPere = vObj_Mdl.RootCategory
                vStr_NomCat = gcStr_ADPPckgName_Analyse
                
            Case gcStr_O4OTypeVue_LCT
                ' Package père <== Vue 'Logique'
                Set vObj_CatPere = vObj_Mdl.RootCategory
                vStr_NomCat = gcStr_ADPPckgName_ConceptionTechnique
                
            Case Else
                Call sPub_TracerMessage("<mfPriBln_RecupererPackageVue> Type de vue non géré [" & pStr_TypeVue & "] !", NatureMessage_Erreurs)
                vBln_Ok = False
        End Select
        
        If (vBln_Ok And (vObj_CatPere Is Nothing)) Then
            Call sPub_TracerMessage("<mfPriBln_RecupererPackageVue> Racine vide trouvée pour vue [" & pStr_TypeVue & "] !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération des sous-package du package père trouvé
    If (vBln_Ok And Not (vObj_CatPere Is Nothing)) Then
        Set vCol_Cat = vObj_CatPere.Categories
        
        If (vCol_Cat Is Nothing) Then
            Call sPub_TracerMessage("<mfPriBln_RecupererPackageVue> Collection de packages vide récupérée [" & vObj_CatPere.Name & "] !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération du package recherché
    If (vBln_Ok And Not (vObj_CatPere Is Nothing)) Then
        For vInt_Cpt = 1 To vCol_Cat.Count
            Set vObj_Cat = vCol_Cat.GetAt(vInt_Cpt)
            
            If Not (vObj_Cat Is Nothing) Then
                ' Test si package trouvé correspondant au package recherché
                If (vObj_Cat.Name = vStr_NomCat) Then
                    Call sPub_TracerMessage("... Package [" & vObj_Cat.Name & "] récupéré pour [" & pStr_TypeVue & "]", NatureMessage_Details)
                    Set pObj_Cat = vObj_Cat
                    Exit For
                End If
            Else
                Call sPub_TracerMessage("<mfPriBln_RecupererPackageVue> Package vide récupéré (" & vInt_Cpt & ") [" & vObj_CatPere.Name & "] !", NatureMessage_Erreurs)
                vBln_Ok = False
                Exit For
            End If
        Next vInt_Cpt
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    mfPriBln_RecupererPackageVue = vBln_Ok
End Function

'******************************************************************************
' NOM                  : mfPriBln_ValiderPackageSel
' DESCRIPTION          : Récupération de la vue à partir du package sélectionné
' PARAMETRES           : RoseCategory, String
' RETOUR               : Boolean
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 24/03/03
'******************************************************************************
' DESCRIPTION          : Suppression prise en compte 'UAN' et 'LRB'.
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 16/10/03
'******************************************************************************

Private Function mfPriBln_ValiderPackageSel(ByVal pObj_Cat As RoseCategory, ByRef pStr_TypeVue As String) As Boolean
    Dim vBln_Ok As Boolean
    Dim vObj_CatPere As RoseCategory
    Dim vStr_CatName As String
    Dim vStr_CatPereName As String
    Dim vStr_Prefixe As String
    Dim vInt_LngCnst As Integer
    Dim vBln_Fin As Boolean
    
    vBln_Ok = True
    vBln_Fin = False
    
    pStr_TypeVue = ""
    
    Set vObj_CatPere = Nothing
    
    Call sPub_TracerMessage("IO4OACT.mfPriBln_ValiderPackageSel", NatureMessage_Fonctions)
    
    If (pObj_Cat Is Nothing) Then
        Call sPub_TracerMessage("<mfPriBln_ValiderPackageSel> Package vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Rejet du package racine
    If vBln_Ok Then
        If Not (pObj_Cat.TopLevel()) Then
            vStr_CatName = pObj_Cat.Name
        Else
            Call sPub_TracerMessage("<mfPriBln_ValiderPackageSel> Package racine sélectionné !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Récupération du package père
    If vBln_Ok Then
        Set vObj_CatPere = pObj_Cat.ParentCategory
        
        If Not (vObj_CatPere Is Nothing) Then
            vStr_CatPereName = vObj_CatPere.Name
        Else
            Call sPub_TracerMessage("<mfPriBln_ValiderPackageSel> Package vide récupéré (père) !", NatureMessage_Erreurs)
            vBln_Ok = False
        End If
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Prise en compte immédiate des packages 'RecueilBesoins', 'Analyse' et 'ConceptionTechnique'
    If (vBln_Ok And Not vBln_Fin) Then
        Select Case vStr_CatName
            Case gcStr_ADPPckgName_RecueilBesoins
                Select Case vStr_CatPereName
                    Case gcStr_ADPViewName_UseCase
                        pStr_TypeVue = gcStr_O4OTypeVue_URB
                        vBln_Fin = True
                        
                    Case Else
                        Call sPub_TracerMessage("<mfPriBln_ValiderPackageSel> Package non géré [" & vStr_CatName & "] dans [" & vStr_CatPereName & "] !", NatureMessage_Erreurs)
                        vBln_Ok = False
                End Select
                
            Case gcStr_ADPPckgName_Analyse
                Select Case vStr_CatPereName
                    Case gcStr_ADPViewName_Logical
                        pStr_TypeVue = gcStr_O4OTypeVue_LAN
                        vBln_Fin = True
                        
                    Case Else
                        Call sPub_TracerMessage("<mfPriBln_ValiderPackageSel> Package non géré [" & vStr_CatName & "] dans [" & vStr_CatPereName & "] !", NatureMessage_Erreurs)
                        vBln_Ok = False
                End Select
                
            Case gcStr_ADPPckgName_ConceptionTechnique
                Select Case vStr_CatPereName
                    Case gcStr_ADPViewName_Logical
                        pStr_TypeVue = gcStr_O4OTypeVue_LCT
                        vBln_Fin = True
                        
                    Case Else
                        Call sPub_TracerMessage("<mfPriBln_ValiderPackageSel> Package non géré [" & vStr_CatName & "] dans [" & vStr_CatPereName & "] !", NatureMessage_Erreurs)
                        vBln_Ok = False
                End Select
                
            Case Else
                Call sPub_TracerMessage("<mfPriBln_ValiderPackageSel> Package non géré [" & vStr_CatName & "] dans [" & vStr_CatPereName & "] !", NatureMessage_Erreurs)
                vBln_Ok = False
        End Select
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    mfPriBln_ValiderPackageSel = vBln_Ok
End Function

'******************************************************************************
' NOM                  : mfPriBln_EstClasseCandidate
' DESCRIPTION          : Vérifie que le stéréotype de la classe passée est
' 'metier' ou 'utility'
' PARAMETRES           : RoseClass, String
' RETOUR               : Boolean
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 26/03/03
'******************************************************************************
' DESCRIPTION          : Prise en compte type de vue passé pour sélection fine
' des classes candidates.
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 27/03/03
'******************************************************************************
' DESCRIPTION          : Mise en cohérence avec les nouvelles règles de nommage
' en RecueilBesoins et Analyse. Suppression prise en compte 'UAN' et 'LRB'.
' AUTEUR               : Maxime Toledano
' DATE DE MODIFICATION : 16/10/03
'******************************************************************************

Private Function mfPriBln_EstClasseCandidate(ByVal pObj_Cls As RoseClass, ByVal pStr_TypeVue As String) As Boolean
    Dim vBln_Ok As Boolean
    Dim vBln_Etat As Boolean
    
    vBln_Ok = True
    vBln_Etat = False
    
    Call sPub_TracerMessage("IO4OACT.mfPriBln_EstClasseCandidate", NatureMessage_Fonctions)
    
    If (pObj_Cls Is Nothing) Then
        Call sPub_TracerMessage("<mfPriBln_EstClasseCandidate> Classe vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    If (pStr_TypeVue = "") Then
        Call sPub_TracerMessage("<mfPriBln_EstClasseCandidate> Type de vue vide en paramètre !", NatureMessage_Erreurs)
        vBln_Ok = False
    End If

    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    ' Traitement en fonction du type de vue passé
    If vBln_Ok Then
        Select Case pStr_TypeVue
            Case gcStr_O4OTypeVue_URB
                ' Stéréotype ==> 'objet_metier'
                '  & Préfixe ==> pStr_TypeVue
                If ((pObj_Cls.Stereotype = gcStr_ADPStereotypeClasse_RB_metier) _
                        And (Left$(pObj_Cls.Name, Len(gcStr_ADPPrefixeClasse_RecueilBesoins)) = gcStr_ADPPrefixeClasse_RecueilBesoins)) Then
                    vBln_Etat = True
                End If
                
            Case gcStr_O4OTypeVue_LAN
                ' Stéréotype ==> 'classe_metier' ou 'classe_technique'
                '  & Préfixe ==> pStr_TypeVue
                If (((pObj_Cls.Stereotype = gcStr_ADPStereotypeClasse_AN_metier) Or (pObj_Cls.Stereotype = gcStr_ADPStereotypeClasse_AN_technique)) _
                        And (Left$(pObj_Cls.Name, Len(gcStr_ADPPrefixeClasse_Analyse)) = gcStr_ADPPrefixeClasse_Analyse)) Then
                    vBln_Etat = True
                End If
                
            Case gcStr_O4OTypeVue_LCT
                ' Stéréotype ==> 'metier' ou 'utility' ou 'Interface'
                If ((pObj_Cls.Stereotype = gcStr_ADPStereotypeClasse_CT_metier) _
                        Or (pObj_Cls.Stereotype = gcStr_ADPStereotypeClasse_CT_utility) _
                        Or (pObj_Cls.Stereotype = gcStr_ADPStereotypeClasse_CT_interface)) Then
                    vBln_Etat = True
                End If
                
            Case Else
                Call sPub_TracerMessage("<mfPriBln_EstClasseCandidate> Type de vue non géré [" & pStr_TypeVue & "] !", NatureMessage_Erreurs)
                vBln_Ok = False
        End Select
    End If
    
    ' -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    
    mfPriBln_EstClasseCandidate = vBln_Etat
End Function

