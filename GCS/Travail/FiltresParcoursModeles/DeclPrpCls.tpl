
'******************************************************************************
' NOM                  : mgBln_Filtre@<NomEltMdl>@ [Propriété]
' DESCRIPTION          : Filtrage des "@<DscEltMdl>@"
' PARAMETRES           : Booléen (Let)
' RETOUR               : Booléen (Get)
' AUTEUR               : Maxime Toledano
' DATE DE CREATION     : 20/09/02
'******************************************************************************
' DESCRIPTION          :
' AUTEUR               :
' DATE DE MODIFICATION :
'******************************************************************************

Public Property Get mgBln_Filtre@<NomEltMdl>@() As Boolean
' @<DscEltMdl>@ ==> "@<CodeEltMdl>@"

    mgBln_Filtre@<NomEltMdl>@ = lBln_Filtre@<NomEltMdl>@
End Property

Public Property Let mgBln_Filtre@<NomEltMdl>@(ByVal pBln_Etat As Boolean)
' @<DscEltMdl>@ ==> "@<CodeEltMdl>@"

    lBln_Filtre@<NomEltMdl>@ = pBln_Etat
End Property