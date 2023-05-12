# Scripts-Utilities
new/renew Ankabot methods

# saleV2.lua *Refonte des méthodes sale* :

__*Description:*__

Il s'agit d'un clonage des méthodes d'Ankabot de la classe sale l'avantage avec ceux-ci c'est :
> Vous pouvez contrôler le delay des méthodes, ils sont donc extrêmement rapide.

> C'est un clonage des méthodes d'Ankabot donc ils respectent les mêmes entrées (arguments) ainsi que les noms des méthodes que ceux de la documentation [https://doc.ankabot.dev/ankabot-pc/methodes/sale] vous pouvez donc vous référenciez  à la doc pour avoir les explications des entrées.

> La méthode updateAllItems possède désormais un paramètre TAUX_TOLERANCE ajoutant plus de sécurité aux ventes, vous pouvez spécifier un taux à ne pas dépasser en valeur estimé de l'objet dans le cas de la modification du prix (exemple 0.5 signifie que si le prix en HDV était inférieur strictement à 50% de la valeur estimée : le prix de notre objet en vente ne sera

> C'est pas un vrai avantage mais s'il vous est arrivé un jour de vous avoir fais chier de savoir si vous devez mettre 1 , 2 ,3 ou 1 ,10 , 100 dans l'argument lot de certain méthodes , alors sur ceux-ci c'est toujours la quantité (1, 10 , 100) 

__*Utilisation :*__

1- Télécharger le fichier saleV2.lua

2- Copier le fichier dans le répertoire de votre Ankabot

3- Vous pouvez utiliser ces fonctions de façon normale comme ce que vous faites pour ceux d'Ankabot en initialisant votre script avec la ligne suivant : `saleV2 = dofile('saleV2.lua')` au tout début
