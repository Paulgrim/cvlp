# TODO et mise en place

1. mettre en place pooling sur encoder pour pouvoir faire embedding. Faire quelque chose de reproductible
2. essayer de faire elasticsearch
3. Essayer d'autres visual embedding, autres positions embedding


Clip utiliser la projection pour la sortie :

Si aux boxes je ne dis pas à quoi ca correspond on va avoir un problème pour l'entrainement
Il faudrait plutot pouvoir donner 'tous l'embedding' de l'image avec clip directement
Pour  l'instant on commence comme cela et on pourra jouer sur lorsuqe l'on instancie le joint encoder pour changer cela

### pour charger joint encoder

On a sauvegardé en utilisant pretrain model
On peut le recharger depuis T5 sans rien d'autres.
On pourra donc le modifier commen on veut et changer visual embedding etc normalement mais il faudra surmeent modifié la config des encoders pour recharger les modèles avec une nouvelle config.

Commment faire pour le modèle principale sachant qu'il y a plusieurs type d'encoder ?
Voir dans Clip comment s'est géré

## TODO

- [ ] faire embedding et faire la recherche de performance. Dans notre cas on aura pas besoin du article2index car on fera dirextement la recherche dans les passages.

[ ] modifer le joint encoder de Bart

- [ ] faisabilité pour avoit un énorme dataset avec passages et images pour pretrain le modèle
- [ ] faire l'embedding
- [ ] réfléchir à la loss
- [ ] comment on nourrit le model la question et image et des bons et mauvais exemple. Voir entrainement du DPR qui peut aider
- [ ] réfléchir pour ajouter la projection a la fin
- [ ] comment freeze le modèle
- [ ] partager les paramètres entre les duex encoders
- [ ] torch topk
- [ ] etre sur que les indices minés et les article2passage.json soit bon pour pouvoir comparer de manière legit
- [ ] faire le DataLoader

## DONE

## mise en place et choix

on a télécharger les joint encoder den les chargeant puis enregistré
Pour ele modèle de base on n'est pas obligé de charger depuis encoder. On peut juste charger depuis T5 et BART initialisation se fera toute seul.



Traitement sur les images, on utilise ceux utiliser avec les modèles d'images donnés.

Dans VL adapter on pourra trouver celui pour clip

contrastive pretraining

pas d'intérêt à fine tuner le model de vision. + faster cnn pas stable a l'entrainement de cette facon la : source article => Ils en parlent dans VL adapter mais recup la source pour l'insérer.

Il faut que la recherche entre les vecteurs soient de la même facon que la cosine similarité entre modèle. Mettre en place elasticsearch

De cette facon si on récup les même choses on peut imaginer essayer notre modèle avec d'autres types d'encoder

On peut facilement utiliser VL Bart aussi donc le faire aussi

On n'utilise pas les préfixes mais c'est qqch que l'on pourrait faire car le modèle est entrainé la dessus. Via Instruction NER. Ajouter au moins question : et passage :

Faire un pretrain avec beaucoup de données : 

    - avoir besoin de récup les questions ambigue
    - faire matcher des passages
    - faire les embeddings
    - faire notre entrainement
    => en somme créer un dataset qui ne sera pas parfait du tout mais peut permettre d'entrainer 

Je peux d'abord faire un entrainement seulement sur la partie language puis dans un second temps ajouter les tâches de vision. voir même avoir deux facon de training.

faire un dataset de question et passage un peu beateau pour faire le pretraining. Scrapper des choses ?

Ou comment faire le pretraining ? : voir comment ils ont fait avec InstructionER pour ajouter un nouveau préfix et fait du few shot

Il faudra faire attention à overfitting au vue de la taille de nos données (courbe de validation nous aidera dans ce cas là par exmple). Palier à l'absence de données.

Clip on n'a pas de modèle disponible. Comment faire en sorte de réaliser entrainement ?

Peut etre aussi travailler sur DPR context et question encoder en ajoutant une partie par rapport à l'image.

Pour l'instant on choisit que si l'on choisit un type d'encoder on le met dans les deux cas

### recup

on voit comment faire une architecture compatible clip et faster cnn
on récupère truc pour preprocess image avec clip
on voit si on utilise le meilleur modèle de VL T5 avec CLIP comme ca on pourra utiliser les deux en baseline.
Il y a des infos dans le trainer.py de VL adapter pour freeze le modèle

vl T5 est grandement copié sur le code pour modèliser t5

## ressource

multimodal représentation mais par région :

- [VLT5]()
- [VL BERT](https://github.com/jackroos/VL-BERT)
- [Unified framework vl bert](https://arxiv.org/pdf/2011.15124.pdf) [git](https://github.com/e-bug/volta)

voir si pas mieux de partir sur VL Bert car on s'en fout du decoder et VL T5 s'est son seul intérêt à part qu'on peut utiliser le pretrain. Mais je peux surement utiliser un pretrain de ce modèle.

<https://drive.google.com/drive/folders/1wLdUVd0zYFsrF0LQvAUCy5TnTGDW48Fo> pour recup les modèles

VL BART ?
VL T5 ?
VL T5 > VIL BERT

avec CLIP

- [VL Adapter](https://github.com/ylsung/VL_adapter/) [paper](https://arxiv.org/pdf/2112.06825.pdf)

- [Clip VIL](https://arxiv.org/pdf/2107.06383.pdf) Il reste plus intéressant d'utiliser VL T5 ou VL Bart je pense résultat meilleurs mais idées est la même

Au final il décide de freeze CLIP donc ca nous arrange

Comment features image de clip sont intégrés ?

dans CLIP VIL

clip_prepro_feats.py extract the clip features (both fc feature and last conv feature) of each image. The features are saved in data/cocotalk_clip_${model_type}_fc and data/cocotalk_clip_${model_type}_att
[fichier ou il font une prepro des images pour clip](https://github.com/clip-vil/CLIP-ViL/blob/master/CLIP-ViL-Direct/caption/scripts/clip_prepro_feats.py)

Dans Vl Adapter
dans VLT5/scripts/images on a les scripts bash pour faire les entrainements de VLT5

- [ViQuAE]
- [simple implementation de clip](https://towardsdatascience.com/simple-implementation-of-openai-clip-model-a-tutorial-ace6ff01d9f2)

Note sur VL T5 et Visual adapter

La philosophie c'est d'avoir un modeling un modeling_t5 qui est le modèle de base et dont pour chaque tahe particulière un modèle peut hériter

Dans classification.py on recup le clip et on le définit comme étant l'encoder du model. Da,s modeling on a qqch pour clip ligne 725 ou on voit un embedding. Ils utilisent pour les boxes ne sortent de matrice.
Je pense que pour les features ils prennent plusieurs aussi. Comprendre ce que renvoit exactement ce modèle.