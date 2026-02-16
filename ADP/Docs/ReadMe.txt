
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     ~ Documentation des outils Windows. ~
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Repères:
~~~~~~~~

Code outil:       ADP
Libellé long:     Arbre des Dépendances des Packages
Version:          0.3
Utilisation:      Sous Rose uniquement
Points d'entrée:  Menu "Outils Méthodes ==> Dépendances Inter-Packages"

Description:
~~~~~~~~~~~~

Outil d'extraction des utilisations entre classes, à partir d'une vue choisie (URB, UAN, LRB, LAN, LCT), permettant de reconstituer l'arbre (en réalité, le graphe) de dépendances des packages.

Les fichiers résultats (les utilisations, puis les dépendances) pourront être utilisés pour mieux comprendre les classes et packages modélisés; pour vérifier les utilisations réellement mises en oeuvre; pour lotir et planifier la conception, le développement comme l'intégration des différents composants.

Fonctionnalités disponibles:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   * Extraction des utilisations inter-classes :
   
      ==> Pour chaque classe candidate (voir mode opératoire), les informations ci-dessous sont extraites pour constituer le fichier XML des utilisations (qui peut être consulté directement sous un navigateur Web).
      
         - Package contenant la classe trouvée.
         
         - Classes candidates issues des associations de la classe trouvée.
         
         - Classes candidates en attributs de la classe trouvée.
         
         - Classes candidates en paramètres d'opération de la classe trouvée.
   
   Cas particulier du RecueilBesoins, en Use Case View
      
      ==> Pour chaque diagramme de scénario (séquence ou collaboration), les messages échangés sont analysés pour extraire les appels de méthodes entre classes de packages différents.
    
   	Pour chaque classe et package, les nom et nom qualifié sont extraits.
	
   	Le second n'est utilisé que pour contrôler l'intégrité du modèle (vérification de l'unicité des noms trouvés).
   
Mode opératoire:
~~~~~~~~~~~~~~~~

A partir d'un des packages de vue (URB, LAN, LCT), un parcours du modèle est déclenché.

   * Reconstituer les dépendances:
   
   Selon le type de vue choisie, les classes candidates suivantes seront traitées:
   
   	URB ==> Classes dont le nom est préfixé par "OM" et dont le stéréotype est"objet_metier".
   	
   	LAN ==> Classes dont le nom est préfixé par "AN" et dont le stéréotype est "classe_metier" ou "classe_technique".
   	
   	LCT ==> Classes dont le stéréotype est "metier", "utility" ou "Interface".
   
   Le modèle Rose ne sera pas modifié par l'activation de ces fonctionnalités.
   
Clés de registre:
~~~~~~~~~~~~~~~~~

   HKEY_LOCAL_MACHINE
    |_ SOFTWARE
        |_ Rational Software
            |_ Rose
                |_ AddIns
                    |_ Outils4Octalis
                        |_ ADP

   * FichPackagesClasses ==> Fichier des utilisations extraites de Rose.

   * FichDependClasses ==> Fichier des dépendances reconstituées.

   * ScriptDepend ==> Nom du script appelé pour reconstituer les dépendances inter-packages à partir des utilisations inter-classes.

   * FichXSLTransform ==> Nom du fichier de transformation XSL.

   * XMLNoXSL ==> Désactive l'utilisation du fichier de transformation XSL.

Evolutions:
~~~~~~~~~~~

   * 0.3: Prise en compte des appels de méthodes (utilisation "METH"), à partir des diagrammes de scénarios sur Use Case View / RecueilBesoins.

   * 0.2: Couplage finalisé pour génération ADP complet depuis Rose. Refonte de l'algorithme d'extraction des dépendances et niveaux de packages pour fiabiliser les informations produites.

   * 0.1: Génération du fichier des utilisations.
