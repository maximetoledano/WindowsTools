
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     ~ Documentation des outils Windows. ~
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Repères:
~~~~~~~~

Code outil:       GCS
Libellé long:     Génération de Codes Sources
Version:          0.1
Utilisation:      Sous Windows uniquement
Points d'entrée:  Par raccourci Windows paramétré

Description:
~~~~~~~~~~~~

Destiné à faciliter l'écriture de codes sources à lignes répétitives, cet outil permet de générer à la volée un contenu quelconque, à partir de fichiers templates prédéfinis contenant des variables à valoriser lors de la génération.

Cette génération consiste à appliquer ces templates, dans un ordre et avec des valeurs de variables, décrits dans un unique fichier de déclaration.

Le fichier de déclaration est traité ligne après ligne (hors ligne vide et commentaires préfixés par "#").

Le résultat de chaque ligne étant ajouter au fichier résultat (fichier "_genCodesSources.txt" du répertoire "Travail").

Le format attendu de ces lignes est:

   <template> | <variable1> = <valeur1> | <variable2> = <valeur2> | ...

Les noms de templates utilisés ci-dessus devant être préalablement déclarés dans un fichier associant le nom et le chemin d'accès des templates:

   <template1> = <chemin1>
   <template2> = <chemin2>
   ...

Fonctionnalités disponibles:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   * Génération de lignes de codes par application de templates avec variables:
   
   Produit un fichier texte résultat dont le contenu est obtenu par application successive de templates prédéfinis, selon un nombre et un paramétrage décrits dans un unique fichier de déclaration.
   
Mode opératoire:
~~~~~~~~~~~~~~~~

   * Déclarer un raccourci Windows (sur script "genCodesSources.bat") en précisant les paramètres suivants:
   
   a) Le fichier des templates (ex: "ListTplFiltresParcoursModele.txt")
   b) Le fichier des déclarations (ex: "DeclVarFiltresParcoursModele.txt")
   
   * Lancer la génération du code (double-click sur le raccourci créé).
   
   * Visualiser et copier-coller les lignes générées selon les besoins.

Clés de registre:
~~~~~~~~~~~~~~~~~

   Aucune clé utilisée.

Evolutions:
~~~~~~~~~~~

   * A venir: Génération à deux niveaux (le fichier actuel des déclarations étant lui-même produit à l'aide d'un fichier de déclaration dans lequel seraient gérés les flux d'entrée et de sortie, autorisant ainsi une génération multi-niveaux simplifiée).

   * 0.1: Génération simple (séquentielle et à un seul niveau de génération) de fichiers sources par application de templates prédéfinis.
