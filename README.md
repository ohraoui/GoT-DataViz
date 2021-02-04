# GoT-DataViz
Visualization on some of the popular TV series "Game of Thrones" data, using R Shiny. 

**L'app shiny est disponible au lien suivant : https://ohraoui.shinyapps.io/GoT-DataViz/**

Dans le cadre d'un projet de visualisation des données, nous avons été ammenés à travailler sur des données de la série Game of Thrones, 
afin de créer un dashboard interactif permettant d'explorer certaines données relatives à la série.

Nous avons utilisé les tables 'characters', 'episodes', 'scenes' et 'appearances' pour réaliser 6 graphes répartis en 2 onglets : *Personnages & Lieux* et *Temps total à l'écran*.
Dans le premier onglet, nous avons choisi de représenter les 3 graphes suivants :
* Représentation en barres de la durée d'apparition par saison des lieux suivants de la série : Meereen, North of the Wall, The Crownlands, The North, The Riverlands et The Wall. Le graphe permet d'avoir des informations sur chaque barre en la survolant du curseur ; une barre latérale permet de filtrer les saisons à afficher.
* Une répartition spatiale des scènes sur la carte du monde de Game of Thrones (les continents Westeros et Essos) pour les personnages suivants : Jon Snow, Tyrion Lannister, Daenerys Taragryen, Sansa Stark, Cersei Lannister et Arya Stark. Une barre latérale permet de choisir le personnage pour lequel afficher les informations.
* Un graphe représentant la durée d'apparition par épisode pour les mêmes personnages. Une barre latérale permet de choisir le personnage pour lequel afficher les informations.

Dans le deuxième onglet, les 3 graphes suivants sont représentés :
* Un graphe qui donne la durée cumulée pendant laquelle chaque personnage principal choisi dans les graphes du premier onglet est apparu dans la série suivant les saisons. Chaque saison est représentée par une couleur différente, et survoler une couleur avec le curseur permet d'avoir des informations, dont par exemple le nombre de minutes d'apparition.
* Une visualisation plus détaillée du graphe précédent, divisée par saison et montrant le temps d'apparition pour chaque personnafe, en utilisant un slider pour sélectionner la saison.
* Enfin, un graphe qui regroupe globalement les informations précédentes, avec le nombre de morts en plus. *(Le travail sur ce graphe est encore en progrès, ggplotly désordonnant un peu la légende et le graphe en soi.)*
