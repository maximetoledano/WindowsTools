
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     ~ Documentation des outils Windows. ~
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Repères:
~~~~~~~~

Code outil:       GAN
Libellé long:     Glossaire des Abréviations Normalisées
Version:          0.8
Utilisation:      Directement sous Windows, via raccourcis dédiés ou ligne de commande, ou encore sous forme d'API.
Points d'entrée:  Raccourci Windows paramétré

Description:
~~~~~~~~~~~~

Propose l'outillage de base pour mettre en oeuvre une gestion de référentiel d'entreprise, en garantissant la production de noms abrégés normalisés, au format XML, à partir de libellés longs en langage naturel.

Cette génération de codes courts est réalisée par applications successives et multiples d'expressions régulières, regroupées et ordonnées au sein du fichier des abréviations normalisées ("Attrb2Abrev.gan").

Chaque ligne de ce fichier (hors lignes vides ou commentaires commençant par "#") se présente sous la forme:

   <expression> = <abréviation>

Si le fichier des abréviations normalisées est unique, il est possible de préciser des expressions régulières spécifiques à un domaine d'application particulier, en définissant un fichier d'exceptions qui sera utilisé en préalable au traitement dudit fichier des abréviations normalisées.

Sous Windows, le raccourci de génération des noms normalisés (pointant sur le script "gen.bat") accepte les paramètres suivants:

   - Choix du fichier de libellés longs à convertir (1er argument).
   
   - Choix du fichier des exceptions à prendre en compte (2nd argument, facultatif).

Sous Rose, le paramétrage suivant est disponible:

   - Sélection des vues (Use Case, Logical, Component) à analyser.
   
   - Sélection des types d'éléments à rechercher, avec prise en compte des sur et sous types d'éléments (ex: Diagram ==> Class Diagram).

Fonctionnalités disponibles:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   * Reconstitution mots candidats: (Windows)
   
   Génération du fichier "_reverse_abrev.txt", contenant la liste des abréviations disponibles avec, pour chacune, les mots candidats possibles (hors traitement des exceptions).
   
   * Détection conflits abréviations normalisées: (Windows)
   
   Procède à l'auto-analyse (application du générateur de codes courts au fichier des abréviations normalisées lui-même) du paramétrage du GAN, en vue du dépistage des éventuelles incohérences potentielles.
   
   En particulier, les contrôles effectués mettent en évidence le "masquage" d'une abréviation par autre (consulter le document "Règles de mise à jour des abréviations normalisées.doc").
   
   REMARQUE: L'analyse des conflits et incohérences potentiels engendre un très grand nombre de conversions et de contrôles, qui peuvent prendre plusieurs minutes en monopolisant toutes les ressources machines !
   
Mode opératoire:
~~~~~~~~~~~~~~~~

   * Activer la fonction de recherche depuis le menu "Tools", ou à l'aide du click droit.
   
   * Définir les critères de recherche des éléments du modèle à analyser.
   
   * Visualiser le résultat dans le fichier généré.
   

Evolutions:
~~~~~~~~~~~

   * A venir: Support de tous les types d'éléments Rose. Prise en compte de nouveaux termes et abréviations métiers.

   * 0.8: Intégration du parcours sélectif.

   * 0.7: Evolutions fonctionnelles du fichier des abréviations.

   * 0.6: Intégration au add-in Rose (projet VB) et mise en conformité (script ".bat"; variables d'environnement; clés de registre).

   * 0.5: Récupération des résultats et 2nd parcours du modèle pour mise à jour des propriétés Rose4Octalis.

   * 0.4: Extraction de tous les libellés longs.

   * 0.3: Couplage à Rose par script VBA (fichier ".ebs").

   * 0.2: Initialisation du fichiers des abréviations ("Attrb2Abrev.gan") pour  apprentissage de la terminologie métier d'Octalis.

   * 0.1: Portage des scripts et librairies Perl.
